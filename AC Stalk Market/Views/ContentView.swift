//
//  ContentView.swift
//  AC: Stalk Market Wizard
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State var text: String = ""
    let wizard = StalkMarketWizard(network: StalkNetwork())
    
    var body: some View {
        NavigationView {
            FetchWrapper<PredictionWrapper<DetermineSaleView<StalkMarketWizard>, StalkMarketWizard>> { elements in
                PredictionWrapper(prices: elements, predictor: self.wizard) { prediction in
                    DetermineSaleView(prediction: prediction)
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
