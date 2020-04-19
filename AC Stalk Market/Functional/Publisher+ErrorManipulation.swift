//
//  Publisher+ErrorManipulation.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import Combine

public enum ErrorLift: Error {
    case wasNever
}

extension Publisher where Failure == Never {
    func normalizeError() -> Publishers.MapError<Self, Error> {
        return self.mapError() { _ in ErrorLift.wasNever }
    }
}
