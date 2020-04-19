//
//  PriceHistoryList.swift
//  AC: Stalk Market Wizard
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

public struct PriceHistoryList: View {
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    @FetchRequest(entity: TurnipPrice.entity(),
                  sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
    var entries: FetchedResults<TurnipPrice>
    
    public var body: some View {
        List() {
            ForEach(entries.filter { $0.date?.dayOfWeek != .sunday }, id: \.date) { price in
                TurnipPriceCell(price: price)
            }.onDelete { indexes in
                withAnimation() { self.delete(indexes: indexes) }
            }
        }
    }
    
    func delete(indexes: IndexSet) {
        for index in indexes {
            let element = self.entries[index]
            self.context.delete(element)
        }
    }
}

struct PriceHistoryList_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
