//
//  TurnipPriceCell.swift
//  AC: Stalk Market Wizard
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import SwiftUI

public struct TurnipPriceCell: View {
    public let price: TurnipPrice
    
    public var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(self.turnipPriceDescription()).font(.title)
                if price.date != nil {
                    Text(self.dateDescription()).font(.body)
                } else {
                    Spacer()
                }
            }
            Spacer()
        }
    }
    
    func turnipPriceDescription() -> String {
        return "\(self.price.price) Bells"
    }
    
    func dateDescription() -> String {
        return self.formatter.string(from: self.price.date!)
    }
}

struct TurnipPriceCell_Previews: PreviewProvider {
    static var previews: some View {
        let price = self.synthesize(entry: (Date(), 123))
        return TurnipPriceCell(price: price)
    }
}
