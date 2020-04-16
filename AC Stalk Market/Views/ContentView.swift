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
    let network = StalkNetwork()
    
    @State var reciever: AnyPublisher<String, Never> = Empty().eraseToAnyPublisher()
    @State var text: String = ""
    
    var body: some View {
        NavigationView {
            DetermineSaleView(predictor: StalkMarketWizard(network: StalkNetwork()))
        }
//        VStack {
//            SUIWebView(webView: network.web)
//                .onReceive(self.reciever) { value in
//                    print(value)
//            }
//            Button(action: self.rerun) { Text("rerun") }
//        }.onAppear() {
//            self.rerun()
//        }
    }
    
    func rerun() {
        let sampleWeek = WeekModel(monday: DayModel(day: Date(), morning: 2, afternoon: 3), tuesday: DayModel(day: Date(), morning: 100, afternoon: nil), wednesday: nil, thursday: nil, friday: nil, saturday: nil, sunday: nil)
        self.reciever = self.network.prediction(from: sampleWeek)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
