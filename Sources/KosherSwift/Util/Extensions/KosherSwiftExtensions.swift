//
//  DateExtensions.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/21/23.
//

import Foundation

infix operator ~/

public extension Int {    
    static func ~/ (lhs: Int, rhs: Int) -> Int {
        Int((Double(lhs) / Double(rhs)).rounded(.down))
    }
    
    static func ~/ (lhs: Int, rhs: Double) -> Int {
        Int((Double(lhs) / rhs).rounded(.down))
    }
    
    static func ~/ (lhs: Double, rhs: Int) -> Int {
        Int((lhs / Double(rhs)).rounded(.down))
    }
}

public extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }

    func getComponent(_ component: Calendar.Component) -> Int {
        Calendar.current.component(component, from: self)
    }
    
    init(year: Int, month: Int, day: Int, timezone: TimeZone? = nil) {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timezone ?? TimeZone.current
        let ret = cal.date(from: DateComponents(year: year, month: month, day: day))!
        self = ret
    }
    
    var year: Int { getComponent(.year) }
    var month: Int { getComponent(.month) }
    var day: Int { getComponent(.day) }
    var hour: Int { getComponent(.hour) }
    var minute: Int { getComponent(.minute) }
    var second: Int { getComponent(.second) }
    var weekday: Int { getComponent(.weekday) }
    var nanosecond: Int { getComponent(.nanosecond) }
    var timeZone: TimeZone? { Calendar.current.dateComponents([.timeZone], from: self).timeZone }
    var weekOfMonth: Int { getComponent(.weekOfMonth) }
    
    func withAdded(days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0, milliseconds: Int = 0, nanoseconds: Int = 0) -> Date? {
        guard var temp = Calendar.current.date(byAdding: .day, value: days, to: self) else { return nil }
        temp = Calendar.current.date(byAdding: .hour, value: hours, to: temp)!
        temp = Calendar.current.date(byAdding: .minute, value: minutes, to: temp)!
        temp = Calendar.current.date(byAdding: .second, value: seconds, to: temp)!
        temp = Calendar.current.date(byAdding: .nanosecond, value: milliseconds * 1000000, to: temp)!
        temp = Calendar.current.date(byAdding: .nanosecond, value: nanoseconds, to: temp)!
        temp = Calendar.current.date(byAdding: .nanosecond, value: nanoseconds, to: temp)!

        return temp
    }
    
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    func next(_ weekday: DayOfWeek) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        var nextDateComponent = calendar.dateComponents([.hour, .minute, .second], from: self)
        nextDateComponent.weekday = weekday.rawValue
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: .forward)
        
        return date!
    }
    
    func isBetween(start: Date, end: Date) -> Bool {
        start < self && end > self
    }
    
    func dateEquals(_ other: Date) -> Bool {
        year == other.year && day == other.day && month == other.month
    }
}

public extension TimeInterval {
    var inMilliseconds: Double { self * 1000 }
}
