//
//  FunctionalBasics.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation

func const<A, T>(_ v: T) -> (A) -> T {
    return { _ in v }
}

extension Int {
    var stringValue: String { "\(self)" }
}

public protocol Unit {
    static var empty: Self { get }
}

extension Optional: Unit {
    public static var empty: Optional<Wrapped> { return nil }
}

extension String: Unit {
    public static var empty: String = ""
}
