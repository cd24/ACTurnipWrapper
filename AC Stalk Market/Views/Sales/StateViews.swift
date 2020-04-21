//
//  ShouldHoldView.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import SwiftUI

struct ShouldSellView: View {
    var body: some View {
        Text("You should sell right now!")
            .navigationBarTitle("Sell your turnips!")
    }
}

struct ShouldHoldView: View {
    var body: some View {
        Text("You should hold right now")
            .navigationBarTitle("Hold your turnips!")
    }
}

struct ProcessingView: View {
    var body: some View {
        Text("Processing... I'm thinking about your options!")
            .navigationBarTitle("Processing...")
    }
}
