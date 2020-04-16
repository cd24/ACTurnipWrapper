//
//  PriceHistoryList.swift
//  AC: Stalk Market Wizard
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import SwiftUI

public struct PriceHistoryList: View {
    @FetchRequest(entity: TurnipPrice.entity(),
                  sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
    var entries: FetchedResults<TurnipPrice>
    
    public var body: some View {
        List(entries.filter { $0.date?.dayOfWeek != .sunday }, id: \.date) { price in
            TurnipPriceCell(price: price)
        }
    }
}
