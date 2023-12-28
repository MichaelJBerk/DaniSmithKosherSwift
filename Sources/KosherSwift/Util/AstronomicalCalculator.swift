//
//  AstronomicalCalculator.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/19/23.
//

import Foundation

public protocol AstronomicalCalculator {
    func getUtcSunrise(date: Date, location: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double
    func getUtcSunset(date: Date, location: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double
    
    init()
}

extension AstronomicalCalculator {
    static func getElevationAdjustment(_ elevation: Double) -> Double {
        // double elevationAdjustment = 0.0347 * Math.sqrt(elevation);
        GeoLocation.degrees(acos(AstronomicalCalculatorConstants.earthRadius / (AstronomicalCalculatorConstants.earthRadius + (elevation / 1000))));
      }
    
    static func adjustZenith(zenith: Double, elevation: Double) -> Double {
        var adjustedZenith = zenith
        if zenith == Zenith.geometric.rawValue {
            // only adjust if it is exactly sunrise or sunset
            adjustedZenith = zenith +
            (AstronomicalCalculatorConstants.solarRadius +
             AstronomicalCalculatorConstants.refraction +
             getElevationAdjustment(elevation));
        }
        return adjustedZenith;
    }
}

public class AstronomicalCalculatorConstants {
    static let refraction = 34 / 60.0
    static let solarRadius = 16 / 60.0
    static let earthRadius = 6356.9
}
