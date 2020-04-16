//
//  SwiftUIPreviews+PreviewData.swift
//  AC: Stalk Market Wizard
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI
import UIKit

extension PreviewProvider {
    static func syntheticManagedContext() -> NSManagedObjectContext {
        return DataModel.shared.persistentContainer.viewContext
    }
    
    @discardableResult
    static func synthesize(entry: (Date, Int64)) -> TurnipPrice {
        let price = TurnipPrice(context: self.syntheticManagedContext())
        price.date = entry.0
        price.price = entry.1
        return price
    }
    
    static func standardSyntheticData() {
        self.synthesize(entry: (Date().addingTimeInterval((60 * 60 * 24) * -1), 125))
        self.synthesize(entry: (Date().addingTimeInterval((60 * 60 * 24) * -2), 100))
        self.synthesize(entry: (Date().addingTimeInterval((60 * 60 * 24) * -3), 90))
    }
}
