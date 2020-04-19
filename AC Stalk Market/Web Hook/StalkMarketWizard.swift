//
//  StalkMarketWizard.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import Combine

extension WeekModel {
    func dayModel(for day: DayOfWeek) -> DayModel? {
        switch day {
        case .monday:
            return self.monday
        case .tuesday:
            return self.tuesday
        case .wednesday:
            return self.wednesday
        case .thursday:
            return self.thursday
        case .friday:
            return self.friday
        case .saturday:
            return self.saturday
        case .sunday:
            return self.sunday
        }
    }
}

public protocol StalkMarketWizardNetworkInterface {
    func prediction(from week: WeekModel?) -> AnyPublisher<String, Error>
}

public struct StalkMarketWizard: TurnipPredictor {
    public typealias Failure = Error
    
    public let network: StalkMarketWizardNetworkInterface
    
    public func needsNewValue<S>(for prices: S) -> Bool where S : Sequence, S.Element : TurnipPriceEntry {
        let week = newestWeek(from: days(from: prices))
        guard let day = week?.dayModel(for: Date().dayOfWeek) else {
            return true
        }
        switch day.day.timeOfDay {
        case .morning:
            return day.morning == nil
        case .afternoon:
            return day.afternoon == nil
        }
    }
    
    public func predict<S>(from prices: S) -> AnyPublisher<TurnipPrediction<Error>, Never> where S : Sequence, S.Element : TurnipPriceEntry {
        let weeks: Future<WeekModel?, Never> = Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                let week = newestWeek(from: days(from: prices))
                promise(.success(week))
            }
        }
        let processing = Future<TurnipPrediction<Error>, Error> { promise in
            promise(.success(.processing))
        }
        let work = weeks
            .normalizeError()
            .receive(on: RunLoop.main)
            .flatMap { week in self.network.prediction(from: week).map { self.parse(content: $0) } }
            .eraseToAnyPublisher()
        return processing.merge(with: work)
            .catch() { error in Just(TurnipPrediction<Error>.failed(error)) }
            .eraseToAnyPublisher()
    }
    
    func parse(content: String) -> TurnipPrediction<Error> {
        if content.lowercased().contains("sell") {
            return .sell
        } else {
            return .hold
        }
    }
}
