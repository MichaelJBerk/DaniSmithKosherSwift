//
//  ZmanimCalendar.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/20/23.
//

import Foundation

typealias ZmanCalculator = () -> Date?

public class ZmanimCalendar: AstronomicalCalendar, @unchecked Sendable {
    let shouldUseElevation: Bool
    public let candleLightingOffset: Double
    
    public required init(location: GeoLocation, date: Date, astronomicalCalculator: AstronomicalCalculator = NOAACalculator(), shouldUseElevation: Bool = false, candleLightingOffset: Double = 18) {
        self.shouldUseElevation = shouldUseElevation
        self.candleLightingOffset = candleLightingOffset
        super.init(location: location, date: date, astronomicalCalculator: astronomicalCalculator)
    }
    
    var elevationAdjustedSunrise: Date? { shouldUseElevation ? sunrise : seaLevelSunrise }
    var elevationAdjustedSunset: Date? { shouldUseElevation ? sunset : seaLevelSunset }
    
    // Zmanim
    public func tzeis() -> Date? { getSunsetOffsetByDegrees(offsetZenith: Zenith.z8_5) }
	
	/// Returns *alos* (dawn) based on the time when the sun is [16.1°](``Zenith/z16_1``) below the eastern [geometric horizon](``Zenith/geometric``) before [sunrise](``AstronomicalCalendar/sunrise``). This is based on the calculation that the time between dawn and sunrise (and sunset to nightfall) is 72 minutes, the time that is takes to walk 4 [mil](https://en.wikipedia.org/wiki/Biblical_and_Talmudic_units_of_measurement) at 18 minutes a mil ([Rambam](https://en.wikipedia.org/wiki/Maimonides) and others). The sun's position below the horizon 72 minutes before [sunrise](``AstronomicalCalendar/sunrise``) in Jerusalem on the [around the equinox / equilux](https://kosherjava.com/2022/01/12/equinox-vs-equilux-zmanim-calculations/) is 16.1&deg; below [geometric zenith](``Zenith/geometric``).
	/// - Returns: The `Date` of dawn. If the calculation can't be computed such as northern and southern
	/// locations even south of the Arctic Circle and north of the Antarctic Circle where the sun may not reach low enough below the horizon for this calculation, a `null` will be returned. See detailed explanation on top of the ``AstronomicalCalendar`` documentation.
	/// ## See Also
	/// - ``ComplexZmanimCalendar/alos16Point1Degrees()``
	/// - ``Zenith/z16_1``
    public func alosHashachar() -> Date? { getSunriseOffsetByDegrees(offsetZenith: .z16_1) }
    public func alos72() -> Date? { AstronomicalCalendar.getTimeOffset(time: elevationAdjustedSunrise, offset: -72 * ZmanimCalendar.minuteMillis) }
	public func chatzos() -> Date? {
		return getSunTransit()
	}
    public func latestShemaGra() -> Date? { calculateLatestZmanShema(elevationAdjustedSunrise, elevationAdjustedSunset) }
    public func latestShemaMga() -> Date? { calculateLatestZmanShema(alos72(), tzeis72()) }
    public func tzeis72() -> Date? { AstronomicalCalendar.getTimeOffset(time: elevationAdjustedSunset, offset: 72 * AstronomicalCalendar.minuteMillis) }
	
	/// A method to return candle lighting time, calculated as ``candleLightingOffset`` minutes before ``AstronomicalCalendar/seaLevelSunset``
	///
	/// This will return the time for any day of the week, since it can be used to calculate candle lighting time for *Yom Tov* (mid-week holidays) as well. Elevation adjustments are intentionally not performed by this method, but you can calculate it by passing the elevation adjusted sunset to ``AstronomicalCalendar/getTimeOffset(time:offset:)``.
	/// - Returns: candle lighting time. If the calculation can't be computed such as in the Arctic Circle where there is at
	/// least one day a year where the sun does not rise, and one where it does not set, `nil` will be returned. See detailed explanation on top of the `AstronomicalCalendar` documentation.
	/// ## See Also
	/// - ``AstronomicalCalendar/seaLevelSunset``
	/// - ``candleLightingOffset``
	public func candleLighting() -> Date? {
		return AstronomicalCalendar.getTimeOffset(time: seaLevelSunset, offset: -1 * candleLightingOffset * AstronomicalCalendar.minuteMillis)
	}
	
