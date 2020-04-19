//
//  ContentView.swift
//  AC: Stalk Market Wizard
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import SwiftUI
import Combine

struct ContentLanding: View {
    let prediction: TurnipPrediction<Error>
    
    var body: some View {
        VStack(alignment: .leading) {
            PredictionPresenter(prediction: prediction).padding()
            PriceHistoryList()
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var context
    @State var text: String = ""
    let wizard = StalkMarketWizard(network: KBStalkNetwork(), parser: KBNetworkParser())
    
    var body: some View {
        NavigationView {
            FetchWrapper { elements in
                PredictionWrapper(prices: elements, predictor: self.wizard) { prediction in
                    ContentLanding(prediction: prediction).environment(\.managedObjectContext, self.context)
                }
            }
            .environment(\.managedObjectContext, DataModel.shared.persistentContainer.viewContext)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
