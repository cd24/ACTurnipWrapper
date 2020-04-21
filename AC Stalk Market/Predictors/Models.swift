//
//  WeekWebModel.swift
//  AC Stalk Market
//
//  Created by John McAvey on 4/14/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation

public struct DayModel: Equatable {
    public let day: Date
    public let morning: Int?
    public let afternoon: Int?
}

public struct WeekModel: Equatable {
    public let monday: DayModel?
    public let tuesday: DayModel?
    public let wednesday: DayModel?
    public let thursday: DayModel?
    public let friday: DayModel?
    public let saturday: DayModel?
    public let sunday: DayModel?
}

public func days<S: Sequence>(from prices: S) -> [DayModel] where S.Element: TurnipPriceEntry {
    let v = Dictionary(grouping: prices, by: \.date.startOfDay).map { _, group in group.sorted { $0.price < $1.price } }
    let p1 = v.lazy.map { group -> (morning: TurnipPriceEntry?, afternoon: TurnipPriceEntry?) in
        let mn = group.lazy.filter { $0.date.timeOfDay == .morning }.first
        let af = group.lazy.filter { $0.date.timeOfDay == .afternoon }.first
        return (morning: mn, afternoon: af)
    }
    let snd = p1.map { (o: (morning: TurnipPriceEntry?, afternoon: TurnipPriceEntry?)) in (day: o.morning?.date ?? o.afternoon?.date, times: o) }
    let values: [DayModel] = snd.lazy.compactMap { values in
        guard let dow = values.day else {
            return nil
        }
        return DayModel(day: dow, morning: values.times.morning?.price, afternoon: values.times.afternoon?.price)
    }
    return values
}

extension Array where Element == DayModel {
    func first(_ week: DayOfWeek) -> DayModel? {
        return self.filter() { $0.day.dayOfWeek == week }.first
    }
}

public func newestWeek(from days: [DayModel]) -> WeekModel? {
    guard let oneWeekAgo = Date().startOfWeek else {
        return nil
    }
    let releventDays = days.filter { $0.day > oneWeekAgo }.sorted { $0.day > $1.day }
    return WeekModel(monday: releventDays.first(.monday),
                     tuesday: releventDays.first(.tuesday),
                     wednesday: releventDays.first(.wednesday),
                     thursday: releventDays.first(.thursday),
                     friday: releventDays.first(.friday),
                     saturday: releventDays.first(.saturday),
                     sunday: releventDays.first(.sunday))
}

extension WeekModel {
    func dayModel(for day: DayOfWeek) -> DayModel? {
        switch day {
        case .monday:
            return self.monday
        case .tuesday:
            return self.tuesday
        case .wednesday:
            return self.wednesday
        case .thursday:
            return self.thursday
        case .friday:
            return self.friday
        case .saturday:
            return self.saturday
        case .sunday:
            return self.sunday
        }
    }
}
