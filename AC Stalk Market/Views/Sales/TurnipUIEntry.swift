//
//  TurnipUIEntry.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import CoreData

public struct TurnipUIEntry: TurnipPriceEntry {
    public let price: Int
    public let date: Date
    
    init(from: TurnipPrice) {
        self.price = Int(from.price)
        self.date = from.date ?? Date()
    }
}

extension TurnipPrice {
    static var sortedFetch: NSFetchRequest<TurnipPrice> {
        let request: NSFetchRequest<TurnipPrice> = TurnipPrice.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return request
    }
}
