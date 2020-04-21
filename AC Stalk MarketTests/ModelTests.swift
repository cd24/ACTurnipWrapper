//
//  ModelTests.swift
//  AC Stalk MarketTests
//
//  Created by John McAvey on 4/20/20.
//  Copyright © 2020 John McAvey. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble

@testable import AC_Stalk_Market

public class DayModelSpec: QuickSpec {
    public override func spec() {
        describe("Parsing") {
            let april20_2020_morning = date(from: [.year(2020), .month(4), .dayOfMonth(20), .hours(3)])!
            let morningEntry = TurnipUIEntry(price: 20, date: april20_2020_morning)
            let afternoonEntry = TurnipUIEntry(price: 30, date: april20_2020_morning.afternoon)
            it("handles empty sequences") {
                expect(days(from: [TurnipUIEntry]())).to(be([]))
            }
            it("maps morning entries"){
                expect(days(from: [morningEntry])).to(equal([DayModel(day: april20_2020_morning, morning: 20, afternoon: nil)]))
            }
            it("maps afternoon entries") {
                expect(days(from: [afternoonEntry])).to(equal([DayModel(day: afternoonEntry.date, morning: nil, afternoon: 30)]))
            }
            it("maps morning and afternoon entries") {
                let dayModel = DayModel(day: morningEntry.date, morning: morningEntry.price, afternoon: afternoonEntry.price)
                expect(days(from: [morningEntry, afternoonEntry])).to(equal([dayModel]))
            }
            it("takes dates in any order") {
                let dayModel = DayModel(day: morningEntry.date, morning: 20, afternoon: afternoonEntry.price)
                expect(days(from: [afternoonEntry, morningEntry])).to(equal([dayModel]))
            }
            it("returns multiple days") {
                let oneMorningLater = TurnipUIEntry(price: 40, date: morningEntry.date + .days(1))
                let oneAfternoonLater = TurnipUIEntry(price: 582, date: afternoonEntry.date + .days(1))
                let models = days(from: [morningEntry, afternoonEntry, oneMorningLater, oneAfternoonLater]).sorted { $0.day < $1.day }
                let answers = [
                    DayModel(day: morningEntry.date, morning: 20, afternoon: 30),
                    DayModel(day: oneMorningLater.date, morning: 40, afternoon: 582)
                ]
                expect(models.count).to(equal(answers.count))
                expect(models[0]).to(equal(answers[0]))
                expect(models[1]).to(equal(answers[1]))
            }
        }
    }
}

public class WeekModelSpec: QuickSpec {
    public override func spec() {
        describe("Parsing") {
            let april20_2020 = date(from: [.year(2020), .month(4), .dayOfMonth(20), .hours(3)])!
            let april18_2020 = date(from: [.year(2020), .month(4), .dayOfMonth(18), .hours(3)])!
            it("excludes entries from last week") {
                let week = newestWeek(from: [DayModel(day: april18_2020, morning: 20, afternoon: 10), DayModel(day: april20_2020, morning: 40, afternoon: 30)])
                expect(week?.monday?.day).to(equal(april20_2020))
                expect(week?.monday?.morning).to(equal(40))
                expect(week?.monday?.afternoon).to(equal(30))
                expect(week?.tuesday).to(beNil())
                expect(week?.wednesday).to(beNil())
                expect(week?.thursday).to(beNil())
                expect(week?.friday).to(beNil())
                expect(week?.saturday).to(beNil())
                expect(week?.sunday).to(beNil())
            }
        }
    }
}
