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

public struct PredictionPresenter<PE: Error>: View {
    @Environment(\.managedObjectContext) var context
    var prediction: TurnipPrediction<PE> = .processing
    
    public var body: some View {
        VStack {
            if prediction.shouldSell() {
                ShouldSellView()
            } else if prediction.shouldHold() {
                ShouldHoldView()
            } else if prediction.processing() {
                ProcessingView()
            }
        }
    }
}

struct PredictionPresenter_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Text("TODO")
        }
    }
}
