//
//  AstronomicalCalendar.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/20/23.
//

import Foundation

/// A class used for non-religious astronomical times such as sunrise, sunset and twilight times.
///
/// There are times when the algorithms can't calculate proper values for sunrise, sunset and twilight. This is usually caused by trying to calculate times for areas either very far North or South, where sunrise / sunset never happen on that date. This is common when calculating twilight with a deep dip below the horizon for locations as far south of the North Pole as London, in the northern hemisphere. The sun never reaches this dip at certain times of the year. When the calculations encounter this condition, they will return `nil`. The reason that Errors are not thrown in these cases is because the lack of a rise/set or twilight is not an exception, but an expected condition in many parts of the world.
public class AstronomicalCalendar {
	///The ``GeoLocation`` used for calculations
    public let location: GeoLocation
	///The ``Date`` used for calculations
    public let date: Date
	///The internal ``AstronomicalCalculator`` used for calculating solar based times.
    public let astronomicalCalculator: AstronomicalCalculator
    
	
	/// Creates an ``AstronomicalCalendar`` using the given paramenters
	/// - Parameters:
	///   - location: The ``GeoLocation`` used for calculations
	///   - date: The ``Foundation/Date`` used for calculations
	///   - astronomicalCalculator: The internal ``AstronomicalCalculator`` used for calculating solar based times. Defaults to ``NOAACalculator``.
    public init(location: GeoLocation, date: Date, astronomicalCalculator: AstronomicalCalculator = NOAACalculator()) {
        self.location = location
        self.date = date
        self.astronomicalCalculator = astronomicalCalculator
    }
    
	///A Date representing the elevation adjusted sunrise time.
	///
	///The ``AstronomicalCalculator``'s elevation adjustment is used to calculate sunrise
    public var sunrise: Date? {
        let ret = getUtcSunrise(zenith: Zenith.geometric.rawValue)
        
        return getDateFromTime(time: ret, isSunrise: true)
    }
    
    public var seaLevelSunrise: Date? {
        let ret = getUtcSeaLevelSunrise(zenith: Zenith.geometric)
        return getDateFromTime(time: ret, isSunrise: true)
    }
    
    public var civilTwilightStart: Date? {
        getSunriseOffsetByDegrees(offset: Zenith.civil.rawValue)
    }
    
    public var nauticalTwilightStart: Date? {
        getSunriseOffsetByDegrees(offset: Zenith.nautical.rawValue)
    }
    
    public var astronomicalTwilightStart: Date? {
        getSunriseOffsetByDegrees(offset: Zenith.astronomical.rawValue)
    }
    
    public var sunset: Date? {
        let ret = getUtcSunset(zenith: Zenith.geometric.rawValue)
        return getDateFromTime(time: ret, isSunrise: false)
    }
    
    public var seaLevelSunset: Date? {
        let ret = getUtcSeaLevelSunset(zenith: .geometric)
        return getDateFromTime(time: ret, isSunrise: false)
    }
    
    public var civilTwilightEnd: Date? {
        getSunsetOffsetByDegrees(offset: Zenith.civil.rawValue)
    }
    
    public var nauticalTwilightEnd: Date? {
        getSunsetOffsetByDegrees(offset: Zenith.nautical.rawValue)
    }
    
    public var astronomicalTwilightEnd: Date? {
        getSunsetOffsetByDegrees(offset: Zenith.astronomical.rawValue)
    }
    
    func getSunriseOffsetByDegrees(offset: Double) -> Date? {
        let ret = getUtcSunrise(zenith: offset)
        return getDateFromTime(time: ret, isSunrise: true)
    }
    
    func getSunriseOffsetByDegrees(offsetZenith: Zenith) -> Date? {
        getSunriseOffsetByDegrees(offset: offsetZenith.rawValue)
    }
    
    func getSunsetOffsetByDegrees(offset: Double) -> Date? {
        let ret = getUtcSunset(zenith: offset)
        return getDateFromTime(time: ret, isSunrise: false)
    }
    
    func getSunsetOffsetByDegrees(offsetZenith: Zenith) -> Date? {
        getSunsetOffsetByDegrees(offset: offsetZenith.rawValue)
    }
    
    public var adjustedDate: Date? {
        let offset = location.antimeridianAdjustment
        if offset == 0 {
            return date
        }
        
        return Calendar.current.date(byAdding: .day, value: 1, to: date)
    }
    
    func getUtcSunrise(zenith: Double) -> Double? {
        guard let adjustedDate else { return nil }
        return astronomicalCalculator.getUtcSunrise(date: adjustedDate, location: location, zenith: zenith, adjustForElevation: true)
    }
    
    func getUtcSeaLevelSunrise(zenith: Zenith) -> Double? {
        guard let adjustedDate else { return nil }
        return astronomicalCalculator.getUtcSunrise(date: adjustedDate, location: location, zenith: zenith.rawValue, adjustForElevation: false)
    }
    
    func getUtcSunset(zenith: Double) -> Double? {
        guard let adjustedDate else { return nil }
        return astronomicalCalculator.getUtcSunset(date: adjustedDate, location: location, zenith: zenith, adjustForElevation: true)
    }
    
