//
//  TurnipPredictor.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Combine
import Foundation

public enum TurnipPrediction<F: Error> {
    case sell
    case hold
    case processing
    case failed(F)
}

public protocol UserPrintable {
    func userString() -> String
}

public protocol TurnipPriceEntry {
    var price: Int { get }
    var date: Date { get }
}

public protocol TurnipPredictor {
    associatedtype Failure: Error
    func needsNewValue<S: Sequence>(for prices: S) -> Bool where S.Element: TurnipPriceEntry
    func predict<S: Sequence>(from prices: S) -> AnyPublisher<TurnipPrediction<Failure>, Never> where S.Element: TurnipPriceEntry
}
