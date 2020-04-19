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

extension TurnipPrice {
    static var sortedFetch: NSFetchRequest<TurnipPrice> {
        let request: NSFetchRequest<TurnipPrice> = TurnipPrice.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return request
    }
}

public struct FetchWrapper<T: View>: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(fetchRequest: TurnipPrice.sortedFetch)
    var elements: FetchedResults<TurnipPrice>
    
    var wrapped: (FetchedResults<TurnipPrice>) -> T
    
    public var body: some View {
        wrapped(elements).environment(\.managedObjectContext, context)
    }
}

public struct PredictionWrapper<T: View, P: TurnipPredictor>: View {
    @Environment(\.managedObjectContext) var context
    
    let prices: FetchedResults<TurnipPrice>
    let predictor: P
    
    @State var predictions: AnyPublisher<TurnipPrediction<P.Failure>, Never> = Empty().eraseToAnyPublisher()
    @State var prediction: TurnipPrediction<P.Failure> = .processing
    @State var popoverShowing: Bool = false
    
    var wrapped: (TurnipPrediction<P.Failure>) -> T
    
    public var body: some View {
        wrapped(prediction)
            .environment(\.managedObjectContext, context)
            .onReceive(predictions) { self.prediction = $0 }
            .onAppear() {
                self.popoverShowing = self.predictor.needsNewValue(for: self.turnipUIEntries())
                self.predictions = self.predictor.predict(from: self.turnipUIEntries())
            }
            .popover(isPresented: $popoverShowing) {
                TurnipPriceNow(showing: self.$popoverShowing)
                    .environment(\.managedObjectContext, self.context)
            }
            .navigationBarItems(trailing: Button(action: { self.popoverShowing = true }) { Image(systemName: "plus").padding() })
    }
    
    func turnipUIEntries() -> [TurnipUIEntry] {
        return self.prices.lazy.map(TurnipUIEntry.init)
    }
}

public struct DetermineSaleView<P: TurnipPredictor>: View {
    @Environment(\.managedObjectContext) var context
    var prediction: TurnipPrediction<P.Failure> = .processing
    
    public var body: some View {
        VStack {
            if prediction.shouldSell() {
                ShouldSellView()
            } else if prediction.shouldHold() {
                ShouldHoldView()
            } else if prediction.processing() {
                ProcessingView()
            }
            PriceHistoryList().environment(\.managedObjectContext, context)
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

struct ProcessingView: View {
    var body: some View {
        Text("Processing... I'm thinking about your options!")
            .navigationBarTitle("Processing...")
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
            Text("TODO")
        }
    }
}
