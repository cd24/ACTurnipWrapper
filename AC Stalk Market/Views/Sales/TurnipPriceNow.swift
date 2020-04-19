//
//  TurnipPriceNow.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

public struct TurnipPriceNow: View {
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    @State var text: String = ""
    var showing: Binding<Bool>
    
    public var body: some View {
        VStack {
            Text("Hey! Can you tell me what the current price of your turnips is?")
                .lineLimit(nil)
                .padding(.bottom)
            TextField("Current Price", text: $text).keyboardType(.numberPad)
            HStack {
                Button(action: self.ignore) {
                    Text("Not now.")
                }
                Spacer()
                Button(action: self.add) {
                    Text("Add!")
                }
                .disabled(Int64(text) == nil)
            }
            Spacer()
        }
        .padding()
        .padding(.top, 10)
    }
    
    func add() {
        guard let price = Int64(text) else {
            return
        }
        let turnip = TurnipPrice(context: context)
        turnip.date = Date()
        turnip.price = price
        try! context.save()
        self.showing.wrappedValue = false
    }
    
    func ignore() {
        self.showing.wrappedValue = false
    }
}
