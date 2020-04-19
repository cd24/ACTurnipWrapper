//
//  Price+Helpers.swift
//  AC: Stalk Market Wizard
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import os.log

public enum TimeOfDay {
    case morning
    case afternoon
}

// The engine requires M-S
public enum DayOfWeek: Int {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var order: [DayOfWeek] {
        return [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}

extension Date {
    var timeOfDay: TimeOfDay {
        return Calendar.current.component(.hour, from: self) < 12 ? .morning : .afternoon
    }
    
    var dayOfWeek: DayOfWeek {
        let value = Calendar.current.component(.weekday, from: self)
        guard let day = DayOfWeek.init(rawValue: value) else {
            os_log(.fault, "Unable to convert weekday %{public}d to weekday", value)
            return .sunday
        }
        return day
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func daysFrom(other: Date) -> Int {
        let calendar = NSCalendar.current
        let d1 = calendar.startOfDay(for: self)
        let d2 = calendar.startOfDay(for: other)
        
        let dst = calendar.dateComponents([.day], from: d1, to: d2).day ?? 0
        return abs(dst)
    }
    
    func before(other: Date) -> Bool {
        return self < other
    }
}
