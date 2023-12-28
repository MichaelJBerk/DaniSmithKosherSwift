//
//  ZmanimCalendar.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/20/23.
//

import Foundation

typealias ZmanCalculator = () -> Date?

class ZmanimCalendar: AstronomicalCalendar {
    let shouldUseElevation: Bool
    let candleLightingOffset: Double
    
    init(location: GeoLocation, date: Date = Date.now, astronomicalCalculator: AstronomicalCalculator = NOAACalculator(), shouldUseElevation: Bool = false, candleLightingOffset: Double = 18) {
        self.shouldUseElevation = shouldUseElevation
        self.candleLightingOffset = candleLightingOffset
        super.init(location: location, date: date, astronomicalCalculator: astronomicalCalculator)
    }
    
    var elevationAdjustedSunrise: Date? { shouldUseElevation ? sunrise : seaLevelSunrise }
    var elevationAdjustedSunset: Date? { shouldUseElevation ? sunset : seaLevelSunset }
    
    // Zmanim
    func tzeis() -> Date? { getSunsetOffsetByDegrees(offsetZenith: Zenith.z8_5) }
    func alosHashachar() -> Date? { getSunriseOffsetByDegrees(offsetZenith: .z16_1) }
    func alos72() -> Date? { AstronomicalCalendar.getTimeOffset(time: elevationAdjustedSunrise, offset: -72 * ZmanimCalendar.minuteMillis) }
    func chatzos() -> Date? { getSunTransit() }
    func latestShemaGra() -> Date? { calculateLatestZmanShema(elevationAdjustedSunrise, elevationAdjustedSunset) }
    func latestShemaMga() -> Date? { calculateLatestZmanShema(alos72(), tzeis72()) }
    func tzeis72() -> Date? { AstronomicalCalendar.getTimeOffset(time: elevationAdjustedSunset, offset: 72 * AstronomicalCalendar.minuteMillis) }
    
    func candleLighting() -> Date? {
        // TODO
        return nil
    }
    
    func latestTefilaGra() -> Date? { calculateLatestTefila(elevationAdjustedSunrise, elevationAdjustedSunset) }
    func latestTefilaMga() -> Date? { calculateLatestTefila(alos72(), tzeis72()) }
    func shaahZmanisGra() -> Double? { getTemporalHour(dayStart: elevationAdjustedSunrise, dayEnd: elevationAdjustedSunset) }
    func shaahZmanisMga() -> Double? { getTemporalHour(dayStart: alos72(), dayEnd: tzeis72()) }
    
    // Helpers
    func calculateLatestTefila(_ dayStart: Date?, _ dayEnd: Date?) -> Date? {
        guard let shaahZmanis = getTemporalHour(dayStart: dayStart ?? seaLevelSunrise!, dayEnd: dayEnd ?? seaLevelSunset!) else {
            return nil
        }
        return AstronomicalCalendar.getTimeOffset(time: dayStart, offset: shaahZmanis * 4)
    }
    
    func calculateLatestZmanShema(_ dayStart: Date?, _ dayEnd: Date?) -> Date? {
        guard let dayStart = dayStart, let dayEnd = dayEnd else {
            return calculateLatestZmanShema(seaLevelSunrise, seaLevelSunset)
        }
        return shaahZmanisBasedZman(dayStart, dayEnd, 3)
    }
    
    func calculateMinchaKetana(_ dayStart: Date?, _ dayEnd: Date?) -> Date? {
        guard let dayStart = dayStart, let dayEnd = dayEnd else {
            return calculateMinchaKetana(seaLevelSunrise, seaLevelSunset)
        }
        return shaahZmanisBasedZman(dayStart, dayEnd, 9.5)
    }
    
    func calculatePlagHamincha(_ dayStart: Date?, _ dayEnd: Date?) -> Date? {
        guard let dayStart = dayStart, let dayEnd = dayEnd else {
            return calculatePlagHamincha(seaLevelSunrise, seaLevelSunset)
        }
        return shaahZmanisBasedZman(dayStart, dayEnd, 10.75)
    }
    
    func calculateMinchaGedolah(_ dayStart: Date? = nil, _ dayEnd: Date? = nil) -> Date? {
        guard let dayStart = dayStart, let dayEnd = dayEnd else {
            return calculateMinchaGedolah(seaLevelSunrise, seaLevelSunset)
        }
        return shaahZmanisBasedZman(dayStart, dayEnd, 6.5)
    }
    
    func shaahZmanisBasedZman(_ startOfDay: Date, _ endOfDay: Date, _ hours: Double) -> Date? {
        guard let shaahZmanis = getTemporalHour(dayStart: startOfDay, dayEnd: endOfDay) else {
            return nil
        }
        return AstronomicalCalendar.getTimeOffset(time: startOfDay, offset: shaahZmanis * hours)
    }
}
