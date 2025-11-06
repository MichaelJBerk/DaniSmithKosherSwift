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
	///The Date used for calculations
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
    
	///Elevation-adjusted sunrise time.
	///
	///The ``AstronomicalCalculator``'s elevation adjustment is used to calculate sunrise.
    public var sunrise: Date? {
        let ret = getUtcSunrise(zenith: Zenith.geometric.rawValue)
        
        return getDateFromTime(time: ret, isSunrise: true)
    }
    ///Sunrise without elevation adjustment
    public var seaLevelSunrise: Date? {
        let ret = getUtcSeaLevelSunrise(zenith: Zenith.geometric)
        return getDateFromTime(time: ret, isSunrise: true)
    }
	///The beginning of [civil twilight](https://en.wikipedia.org/wiki/Twilight#Civil_twilight) using a zenith of 96°
	///
	///See details on ``AstronomicalCalendar`` for when this can return `nil`
    public var civilTwilightStart: Date? {
        getSunriseOffsetByDegrees(offset: Zenith.civil.rawValue)
    }
    
	///The beginning of [nautical twilight](https://en.wikipedia.org/wiki/Twilight#Nautical_twilight) using a zenith of 102°
	///
	///See details on ``AstronomicalCalendar`` for when this can return `nil`
    public var nauticalTwilightStart: Date? {
        getSunriseOffsetByDegrees(offset: Zenith.nautical.rawValue)
    }
    
	///The beginning of [astronomical twilight](https://en.wikipedia.org/wiki/Twilight#Astronomical_twilight) using a zenith of 108°
	///
	///See details on ``AstronomicalCalendar`` for when this can return `nil`
    public var astronomicalTwilightStart: Date? {
        getSunriseOffsetByDegrees(offset: Zenith.astronomical.rawValue)
    }
    
	///The elevation-adjusted sunset time
	///
	///
	/// If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not set, this will return `nil`. See details on ``AstronomicalCalendar`` for more information.
	///
	///The zenith used for the calculation uses geometric zenith of 90° plus ``AstronomicalCalculator/getElevationAdjustment(_:)``. This is adjusted by the ``AstronomicalCalculator`` to add approximately 50/60 of a degree to account for 34 archminutes of refraction and 16 archminutes for the sun's radius for a total of 90.83333°. See documentation for the specific implementation of the AstronomicalCalculator that you are using.
	///> Note: In certain cases the calculates sunset will occur before sunrise. This will typically happen when a timezone other than the local timezone is used (calculating Los Angeles sunset using a GMT timezone for example). In this case the sunset date will be incremented to the following date.
    public var sunset: Date? {
        let ret = getUtcSunset(zenith: Zenith.geometric.rawValue)
        return getDateFromTime(time: ret, isSunrise: false)
    }
    
	///Sunset time without elevation adjustment
	///
	/// If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not set, this will return `nil`. See details on ``AstronomicalCalendar`` for more information.
	///
	/// Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible light, something that is not affected by elevation. This method returns sunset calculated at sea level. This forms the base for dusk calculations that are calculated as a dip below the horizon after sunset.
    public var seaLevelSunset: Date? {
        let ret = getUtcSeaLevelSunset(zenith: .geometric)
        return getDateFromTime(time: ret, isSunrise: false)
    }
    
	///The end of [civil twilight](https://en.wikipedia.org/wiki/Twilight#Civil_twilight) using a zenith of 96°.
	///
	///See details on ``AstronomicalCalendar`` for when this can return `nil`
    public var civilTwilightEnd: Date? {
        getSunsetOffsetByDegrees(offset: Zenith.civil.rawValue)
    }
    
	///The end of [nautical twilight](https://en.wikipedia.org/wiki/Twilight#Nautical_twilight) using a zenith of 102°.
	///
	///See details on ``AstronomicalCalendar`` for when this can return `nil`
    public var nauticalTwilightEnd: Date? {
        getSunsetOffsetByDegrees(offset: Zenith.nautical.rawValue)
    }
    
	///The end of [astronomical twilight](https://en.wikipedia.org/wiki/Twilight#Astronomical_twilight) using a zenith of 108°
	///
	///See details on ``AstronomicalCalendar`` for when this can return `nil`
    public var astronomicalTwilightEnd: Date? {
        getSunsetOffsetByDegrees(offset: Zenith.astronomical.rawValue)
    }
    
	///A utility method that returns the time of an offset by degrees below or above the horizon of ``sunrise``.
	///
	///Note that the degree offset is from the vertical, so for a calculation of 14° before `sunrise`, an offset of 14 + ``Zenith/geometric`` = 104 would have to be passed as a parameter.
	///
	///- Parameter offset: the degrees after ``sunrise`` to use in the calculation. For time after sunrise use negative numbers
	///- Returns: The Date of the offset after (or before) ``sunset``. If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not set, this will return `nil`. See details on ``AstronomicalCalendar`` for more information.
    public func getSunriseOffsetByDegrees(offset: Double) -> Date? {
        let ret = getUtcSunrise(zenith: offset)
        return getDateFromTime(time: ret, isSunrise: true)
    }
    
	///A utility method that returns the time of an offset by a Zenith below or above the horizon of sunrise.
	///
	///- Parameter offsetZenith: A Zenith representing the offset to use in the calculation.
	///See ``AstronomicalCalendar/getSunriseOffsetByDegrees(offset:)`` for more information
    func getSunriseOffsetByDegrees(offsetZenith: Zenith) -> Date? {
        getSunriseOffsetByDegrees(offset: offsetZenith.rawValue)
    }
	
	///A utility method that returns the time of an offset by degrees below or above the horizon of sunset.
	///
	/// Note that the degree offset is from the vertical, so for a calculation of 14° after sunset, an offset of 14 + ``Zenith/geometric`` = 104 would have to be passed as a parameter.
	///- Parameter offset: the degrees after ``sunset`` to use in the calculation. For time before sunset, use negative numbers.
	///- Returns: The Date of the offset after (or before) ``sunset``. If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not set, this will return `nil`. See details on ``AstronomicalCalendar`` for more information.
    public func getSunsetOffsetByDegrees(offset: Double) -> Date? {
        let ret = getUtcSunset(zenith: offset)
        return getDateFromTime(time: ret, isSunrise: false)
    }
    
	///A utility method that returns the time of an offset by a Zenith below or above the horizon of sunset.
	///
	///- Parameter offsetZenith: A Zenith representing the offset to use in the calculation.
	///See ``AstronomicalCalendar/getSunsetOffsetByDegrees(offset:)`` for more information
    func getSunsetOffsetByDegrees(offsetZenith: Zenith) -> Date? {
        getSunsetOffsetByDegrees(offset: offsetZenith.rawValue)
    }
	
    ///The ``date``, adjusted to deal with edge cases where the location crosses the antimeridian.
    public var adjustedDate: Date? {
        let offset = location.antimeridianAdjustment
        if offset == 0 {
            return date
        }
        
        return Calendar.current.date(byAdding: .day, value: 1, to: date)
    }
    
	///A method that returns the sunrise in UTC time without correction for time zone offset from GMT and without using daylight savings time.
	///
	///- Parameter zenith: the degrees below the horizon. For time after sunrise use negative numbers.
	///- Returns: The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not set, this will return `nil`. See details on ``AstronomicalCalendar`` for more information.
    public func getUtcSunrise(zenith: Double) -> Double? {
        guard let adjustedDate else { return nil }
        return astronomicalCalculator.getUtcSunrise(date: adjustedDate, location: location, zenith: zenith, adjustForElevation: true)
    }
	
	///A method that returns the sunrise in UTC time without correction for time zone offset from GMT and without using daylight savings time.
	///
	///Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible light, something that is not affected by elevation. This method returns UTC sunrise calculated at sea level. This forms the base for dawn calculations that are calculated as a dip below the horizon before sunrise. For time after sunrise use negative numbers.
	///
	///- Parameter zenith: the degrees below the horizon
	///
	///- Returns: The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not set, this will return `nil`. See details on ``AstronomicalCalendar`` for more information.
	public func getUtcSeaLevelSunrise(zenith: Double) -> Double? {
		guard let adjustedDate else { return nil }
		return astronomicalCalculator.getUtcSunrise(date: adjustedDate, location: location, zenith: zenith, adjustForElevation: false)
	}
	
	///A method that returns the sunrise in UTC time without correction for time zone offset from GMT and without using daylight savings time.
	///
	///- Parameter zenith: the degrees below the horizon
	///
	///See ``getUtcSeaLevelSunrise(zenith:)`` for more information
    func getUtcSeaLevelSunrise(zenith: Zenith) -> Double? {
		return getUtcSeaLevelSunrise(zenith: zenith.rawValue)
    }
    
	///A method that returns the sunset in UTC time without correction for time zone offset from GMT and without using daylight savings time.
	///- Parameter zenith: the degrees below the horizon. For time after sunset use negative numbers.
	///
	///- Returns: The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not set, this will return `nil`. See details on ``AstronomicalCalendar`` for more information.
    func getUtcSunset(zenith: Double) -> Double? {
        guard let adjustedDate else { return nil }
        return astronomicalCalculator.getUtcSunset(date: adjustedDate, location: location, zenith: zenith, adjustForElevation: true)
    }
    
	///A method that returns the sunset in UTC time without correction for elevation, time zone offset from GMT and without using daylight savings time
	///
	/// Non-sunrise and sunset calculations such as dawn and dusk, depend on the amount of visible light, something that is not affected by elevation. This method returns UTC sunset calculated at sea level. This forms the base for dusk calculations that are calculated as a dip below the horizon after sunset.
	/// - Parameter zenith: the degrees below the horizon. For time before sunset use negative numbers.
	///- Returns: The time in the format: 18.75 for 18:45:00 UTC/GMT. If the calculation can't be computed such as in the Arctic Circle where there is at least one day a year where the sun does not rise, and one where it does not set, this will return `nil`. See details on ``AstronomicalCalendar`` for more information.
	public func getUtcSeaLevelSunset(zenith: Double) -> Double? {
		guard let adjustedDate else { return nil }
		return astronomicalCalculator.getUtcSunset(date: adjustedDate, location: location, zenith: zenith, adjustForElevation: false)
	}
	
	///A method that returns the sunset in UTC time without correction for elevation, time zone offset from GMT and without using daylight savings time
	///
	/// - Parameter zenith: the degrees below the horizon. For time before sunset use negative numbers.
	/// See ``getUtcSeaLevelSunset(zenith:)`` for more information
    func getUtcSeaLevelSunset(zenith: Zenith) -> Double? {
		getUtcSeaLevelSunset(zenith: zenith.rawValue)
    }
    
	///A method that calculates a temporal (solar) hour based on the sunrise and sunset passed as parameters.
	///
	///If no parameters are passed, the method defaults to using ``seaLevelSunrise`` and ``seaLevelSunset``.
	///An example of the use of this method would be the calculation of a elevation adjusted temporal hour by passing in sunrise and sunset as parameters.
	///> Tip: The day from sea-level sunrise to sea-level sunset is split into 12 equal parts with each one being a temporal hour.
	///
	///- Parameter dayStart: The start of the day. Defaults to ``seaLevelSunrise``
	///- Parameter dayEnd: The end of the day. Defaults to ``seaLevelSunset``
	///- Returns: the millisecond length of a temporal hour. If the calculation can't be computed, `nil` will be returned. See details on ``AstronomicalCalendar`` for more information.
    func getTemporalHour(dayStart: Date? = nil, dayEnd: Date? = nil) -> Double? {
        let start = dayStart ?? seaLevelSunrise
        let end = dayEnd ?? seaLevelSunset
        
        guard let start = start, let end = end else { return nil }
        
        return Double((end.millisecondsSince1970 - start.millisecondsSince1970) / 12)
    }
    
	/// A method that returns sundial or solar noon.
	///
	/// Sundial, or solar noon, occurs when the Sun is [transiting](https://en.wikipedia.org/wiki/Transit_%28astronomy%29) the [celestial meridian](https://en.wikipedia.org/wiki/Meridian_%28astronomy%29).
	/// The calculations used by this class depend on the ``AstronomicalCalculator`` used. If this calendar instance is set to use the ``NOAACalculator`` (the default) it will calculate astronomical noon. See [The Definition of Chatzos](https://kosherjava.com/2020/07/02/definition-of-chatzos/) for details on the proper definition of solar noon / midday.
	///
	/// This time can be slightly off the real transit time due to changes in declination (the lengthening or shortening day).
	///
	/// If no parameters are passed, the method defaults to using ``seaLevelSunrise`` and ``seaLevelSunset``.
	///
	/// - Parameters:
	///   - dayStart: the start of day for calculating the sun's transit. This can be sea level sunrise, visual sunrise (or any arbitrary start of day) passed to this method. Defaults to ``seaLevelSunrise``
	///   - dayEnd: the end of day for calculating the sun's transit. This can be sea level sunset, visual sunset (or any arbitrary end of day) passed to this method. Defaults to ``seaLevelSunset``
	/// - Returns: the Date representing Sun's transit.  If the calculation can't be computed,  `nil` will be returned. See details on ``AstronomicalCalendar`` for more information.
    func getSunTransit(dayStart: Date? = nil, dayEnd: Date? = nil) -> Date? {
        let start = dayStart ?? seaLevelSunrise
        let end = dayEnd ?? seaLevelSunset
        
        guard let start = start, let end = end else { return nil }
        
        let temporalHour = getTemporalHour(dayStart: start, dayEnd: end)
        guard let temporalHour = temporalHour else { return nil }
        
        return AstronomicalCalendar.getTimeOffset(time: start, offset: temporalHour * 6)
    }
    
	/// A method that returns a Date from the time passed in as a parameter.
	/// 
	/// 
	/// - Parameters:
	///   - time: The time to be set as the time for the Date. time is sunrise and false if it is sunset
	///   - isSunrise: `true` if the date being calculated is relating to Sunrise, `false` if it is not.
	/// - Returns: The Date representation of the time double
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
	
    ///Returns the dip below the horizon before sunrise that matches the offset minutes on passed in as a parameter
	///
	///For exampl,e passing in 72 minutes for a calendar set to the equinox in Jerusalem returns a value close to 16.1°
	///- Warning: Please note that this method is very slow and inefficient and should NEVER be used in a loop.
	///- Parameter minutes: offset
	///- Returns: The degrees below the horizon before sunrise that match the offset in minutes passed it as a parameter.
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
    ///Returns the dip below the horizon after sunset that matches the offset minutes on passed in as a parameter.
	///
	///For example passing in 72 minutes for a calendar set to the equinox in Jerusalem returns a value close to 16.1°
	///- Warning: Please note that this method is very slow and inefficient and should NEVER be used in a loop.
	///- Parameter minutes: offset
	///- Returns: the degrees below the horizon after sunset that match the offset in minutes passed it as a parameter.
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
    
	///A method that returns local mean time (LMT) time converted to regular clock time for the number of hours (0.0 to 23.999...) passed to this method.
	///
	/// This time is adjusted from standard time to account for the local latitude. The 360° of the globe divided by 24 calculates to 15° per hour with 4 minutes per degree, so at a longitude of 0 , 15, 30 etc... noon is at exactly 12:00pm. Lakewood, N.J., with a longitude of -74.222, is 0.7906 away from the closest multiple of 15 at -75°. This is multiplied by 4 clock minutes (per degree) to yield 3 minutes and 7 seconds for a noon time of 11:56:53am.
	///  This method is not tied to the theoretical 15° time zones, but will adjust to the actual time zone and [Daylight saving time](https://en.wikipedia.org/wiki/Daylight_saving_time) to return LMT.
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
