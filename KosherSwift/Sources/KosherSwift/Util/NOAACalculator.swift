//
//  NOAACalculator.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/19/23.
//

import Foundation

class NOAACalculator: AstronomicalCalculator {
    private static let julianDayJan12000 = 2451545.0
    private static let julianDaaysPerCentury = 36525.0;
        
    func getUtcSunrise(date: Date, location: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        let elevation = adjustForElevation ? (location.elevation ?? 0) : 0
        let adjustedZenith = NOAACalculator.adjustZenith(zenith: zenith, elevation: elevation)
        
        var sunrise = getSunriseUTC(julianDay: NOAACalculator.getJulianDay(date), latitude: location.lat, longitude: -location.lng, zenith: adjustedZenith);
        sunrise = sunrise / 60;
        
        // ensure that the time is >= 0 and < 24
        while (sunrise < 0.0) {
            sunrise += 24.0;
        }
        while (sunrise >= 24.0) {
            sunrise -= 24.0;
        }
        return sunrise;
    }
    
    func getUtcSunset(date: Date, location: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double {
        let elevation = adjustForElevation ? location.elevation ?? 0 : 0
        let adjustedZenith = NOAACalculator.adjustZenith(zenith: zenith, elevation: elevation)

        var sunset = getSunsetUTC(julianDay: NOAACalculator.getJulianDay(date), latitude: location.lat, longitude: -location.lng, zenith: adjustedZenith)
        sunset = sunset / 60

        // ensure that the time is >= 0 and < 24
        while sunset < 0.0 {
            sunset += 24.0
        }
        while sunset >= 24.0 {
            sunset -= 24.0
        }
        return sunset
    }
    
    static func getJulianDay(_ date: Date) -> Double {
        let comp = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        var year = comp.year!
        var month = comp.month!
        let day = comp.day!
        
        if (month <= 2) {
            year -= 1
            month += 12
        }
        
        let a = year ~/ 100
        let b = 2 - a + (a ~/ 4)
        let c = (365.25 * Double(year + 4716)).rounded(.down)
        let d = (30.6001 * Double(month + 1)).rounded(.down)
        
        let ret = c + d + Double(day + b) - 1524.5
        return ret
    }
    
    private static func getJulianDayFromJulianCenturies(_ julianCenturies: Double) -> Double {
        return julianCenturies * julianDaaysPerCentury + julianDayJan12000;
      }
    
    private static func getSunGeometricMeanLongitude(_ julianCenturies: Double) -> Double {
        var longitude = 280.46646 +
        julianCenturies * (36000.76983 + 0.0003032 * julianCenturies);
        while (longitude > 360.0) {
            longitude -= 360.0;
        }
        while (longitude < 0.0) {
            longitude += 360.0;
        }
        
        return longitude; // in degrees
    }
    
    private static func getSunGeometricMeanAnomaly(_ julianCenturies: Double) -> Double {
        return 357.52911 +
            julianCenturies *
                (35999.05029 - 0.0001537 * julianCenturies); // in degrees
      }
    
    private static func getEarthOrbitEccentricity(julianCenturies: Double) -> Double {
        return 0.016708634 -
            julianCenturies *
                (0.000042037 + 0.0000001267 * julianCenturies); // unitless
      }
    
    static func getSunEquationOfCenter(julianCenturies: Double) -> Double {
        let m = getSunGeometricMeanAnomaly(julianCenturies);

        let mrad = m.radians;
        let sinm = sin(mrad);
        let sin2m = sin(mrad + mrad);
        let sin3m = sin(mrad + mrad + mrad);

        return sinm *
                (1.914602 -
                    julianCenturies * (0.004817 + 0.000014 * julianCenturies)) +
            sin2m * (0.019993 - 0.000101 * julianCenturies) +
            sin3m * 0.000289; // in degrees
      }
    
    static func getSunTrueLongitude(_ julianCenturies: Double) -> Double {
        let sunLongitude = getSunGeometricMeanLongitude(julianCenturies)
        let center = getSunEquationOfCenter(julianCenturies: julianCenturies)
        return sunLongitude + center // in degrees
    }

    static func getSunApparentLongitude(_ julianCenturies: Double) -> Double {
        let sunTrueLongitude = getSunTrueLongitude(julianCenturies)
        let omega = 125.04 - 1934.136 * julianCenturies
        let lambda = sunTrueLongitude - 0.00569 - 0.00478 * sin(omega.radians)
        return lambda // in degrees
    }

    static func getMeanObliquityOfEcliptic(_ julianCenturies: Double) -> Double {
        let seconds = 21.448 -
            julianCenturies *
            (46.8150 +
                julianCenturies * (0.00059 - julianCenturies * (0.001813)))
        return 23.0 + (26.0 + (seconds / 60.0)) / 60.0 // in degrees
    }

    static func getObliquityCorrection(_ julianCenturies: Double) -> Double {
        let obliquityOfEcliptic = getMeanObliquityOfEcliptic(julianCenturies)
        let omega = 125.04 - 1934.136 * julianCenturies
        return obliquityOfEcliptic + 0.00256 * cos(omega.radians) // in degrees
    }

    func getSunDeclination(_ julianCenturies: Double) -> Double {
        let obliquityCorrection = NOAACalculator.getObliquityCorrection(julianCenturies)
        let lambda = NOAACalculator.getSunApparentLongitude(julianCenturies)
        let sint = sin(obliquityCorrection.radians) * sin(lambda.radians)
        let theta = asin(sint).degrees
        return theta // in degrees
    }

    func getEquationOfTime(_ julianCenturies: Double) -> Double {
        let epsilon = NOAACalculator.getObliquityCorrection(julianCenturies)
        let geomMeanLongSun = NOAACalculator.getSunGeometricMeanLongitude(julianCenturies)
        let eccentricityEarthOrbit = NOAACalculator.getEarthOrbitEccentricity(julianCenturies: julianCenturies)
        let geomMeanAnomalySun = NOAACalculator.getSunGeometricMeanAnomaly(julianCenturies)
        var y = tan(epsilon.radians / 2.0)
        y *= y
        let sin2l0 = sin(2.0 * geomMeanLongSun.radians)
        let sinm = sin(geomMeanAnomalySun.radians)
        let cos2l0 = cos(2.0 * geomMeanLongSun.radians)
        let sin4l0 = sin(4.0 * geomMeanLongSun.radians)
        let sin2m = sin(2.0 * geomMeanAnomalySun.radians)
        let equationOfTime = y * sin2l0 -
            2.0 * eccentricityEarthOrbit * sinm +
            4.0 * eccentricityEarthOrbit * y * sinm * cos2l0 -
            0.5 * y * y * sin4l0 -
            1.25 * eccentricityEarthOrbit * eccentricityEarthOrbit * sin2m
        return equationOfTime.degrees * 4.0 // in minutes of time
    }

    func getSunHourAngleAtSunrise(lat: Double, solarDec: Double, zenith: Double) -> Double {
        let latRad = lat.radians
        let sdRad = solarDec.radians
        var x = (cos(zenith.radians) / (cos(latRad) * cos(sdRad)) - tan(latRad) * tan(sdRad))
        x = max(min(1, x), -1)
        return acos(x) // in radians
    }

    func getSunHourAngleAtSunset(lat: Double, solarDec: Double, zenith: Double) -> Double {
        let latRad = lat.radians
        let sdRad = solarDec.radians
        let hourAngle = acos(cos(zenith.radians) / (cos(latRad) * cos(sdRad)) - tan(latRad) * tan(sdRad))
        return -hourAngle // in radians
    }

    func getSolarElevation(dateTime: Date, lat: Double, lon: Double) -> Double {
        let julianDay = getJulianDay(dateTime: dateTime)
        let julianCenturies = getJulianCenturiesFromJulianDay(julianDay: julianDay)
        let eot = getEquationOfTime(julianCenturies: julianCenturies)
        
        let comps = Calendar.current.dateComponents([.hour, .minute, .second], from: dateTime)
        
        let a = (Double(comps.hour!) + 12.0)
        let b = (Double(comps.minute!) + eot + Double(comps.second!) / 60.0)
        var longitude = a + b / 60.0
        
        longitude = -(longitude * 360.0 / 24.0).truncatingRemainder(dividingBy: 360.0)
        let hourAngleRad = (lon - longitude).radians
        let declination = getSunDeclination(julianCenturies: julianCenturies)
        let decRad = declination.radians
        let latRad = lat.radians
        return asin((sin(latRad) * sin(decRad)) + (cos(latRad) * cos(decRad) * cos(hourAngleRad))).degrees
    }

    func getJulianDay(dateTime: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: dateTime)
        let year = Double(components.year!)
        let month = Double(components.month!)
        let day = Double(components.day!)
        
        if month <= 2 {
            let y = year - 1
            let m = month + 12
            return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + day - 1524.5
        } else {
            let y = year
            let m = month
            return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + day - 1524.5
        }
    }