	/// A method to return the next candle lighting time
	/// 
	/// This method returns the value of ``candleLighting()`` time on the next day that has candle lighting (which can also include the current day).
	/// - Parameter inIsrael: whether or not the user is in Israel, which affects _Yom Tov_ calculations
	/// ## See Also
	/// - ``candleLighting()``
	public func getNextCandleLighting(inIsrael: Bool = false) -> Date? {
		var cal = CoreJewishCalendar(date: date, isInIsrael: inIsrael)
		while !cal.isTomorrowShabbosOrYomTov {
			cal = cal.advanced(byAdding: .day, value: 1)
		}
		let zmanimCal = copy(with: cal.gregDate)
		return zmanimCal.candleLighting()
	}
	
	/// A method to return the time when *Shabbos* or *Yom Tov* ends
	///
	/// - Parameter timeOffset: the number of minutes after ``AstronomicalCalendar/seaLevelSunset`` when *Shabbos* or *Yom Tov* ends. Defaults to `50`.
	///
	/// This will return the time for any day of the week, since it can be used to calculate the time for the end of *Yom Tov* (mid-week holidays) as well. Elevation adjustments are intentionally not performed by this method, but you can calculate it by passing the elevation adjusted sunset to ``AstronomicalCalendar/getTimeOffset(time:offset:)``.
	/// - Returns: the time when *Shabbos* or *Yom Tov* ends. If the calculation can't be computed such as in the Arctic Circle where there is at
	/// least one day a year where the sun does not rise, and one where it does not set, `nil` will be returned. See detailed explanation on top of the `AstronomicalCalendar` documentation.
	/// ## See Also
	/// - ``AstronomicalCalendar/seaLevelSunset``
	/// - ``candleLightingOffset``
	public func havdalah(timeOffset: Double = 50) -> Date? {
		return AstronomicalCalendar.getTimeOffset(time: seaLevelSunset, offset: timeOffset * AstronomicalCalendar.minuteMillis)
	}
	
	/// A method to return *havdala* on the next day where *Shabbos* or *Yom Tov* ends
	///
	/// This will return the time for *havdala* on the next day that *Shabbos* or *Yom Tov* ends.
	/// For example, if the ``AstronomicalCalendar/date`` is set to a day that is *Erev Yom Tov*, it will return the *havdala* on the last day of *Yom Tov*. If the *Yom Tov* occurs on Friday, it will return the *havdala* for *Shabbos*. If called on a weekday, it will return the *havdala* for the upcoming *Shabbos*.
	/// - Parameters:
	///   - timeOffset: the number of minutes after ``AstronomicalCalendar/seaLevelSunset`` when *Shabbos* or *Yom Tov* ends. Defaults to `50`.
	///   - inIsreal: whether or not the user is in Israel, which affects _Yom Tov_ calculations
	/// ## See Also
	/// - ``havdalah(timeOffset:)``
	public func nextHavdala(timeOffset: Double = 50, inIsreal: Bool) -> Date? {
		var cal = CoreJewishCalendar(date: date, isInIsrael: inIsreal)
		while !(cal.isAssurBemelacha && !cal.isTomorrowShabbosOrYomTov) {
			cal = cal.advanced(byAdding: .day, value: 1)
		}
		let zmanimCal = copy(with: cal.gregDate)
		return zmanimCal.havdalah(timeOffset: timeOffset)
	}
    
    public func latestTefilaGra() -> Date? { calculateLatestTefila(elevationAdjustedSunrise, elevationAdjustedSunset) }
    public func latestTefilaMga() -> Date? { calculateLatestTefila(alos72(), tzeis72()) }
    public func shaahZmanisGra() -> Double? { getTemporalHour(dayStart: elevationAdjustedSunrise, dayEnd: elevationAdjustedSunset) }
    public func shaahZmanisMga() -> Double? { getTemporalHour(dayStart: alos72(), dayEnd: tzeis72()) }
    
    // Helpers
    public func calculateLatestTefila(_ dayStart: Date?, _ dayEnd: Date?) -> Date? {
        guard let shaahZmanis = getTemporalHour(dayStart: dayStart ?? seaLevelSunrise!, dayEnd: dayEnd ?? seaLevelSunset!) else {
            return nil
        }
        return AstronomicalCalendar.getTimeOffset(time: dayStart, offset: shaahZmanis * 4)
    }
    
