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
    
    var afternoon: Date {
        return Calendar.current.date(byAdding: .hour, value: 13, to: self.startOfDay)!
    }
    
    var startOfWeek: Date? {
        let calendar = Calendar.current
        guard let monday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return monday
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

enum CalendarValue {
    case year(Int)
    case yearForWeekOfYear(Int)
    case weekOfYear(Int)
    case month(Int)
    case dayOfMonth(Int)
    case days(Int)
    case hours(Int)
    case minutes(Int)
    case seconds(Int)
    
    func calendarComponent() -> Calendar.Component {
        switch self {
        case .year(_):
            return .year
        case .yearForWeekOfYear(_):
            return .yearForWeekOfYear
        case .month(_):
            return .month
        case .dayOfMonth(_):
            return .day
        case .weekOfYear(_):
            return .weekOfYear
        case .days(_):
            return .day
        case .hours(_):
            return .hour
        case .minutes(_):
            return .minute
        case .seconds(_):
            return .second
        }
    }
    
    func value() -> Int {
        switch self {
        case .year(let value):
            return value
        case .yearForWeekOfYear(let value):
            return value
        case .dayOfMonth(let value):
            return value
        case .weekOfYear(let value):
            return value
        case .month(let value):
            return value
        case .days(let value):
            return value
        case .hours(let value):
            return value
        case .minutes(let value):
            return value
        case .seconds(let value):
            return value
        }
    }
    
    func assignTo(_ components: DateComponents) -> DateComponents {
        var mutable = components
        switch self {
        case .year(let value):
            mutable.year = value
        case .yearForWeekOfYear(let value):
            mutable.yearForWeekOfYear = value
        case .dayOfMonth(let value):
            mutable.day = value
        case .weekOfYear(let value):
            mutable.weekOfYear = value
        case .month(let value):
            mutable.month = value
        case .days(let value):
            mutable.day = value
        case .hours(let value):
            mutable.hour = value
        case .minutes(let value):
            mutable.minute = value
        case .seconds(let value):
            mutable.second = value
        }
        return mutable
    }
}

func +(lhs: Date, rhs: CalendarValue) -> Date {
    return Calendar.current.date(byAdding: rhs.calendarComponent(), value: rhs.value(), to: lhs)!
}

func date(from: [CalendarValue]) -> Date? {
    let components = from.reduce(DateComponents()) { components, value in value.assignTo(components) }
    return Calendar.current.date(from: components)
}
