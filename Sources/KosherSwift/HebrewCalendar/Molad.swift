//
//  Molad.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/26/23.
//

import Foundation

public class MoladDate: JewishDateWrapper, JewishDateProtocol {
    public let molad: Molad
    var jewishDate: JewishDate
    
    init(fromMolad molad: Double) {
        self.molad = MoladDate.moladFromChalakim(chalakim: molad)
        let absDate = JewishDate.moladToAbsDate(chalakim: molad)
        self.jewishDate = JewishDate(date: JewishDate.absDateToDate(absDate: absDate))
    }
    
    init(chalakim: Double, date: Date) {
        self.molad = MoladDate.moladFromChalakim(chalakim: chalakim)
        self.jewishDate = JewishDate(date: date, includeTime: true)
    }
    
    convenience init(date: Date, hour: Int, minute: Int, chalakim: Int) {
        let molad = Molad(hours: hour, minutes: minute, chalakim: chalakim)
        self.init(date: date, molad: molad)
    }
    
    init(date: Date, molad: Molad) {
        self.molad = molad
        self.jewishDate = JewishDate(date: date, includeTime: true)
    }
    
    func withMoladHours(_ hours: Int) -> MoladDate {
        MoladDate(date: gregDate, hour: hours, minute: molad.minutes, chalakim: molad.chalakim)
    }
    
    static func calculate(forJewishDate jewishDate: JewishDate) -> MoladDate? {
        let m = JewishDate.getChalakimSinceMoladTohu(year: jewishDate.year, month: jewishDate.month)
        
        let absM = JewishDate.moladToAbsDate(chalakim: m)
        let gdate = JewishDate.absDateToDate(absDate: absM)
        
        let temp = moladFromChalakim(chalakim: m)
        let hours = (temp.hours + 18) % 24
        let retMolad = Molad(hours: hours, minutes: temp.minutes, chalakim: temp.chalakim)
        
        guard var dt = getMoladAsDate(retMolad, gdate) else { return nil }
        
        if temp.hours >= 6 {
            dt = dt.withAdded(days: 1)!
        }
        
        return MoladDate(date: dt, molad: retMolad)
    }
    
    private static func moladFromChalakim(chalakim: Double) -> Molad {
        let conjunctionDay = chalakim ~/ JewishDate.chalakimPerDay
        var adjustedChalakim = (chalakim - Double(conjunctionDay) * Double(JewishDate.chalakimPerDay))
        
        let hours = adjustedChalakim ~/ JewishDate.chalakimPerHour
        adjustedChalakim = adjustedChalakim - (Double(hours) * Double(JewishDate.chalakimPerHour))
        let minutes = adjustedChalakim ~/ JewishDate.chalakimPerMinute
        let chalakim = adjustedChalakim - Double(minutes * JewishDate.chalakimPerMinute)
        
        return Molad(hours: hours, minutes: minutes, chalakim: Int(chalakim))
    }
    
    
    static func getMoladAsDate(_ molad: Molad, _ mdate: Date) -> Date? {
        let moladHours = (molad.hours + 18) % 24
        let moladMinutes = molad.minutes - 20
        let moladSeconds = (Double(molad.chalakim) * 10 / 3 ) - 56.496
        
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = Calendar.current.timeZone
        let moladDay = DateComponents(calendar: calendar, year: mdate.year, month: mdate.month, day: mdate.day, hour: moladHours, minute: moladMinutes, second: Int(moladSeconds) - 1)
        
        return calendar.date(from: moladDay)
    }
}

public struct Molad {
    public let hours: Int
    public let minutes: Int
    public let chalakim: Int
}