    func getJulianCenturiesFromJulianDay(julianDay: Double) -> Double {
        return (julianDay - 2451545.0) / 36525.0
    }

    func getEquationOfTime(julianCenturies: Double) -> Double {
        let g = (357.528 + 0.9856003 * julianCenturies).truncatingRemainder(dividingBy: 360.0)
        let c = 1.9148 * sin(g.radians) + 0.0200 * sin((2 * g).radians) + 0.0003 * sin((3 * g).radians)
        let lambda = (280.460 + c).truncatingRemainder(dividingBy: 360.0)
        let e = 23.4393 - 0.0000004 * julianCenturies
        let y = tan(e.radians / 2) * tan(e.radians / 2)
        let equationOfTime = 4 * (y * sin(2 * lambda.radians) - 2 * e * sin(g.radians) + 4 * e * y * sin(g.radians) * cos(2 * lambda.radians) - 0.5 * y * y * sin(4 * lambda.radians) - 1.25 * e * e * sin(2 * g.radians))
        return equationOfTime
    }

    func getSunDeclination(julianCenturies: Double) -> Double {
        let g = (357.528 + 0.9856003 * julianCenturies).truncatingRemainder(dividingBy: 360.0)
        let q = 280.459 + 0.98564736 * julianCenturies
        let l = q + 1.915 * sin(g.radians) + 0.020 * sin((2 * g).radians)
        let r = 23.439 - 0.0000004 * julianCenturies
        let e = asin(sin(r.radians) * sin(l.radians))
        return e
    }

