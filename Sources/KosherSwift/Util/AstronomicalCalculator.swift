//
//  AstronomicalCalculator.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/19/23.
//

import Foundation

/**
 A protocol that all sun time calculating classes implement. This allows the algorithm used to be changed at runtime, easily allowing comparison the results of using different algorithms.
 
 ## Topics

 ### Sunrise/Sunset
 - ``getUtcSunset(date:location:zenith:adjustForElevation:)``
 - ``getUtcSunrise(date:location:zenith:adjustForElevation:)``
 
 ### Calculating Adjustments
 - ``adjustZenith(zenith:elevation:)``
 - ``getElevationAdjustment(_:)``
 
 */
public protocol AstronomicalCalculator {
	
	/**
	 A method that calculates UTC sunrise as well as any time based on an angle above or below sunrise.
	 
	 This abstract method is implemented by the classes that implement this protocol.
	 
	 - Parameter date: Date of the year to calculate for
	 - Parameter location: The location information used for astronomical calculating sun times.
	 - Parameter zenith: The azimuth below the vertical zenith of 90 degrees. For sunrise typically the zenith used for the calculation uses geometric zenith of 90° and adjusts this slightly to account for solar refraction and the sun's radius. Another example would be ``AstronomicalCalendar/nauticalTwilightStart`` that passes ``Zenith/nautical`` to this method.
	 - Parameter adjustForElevation: Should the time be adjusted for elevation
	 - Returns: The UTC time of sunrise in 24-hour format. 5:45:00 AM will return 5.75.0. If an error was encountered in the calculation (expected behavior for some locations such as near the poles), Double.nan will be returned.
	 */
    func getUtcSunrise(date: Date, location: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double
	/**
	 A method that calculates UTC sunset as well as any time based on an angle above or below sunset
	 
	 This abstract method is implemented by the classes that implement this protocol.
	 - Parameter date: Date of the year to calculate for
	 - Parameter location: The location information used for astronomical calculating sun times.
	 - Parameter zenith: The azimuth below the vertical zenith of 90°. For sunset typically the zenith used for the calculation uses geometric zenith of 90° and adjusts this slightly to account for solar refraction and the sun's radius. Another example would be ``AstronomicalCalendar/nauticalTwilightEnd`` that passes ``Zenith/nautical`` to this method.
	 - Parameter adjustForElevation:  Should the time be adjusted for elevation
	 - Returns: The UTC time of sunset in 24-hour format. 5:45:00 AM will return 5.75.0. If an error was encountered in the calculation (expected behavior for some locations such as near the poles, Double.nan will be returned.
	 */
    func getUtcSunset(date: Date, location: GeoLocation, zenith: Double, adjustForElevation: Bool) -> Double
    
	///Default initializer for the class
    init()
}


extension AstronomicalCalculator {
	
