//
//  TurnipPriceAdder.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

public struct TurnipPriceAdder: View {
    @Environment(\.managedObjectContext) var context: NSManagedObjectContext
    
    @State var date: Date = Date()
    @State var price: String = ""
    @State var showPicker: Bool = false
    
    public var body: some View {
        VStack {
            HStack {
                TextField("Price", text: $price)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                if showPicker {
                    DatePicker(selection: $date, displayedComponents: [.date, .hourAndMinute]) {
                        Text("Tell me when...")
                    }
                } else {
                    Button(action: self.expandPicker) {
                        Text("\(date)")
                    }
                }
            }
            Button(action: self.add) {
                Text("Add!")
            }
        }
    }
    
    func add() {
        self.showPicker = false
        UIApplication.shared.endEditing()
        let turnip = TurnipPrice(context: context)
        guard let price = Int64(self.price) else {
            return
        }
        turnip.price = price
        turnip.date = self.date
        try? context.save()
    }
    
    func expandPicker() {
        UIApplication.shared.endEditing()
        withAnimation() {
            self.showPicker.toggle()
        }
    }
}

struct TurnipPriceAdder_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TurnipPriceCell(price: self.synthesize(entry: (Date(), 123)))
                .padding()
                .previewLayout(PreviewLayout.fixed(width: 300, height: 70))
            TurnipPriceAdder()
                .environment(\.managedObjectContext, DataModel.shared.persistentContainer.viewContext)
                .padding()
        }
    }
}
