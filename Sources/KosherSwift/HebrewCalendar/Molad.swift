//
//  Molad.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/26/23.
//

import Foundation

public class MoladDate: JewishDate {
    public let molad: Molad
    
    init(fromMolad molad: Double) {
        self.molad = MoladDate.moladFromChalakim(chalakim: molad)
        let absDate = JewishDate.moladToAbsDate(chalakim: molad)
        
        super.init(date: JewishDate.absDateToDate(absDate: absDate))
    }
    
    init(chalakim: Double, date: Date) {
        self.molad = MoladDate.moladFromChalakim(chalakim: chalakim)
        super.init(dateWithTime: date)
    }
    
    convenience init(date: Date, hour: Int, minute: Int, chalakim: Int) {
        let molad = Molad(hours: hour, minutes: minute, chalakim: chalakim)
        self.init(date: date, molad: molad)
    }
    
    init(date: Date, molad: Molad) {
        self.molad = molad
        super.init(dateWithTime: date)
    }
    
    func withMoladHours(_ hours: Int) -> MoladDate {
        MoladDate(date: gregDate, hour: hours, minute: molad.minutes, chalakim: molad.chalakim)
    }
    
    static func calculate(forJewishDate jewishDate: JewishDate) -> MoladDate {
        let m = getChalakimSinceMoladTohu(year: jewishDate.year, month: jewishDate.month)
        
        let absM = moladToAbsDate(chalakim: m)
        let gdate = absDateToDate(absDate: absM)
        
        let temp = moladFromChalakim(chalakim: m)
        let hours = (temp.hours + 18) % 24
        let retMolad = Molad(hours: hours, minutes: temp.minutes, chalakim: temp.chalakim)
        
        var dt = getMoladAsDate(retMolad, gdate)
        
        if temp.hours >= 6 {
            dt = dt.withAdded(days: 1)!
        }
        
        return MoladDate(date: dt, molad: retMolad)
    }
    
    private static func moladFromChalakim(chalakim: Double) -> Molad {
        let conjunctionDay = chalakim ~/ JewishCalendar.chalakimPerDay
        var adjustedChalakim = (chalakim - Double(conjunctionDay) * Double(chalakimPerDay))
        
        let hours = adjustedChalakim ~/ chalakimPerHour
        adjustedChalakim = adjustedChalakim - (Double(hours) * Double(chalakimPerHour))
        let minutes = adjustedChalakim ~/ chalakimPerMinute
        let chalakim = adjustedChalakim - Double(minutes * chalakimPerMinute)
        
        return Molad(hours: hours, minutes: minutes, chalakim: Int(chalakim))
    }
    
    
    static func getMoladAsDate(_ molad: Molad, _ mdate: Date) -> Date {
        let locationName = "Jerusalem, Israel"
        let latitude = 31.778 // Har Habayis latitude
        let longitude = 35.2354 // Har Habayis longitude
        // The raw molad Date (point in time) must be generated using standard time. Using "Asia/Jerusalem" timezone will result in the time
        // being incorrectly off by an hour in the summer due to DST. Proper adjustment for the actual time in DST will be done by the date
        // formatter class used to display the Date.
        let year = String(Calendar.current.component(.year, from: Date()))
        let month = String(format: "%02d", Calendar.current.component(.month, from: mdate))
        let day = String(format: "%02d", Calendar.current.component(.day, from: mdate))
        let hour = String(format: "%02d", Calendar.current.component(.hour, from: mdate))
        let minute = String(format: "%02d", Calendar.current.component(.minute, from: mdate))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateTime = dateFormatter.date(from: "\(year)-\(month)-\(day) \(hour):\(minute)")!
        let geo = GeoLocation(lat: latitude, lng: longitude, name: locationName)
        let moladSeconds = Double(molad.chalakim) * 10 / 3
        var cal = Calendar.current.date(bySettingHour: molad.hours, minute: molad.minutes, second: Int(moladSeconds), of: dateTime)!

        // subtract local time difference of 20.94 minutes (20 minutes and 56.496 seconds) to get to Standard time
        cal.addTimeInterval(-1 * geo.localMeanTimeOffsetWithMillis * 0.001)
        return cal
    }
}

public struct Molad {
    public let hours: Int
    public let minutes: Int
    public let chalakim: Int
}
