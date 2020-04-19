//
//  FetchWrapper.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/19/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

public struct FetchWrapper<T: View>: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(fetchRequest: TurnipPrice.sortedFetch)
    var elements: FetchedResults<TurnipPrice>
    
    var wrapped: (FetchedResults<TurnipPrice>) -> T
    
    public var body: some View {
        wrapped(elements).environment(\.managedObjectContext, context)
    }
}