	/**
	 Method to return the adjustment to the zenith required to account for the elevation.
	 
	 Since a person at a higher elevation can see farther below the horizon, the calculation for sunrise / sunset is calculated below the horizon used at sea level. This is only used for sunrise and sunset and not times before or after it such as nautical twilight since those calculations are based on the level of available light at the given dip below the horizon, something that is not affected by elevation, the adjustment should only be made if the zenith == 90° adjusted for refraction and solar radius. The algorithm used is
	 ```
	 elevationAdjustment = GeoLocation.degrees(acos(earthRadiusInMeters / (earthRadiusInMeters + elevationMeters)));
	 ```
	 
	 The source of this algorithm is Calendrical Calculations by Edward M. Reingold and Nachum Dershowitz. An alternate algorithm that produces similar (but not completely accurate) result found in Ma'aglay Tzedek by Moishe Kosower and other sources is:
	 ```
	  elevationAdjustment = 0.0347 * sqrt(elevationMeters);
	 ```
	 - Parameter elevation: elevation in Meters.
	 - Returns: the adjusted zenith
	 ### See Also
	 - ``adjustZenith(zenith:elevation:)``
	 */
    static func getElevationAdjustment(_ elevation: Double) -> Double {
        // double elevationAdjustment = 0.0347 * Math.sqrt(elevation);
        GeoLocation.degrees(acos(AstronomicalCalculatorConstants.earthRadius / (AstronomicalCalculatorConstants.earthRadius + (elevation / 1000))));
      }

	
    /**
	 Adjusts the zenith of astronomical sunrise and sunset to account for solar refraction, solar radius and elevation.
	 
	 The value for Sun's zenith and true rise/set Zenith (used in this protocol and its children) is the angle that the center of the Sun makes to a line perpendicular to the Earth's surface.
	 
	 If the Sun were a point and the Earth were without an atmosphere, true sunset and sunrise would correspond to a 90° zenith. Because the Sun is not a point, and because the atmosphere refracts light, this 90° zenith does not, in fact, correspond to true sunset or sunrise, instead the center of the Sun's disk must lie just below the horizon for the upper edge to be obscured. This means that a zenith of just above 90° must be used.
	 
	 The Sun subtends an angle of 16 minutes of arc (defined via ``AstronomicalCalculatorConstants/solarRadius``, and atmospheric refraction accounts for 34 minutes or so (defined via ``AstronomicalCalculatorConstants/earthRadius``), giving a total of 50 arcminutes. The total value for ZENITH is 90+(5/6) or 90.8333333° for true sunrise/sunset. Since a person at an elevation can see below the horizon of a person at sea level, this will also adjust the zenith to account for elevation if available. Note that this will only adjust the value if the zenith is exactly 90 degrees. For values below and above this no correction is done. As an example, astronomical twilight is when the sun is 18° below the horizon or 108° below the zenith. This is traditionally calculated with none of the above mentioned adjustments. The same goes for various tzais and alos times such as the 16.1° dip used in ``ComplexZmanimCalendar/alos16Point1Degrees()``
	 - Parameter zenith: the azimuth below the vertical zenith of 90°. For sunset typically the zenith used for the calculation uses geometric zenith of 90° and adjusts this slightly to account for solar refraction and the sun's radius. Another example would be ``AstronomicalCalendar/nauticalTwilightEnd`` that passes ``Zenith/nautical`` to this method.
	 - Parameter elevation: elevation in Meters
	 - Returns: The zenith adjusted to include the sun's radius, refraction and elevation adjustment. This will only be adjusted for sunrise and sunset (if the zenith == 90°)
	 ### See Also
		- ``getElevationAdjustment(_:)``
	 */
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

//TODO: Support changing constants for calculator, (KosherJava already supports this)
public class AstronomicalCalculatorConstants {
	/**
	 The refraction to be used when calculating sunrise and sunset, in arcminutes.
	 
	 The [Errata and Notes for Calendrical Calculations: The Millennium Edition](https://www.cs.tau.ac.il/~nachum/calendar-book/second-edition/errata.pdf) by Edward M. Reingold and Nachum Dershowitz lists the actual average refraction value as 34.478885263888294 or approximately 34' 29". The refraction value as well as the ``solarRadius`` and elevation adjustment are added to the zenith used to calculate sunrise and sunset.
	 */
	static let refraction = 34 / 60.0
	
	/**
	 The Sun's radius in arcminutes.
	 
	 The default value is 16 arcminutes. The sun's radius as it appears from earth is almost universally given as 16 arcminutes but in fact it differs by the time of the year. At the [perihelion](https://en.wikipedia.org/wiki/Perihelion) it has an apparent radius of 16.293, while at the [aphelion](https://en.wikipedia.org/wiki/Aphelion) it has an apparent radius of 15.755. There is little affect for most location, but at high and low latitudes the difference becomes more apparent. My Calculations for the difference at the location of the [Royal Observatory, Greenwich](https://www.rmg.co.uk/royal-observatory) shows only a 4.494-second difference between the perihelion and aphelion radii, but moving into the arctic circle the difference becomes more noticeable. Tests for Tromso, Norway (latitude 69.672312, longitude 19.049787) show that on May 17, the rise of the midnight sun, a 2 minute and 23 second difference is observed between the perihelion and aphelion radii using the USNO algorithm, but only 1 minute and 6 seconds difference using the NOAA algorithm. Areas farther north show an even greater difference. Note that these test are not real valid test cases because they show the extreme difference on days that are not the perihelion or aphelion, but are shown for illustrative purposes only.
	 */
    static let solarRadius = 16 / 60.0
	
	/**
	 The earth radius in KM.
	 
	 The default value is 6356.9 KM
	 */
    static let earthRadius = 6356.9
}