    public func calculateLatestZmanShema(_ dayStart: Date?, _ dayEnd: Date?) -> Date? {
        guard let dayStart = dayStart, let dayEnd = dayEnd else {
            return calculateLatestZmanShema(seaLevelSunrise, seaLevelSunset)
        }
        return shaahZmanisBasedZman(dayStart, dayEnd, 3)
    }
    
    public func calculateMinchaKetana(_ dayStart: Date?, _ dayEnd: Date?) -> Date? {
        guard let dayStart = dayStart, let dayEnd = dayEnd else {
            return calculateMinchaKetana(seaLevelSunrise, seaLevelSunset)
        }
        return shaahZmanisBasedZman(dayStart, dayEnd, 9.5)
    }
    
    public func calculatePlagHamincha(_ dayStart: Date?, _ dayEnd: Date?) -> Date? {
        guard let dayStart = dayStart, let dayEnd = dayEnd else {
            return calculatePlagHamincha(seaLevelSunrise, seaLevelSunset)
        }
        return shaahZmanisBasedZman(dayStart, dayEnd, 10.75)
    }
    
    public func calculateMinchaGedolah(_ dayStart: Date? = nil, _ dayEnd: Date? = nil) -> Date? {
        guard let dayStart = dayStart, let dayEnd = dayEnd else {
            return calculateMinchaGedolah(seaLevelSunrise, seaLevelSunset)
        }
        return shaahZmanisBasedZman(dayStart, dayEnd, 6.5)
    }
    
    public func shaahZmanisBasedZman(_ startOfDay: Date, _ endOfDay: Date, _ hours: Double) -> Date? {
        guard let shaahZmanis = getTemporalHour(dayStart: startOfDay, dayEnd: endOfDay) else {
            return nil
        }
        return AstronomicalCalendar.getTimeOffset(time: startOfDay, offset: shaahZmanis * hours)
    }
    
    public func getHalfDayBasedZman(startOfHalfDay:Date?, endOfHalfDay:Date?, hours:Double) -> Date? {
        if (startOfHalfDay == nil || endOfHalfDay == nil) {
            return nil;
        }
        
        let shaahZmanis = getHalfDayBasedShaahZmanis(startOfHalfDay: startOfHalfDay, endOfHalfDay: endOfHalfDay)
        if (shaahZmanis == Int64.min) { //defensive, should not be needed
            return nil;
        }
        
        if hours >= 0 { // forward from start a day
            return ZmanimCalendar.getTimeOffset(time: startOfHalfDay, offset: (Double(shaahZmanis) * hours) * 1000)
        } else { // subtract from end of day
            return ZmanimCalendar.getTimeOffset(time: endOfHalfDay, offset: (Double(shaahZmanis) * hours) * 1000)
        }
    }
    
    public func getHalfDayBasedShaahZmanis(startOfHalfDay:Date?, endOfHalfDay:Date?) -> Int64 {
        if (startOfHalfDay == nil || endOfHalfDay == nil) {
            return Int64.min;
        }
        return Int64((endOfHalfDay!.timeIntervalSince1970 - startOfHalfDay!.timeIntervalSince1970) / 6)
    }
	
	/// Make a copy of the current ``ZmanimCalendar`` instance with a different date
	/// - Parameter date: The working date for the new instance. If `nil`, it will use the same working date as this instance.
	public func copy(with date: Date?) -> Self {
		return Self.init(location: location, date: date ?? self.date, astronomicalCalculator: astronomicalCalculator, shouldUseElevation: shouldUseElevation, candleLightingOffset: candleLightingOffset)
	}
	
	/// Create a copy of the ``ZmanimCalendar`` instance advanced by a given calendar component
	/// - Parameters:
	///   - component: The calendar component to advance
	///   - value: The value the component should be advanced by
	/// - Returns: A copy of the ``ZmanimCalendar`` with the `component` advanced by `value`
	/// - Warning: This method will crash in rare situations where ``Calendar/date(byAdding:to:wrappingComponents:)`` returns `nil`.
	/// ## See Also
	/// - ``copy(with:)``
	public func advanced(byAdding component: Calendar.Component, value: Int) -> Self {
		self.copy(with: Calendar.current.date(byAdding: component, value: value, to: self.date)!)
	}
}
