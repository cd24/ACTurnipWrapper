//
//  PredictionWrapper.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import Combine

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
