//
//  ShouldSellView.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import CoreData

let recommendationPredicate = NSPredicate { obj, data in
    guard let price = obj as? TurnipPrice else { return false }
    guard let date = price.date else { return false }
    let now = Date()
    return date < now && date.daysFrom(other: Date()) < 7 && date.dayOfWeek != .sunday
}

public struct TurnipUIEntry: TurnipPriceEntry {
    public let price: Int
    public let date: Date
    
    init(from: TurnipPrice) {
        self.price = Int(from.price)
        self.date = from.date ?? Date()
    }
}

public struct DetermineSaleView<P: TurnipPredictor>: View where P.Failure: UserPrintable {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)])
    var elements: FetchedResults<TurnipPrice>
    
    var predictor: P
    @State var prediction: TurnipPrediction<P.Failure> = .processing
    @State var popoverShowing: Bool = false
    
    public var body: some View {
        VStack {
            self.view(for: prediction).scaledToFit().padding()
            PriceHistoryList()
        }
        .navigationBarItems(trailing: Button(action: { self.popoverShowing = true }) { Image(systemName: "plus").padding() })
        .popover(isPresented: $popoverShowing) { TurnipPriceNow(showing: self.$popoverShowing) }
        .onReceive(self.predictor.predict(from: elements.lazy.map(TurnipUIEntry.init))) { prediction in
            self.prediction = prediction
        }
        .onAppear() {
            self.popoverShowing = self.predictor.needsNewValue(for: self.elements.lazy.map(TurnipUIEntry.init))
        }
    }
    
    func view(for prediction: TurnipPrediction<P.Failure>) -> some View {
        switch prediction {
        case .sell:
            return AnyView(ShouldSellView())
        default:
            return AnyView(ShouldHoldView())
        }
    }
}

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
        let turnip = TurnipPrice(entity: TurnipPrice.entity(), insertInto: DataModel.shared.persistentContainer.viewContext)
        turnip.date = Date()
        turnip.price = price
        DataModel.shared.saveContext()
        self.showing.wrappedValue = false
    }
    
    func ignore() {
        self.showing.wrappedValue = false
    }
}

struct BellIcon: View {
    var body: some View {
        Image("bell.icon").resizable()
    }
}

struct ShouldSellView: View {
    var body: some View {
        ZStack {
            VStack {
                BellIcon().scaledToFit()
                Text("You should sell right now!")
            }
        }.navigationBarTitle("Sell your turnips!")
    }
}

struct ShouldHoldView: View {
    var body: some View {
        ZStack {
            VStack {
                Text("You should hold right now")
            }
        }.navigationBarTitle("Hold your turnips!")
    }
}

extension Never: UserPrintable {
    public func userString() -> String {
        return "Something is really wrong."
    }
}

public struct StaticPredictor<Failure: Error>: TurnipPredictor {
    public let value: TurnipPrediction<Failure>
    public func predict<S>(from prices: S) -> AnyPublisher<TurnipPrediction<Failure>, Never> where S : Sequence, S.Element : TurnipPriceEntry {
        return Future { $0(.success(self.value))}.eraseToAnyPublisher()
    }
    public func needsNewValue<S>(for prices: S) -> Bool where S : Sequence, S.Element : TurnipPriceEntry { true }
}

struct DetermineSaleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DetermineSaleView(predictor: StaticPredictor<Never>(value: .processing))
            DetermineSaleView(predictor: StaticPredictor<Never>(value: .hold))
            DetermineSaleView(predictor: StaticPredictor<Never>(value: .sell))
        }
    }
}
