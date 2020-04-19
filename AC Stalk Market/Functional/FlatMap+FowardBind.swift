//
//  FlatMap+FowardBind.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import Combine

infix operator >>>: AdditionPrecedence
public func >>><P1: Publisher, P2: Publisher, E>(lhs: P1, rhs: P2) -> Publishers.FlatMap<P2, P1> where P1.Failure == E {
    return lhs.flatMap(const(rhs))
}