    func getSolarAzimuth(dateTime: Date, lat: Double, lon: Double) -> Double {
        let julianDay = getJulianDay(dateTime: dateTime)
        let julianCenturies = getJulianCenturiesFromJulianDay(julianDay: julianDay)
        let eot = getEquationOfTime(julianCenturies: julianCenturies)
        var longitude = (Double(Calendar.current.component(.hour, from: dateTime)) + 12.0) +
            (Double(Calendar.current.component(.minute, from: dateTime)) + eot + Double(Calendar.current.component(.second, from: dateTime)) / 60.0) / 60.0
        longitude = -(longitude * 360.0 / 24.0).truncatingRemainder(dividingBy: 360.0)
        let hourAngleRad = lon - longitude.radians
        let declination = getSunDeclination(julianCenturies: julianCenturies)
        let decRad = declination.radians
        let latRad = lat.radians
        return atan(sin(hourAngleRad.degrees /
                ((cos(hourAngleRad) * sin(latRad)) -
                    (tan(decRad) * cos(latRad))))) +
            180
    }

    func getSunriseUTC(julianDay: Double, latitude: Double, longitude: Double, zenith: Double) -> Double {
        let julianCenturies = getJulianCenturiesFromJulianDay(julianDay: julianDay)
        let noonmin = getSolarNoonUTC(julianCenturies: julianCenturies, longitude: longitude)
        let tnoon = getJulianCenturiesFromJulianDay(julianDay: julianDay + noonmin / 1440.0)
        var eqTime = getEquationOfTime(tnoon)
        var solarDec = getSunDeclination(tnoon)
        var hourAngle = getSunHourAngleAtSunrise(lat: latitude, solarDec: solarDec, zenith: zenith)
        var delta = longitude - hourAngle.degrees
        var timeDiff = 4 * delta // in minutes of time
        var timeUTC = 720 + timeDiff - eqTime // in minutes
        let newt = getJulianCenturiesFromJulianDay(julianDay: NOAACalculator.getJulianDayFromJulianCenturies(julianCenturies) + timeUTC / 1440.0)
        eqTime = getEquationOfTime(newt)
        solarDec = getSunDeclination(newt)
        hourAngle = getSunHourAngleAtSunrise(lat: latitude, solarDec: solarDec, zenith: zenith)
        delta = longitude - hourAngle.degrees
        timeDiff = 4 * delta
        timeUTC = 720 + timeDiff - eqTime // in minutes
        return timeUTC
    }
    
    func getSolarNoonUTC(julianCenturies: Double, longitude: Double) -> Double {
        // First pass uses approximate solar noon to calculate eqtime
        let tnoon = getJulianCenturiesFromJulianDay(
            julianDay: NOAACalculator.getJulianDayFromJulianCenturies(julianCenturies) + longitude / 360.0)
        var eqTime = getEquationOfTime(tnoon)
        let solNoonUTC = 720 + (longitude * 4) - eqTime // min
        let newt = getJulianCenturiesFromJulianDay(
            julianDay: NOAACalculator.getJulianDayFromJulianCenturies(julianCenturies) -
                0.5 +
                solNoonUTC / 1440.0)
        eqTime = getEquationOfTime(newt)
        return 720 + (longitude * 4) - eqTime // min
    }

    func getSunsetUTC(julianDay: Double, latitude: Double, longitude: Double, zenith: Double) -> Double {
        let julianCenturies = getJulianCenturiesFromJulianDay(julianDay: julianDay)
        let noonmin = getSolarNoonUTC(julianCenturies: julianCenturies, longitude: longitude)
        let tnoon = getJulianCenturiesFromJulianDay(julianDay: julianDay + noonmin / 1440.0)
        let eqTime = getEquationOfTime(tnoon)
        let solarDec = getSunDeclination(tnoon)
        let hourAngle = getSunHourAngleAtSunset(lat: latitude, solarDec: solarDec, zenith: zenith)
        let delta = longitude - hourAngle.degrees
        let timeDiff = 4 * delta
        var timeUTC = 720 + timeDiff - eqTime
        let newt = getJulianCenturiesFromJulianDay(julianDay: NOAACalculator.getJulianDayFromJulianCenturies(julianCenturies) + timeUTC / 1440.0)
        let eqTime2 = getEquationOfTime(newt)
        let solarDec2 = getSunDeclination(newt)
        let hourAngle2 = getSunHourAngleAtSunset(lat: latitude, solarDec: solarDec2, zenith: zenith)
        let delta2 = longitude - hourAngle2.degrees
        let timeDiff2 = 4 * delta2
        timeUTC = 720 + timeDiff2 - eqTime2
        return timeUTC
    }
}

extension Double {
    var radians: Double {
        return self * .pi / 180.0
    }
    
    var degrees: Double {
        return self * 180.0 / .pi
    }
}
