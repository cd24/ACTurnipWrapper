//
//  StaticPredictor.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import Combine

public struct StaticPredictor<Failure: Error>: TurnipPredictor {
    public let value: TurnipPrediction<Failure>
    public func predict<S>(from prices: S) -> AnyPublisher<TurnipPrediction<Failure>, Never> where S : Sequence, S.Element : TurnipPriceEntry {
        return Future { $0(.success(self.value))}.eraseToAnyPublisher()
    }
    public func needsNewValue<S>(for prices: S) -> Bool where S : Sequence, S.Element : TurnipPriceEntry { true }
}