    func getUtcSeaLevelSunset(zenith: Zenith) -> Double? {
        guard let adjustedDate else { return nil }
        return astronomicalCalculator.getUtcSunset(date: adjustedDate, location: location, zenith: zenith.rawValue, adjustForElevation: false)
    }
    
    func getTemporalHour(dayStart: Date? = nil, dayEnd: Date? = nil) -> Double? {
        let start = dayStart ?? seaLevelSunrise
        let end = dayEnd ?? seaLevelSunset
        
        guard let start = start, let end = end else { return nil }
        
        return Double((end.millisecondsSince1970 - start.millisecondsSince1970) / 12)
    }
    
    func getSunTransit(dayStart: Date? = nil, dayEnd: Date? = nil) -> Date? {
        let start = dayStart ?? seaLevelSunrise
        let end = dayEnd ?? seaLevelSunset
        
        guard let start = start, let end = end else { return nil }
        
        let temporalHour = getTemporalHour(dayStart: start, dayEnd: end)
        guard let temporalHour = temporalHour else { return nil }
        
        return AstronomicalCalendar.getTimeOffset(time: start, offset: temporalHour * 6)
    }
    
    func getDateFromTime(time: Double?, isSunrise: Bool) -> Date? {
        guard let time = time else { return nil }
        
        var calculatedTime = time
        
        var gregorianCalendar =  Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = location.timezone
        
        var components = gregorianCalendar.dateComponents([.era,.year,.month,.weekOfYear,.day,.hour,.minute,.second], from: date)
        
        components.timeZone = TimeZone(identifier: "GMT")
        
        let hours = Int(calculatedTime)
        calculatedTime -= Double(hours)
        
        calculatedTime = calculatedTime * 60
        let minutes = Int(calculatedTime)
        calculatedTime -= Double(minutes)
        
        calculatedTime = calculatedTime * 60
        let seconds = Int(calculatedTime)
        calculatedTime -= Double(seconds)
        
        components.hour = hours
        components.minute = minutes
        components.second = seconds
        components.nanosecond = Int(calculatedTime * 1000 * 1000000)
        
        var returnDate = gregorianCalendar.date(from: components)
        
        let offsetFromGMT = Double(location.timezone.secondsFromGMT(for: date)/3600)
        
        if (time + offsetFromGMT > 24)
        {
            returnDate = returnDate?.addingTimeInterval(-86400)
        }
        else if (time + offsetFromGMT < 0)
        {
            returnDate = returnDate?.addingTimeInterval(86400)
        }
        
        return returnDate;
    }
    
    func getSunriseSolarDipFromOffset(minutes: Double) -> Double {
        var offsetByDegrees: Date? = seaLevelSunrise
        let offsetByTime = AstronomicalCalendar.getTimeOffset(time: seaLevelSunrise, offset: -(minutes * AstronomicalCalendar.minuteMillis))
        var degrees = 0.0
        let incrementor = 0.0001
        while offsetByDegrees == nil ||
                ((minutes < 0.0 && offsetByDegrees! < offsetByTime!) ||
                 (minutes > 0.0 && offsetByDegrees! > offsetByTime!)) {
            if minutes > 0.0 {
                degrees += incrementor
            } else {
                degrees -= incrementor
            }
            offsetByDegrees = getSunriseOffsetByDegrees(offset: Zenith.geometric.rawValue + degrees)
        }
        
        return degrees
    }
    
    func getSunsetSolarDipFromOffset(minutes: Double) -> Double {
        var offsetByDegrees: Date? = seaLevelSunset
        let offsetByTime = AstronomicalCalendar.getTimeOffset(time: seaLevelSunset, offset: minutes * AstronomicalCalendar.minuteMillis)
        var degrees = 0.0
        let incrementor = 0.001
        while offsetByDegrees == nil ||
                ((minutes > 0.0 && offsetByDegrees! < offsetByTime!) ||
                 (minutes < 0.0 && offsetByDegrees! > offsetByTime!)) {
            if minutes > 0.0 {
                degrees += incrementor
            } else {
                degrees -= incrementor
            }
            offsetByDegrees = getSunsetOffsetByDegrees(offset: Zenith.geometric.rawValue + degrees)
        }
        
        return degrees
    }
    
    public func getLocalMeanTime(hours: Double) -> Date? {
        AstronomicalCalendar.getTimeOffset(time: getDateFromTime(time: hours - Double(location.timezone.secondsFromGMT()) / AstronomicalCalendar.hourMillis, isSunrise: true), offset: -location.localMeanTimeOffset);
    }
}

extension AstronomicalCalendar {
    // Constants
    static let minuteMillis = 60 * 1000.0
    static let hourMillis = minuteMillis * 60
    
    static func getTimeOffset(time: Date?, offset: Double?) -> Date? {
//        guard let time = time, let offset = offset, offset != Double.leastNormalMagnitude else {
//            return nil
//        }
//        
//        return time + Double(offset) / 1000
        guard let time = time, let offset = offset else { return nil }
        return Date(timeInterval: TimeInterval(offset / 1000), since: time)
    }
    
}
