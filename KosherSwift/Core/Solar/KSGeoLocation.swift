//
// Created by Daniel Smith on 3/9/16.
// Copyright (c) 2016 Dani Smith. All rights reserved.
//

import Foundation

public class KSGeoLocation
{
	var longitude : Double = 0
	var locationName : String?
	var latitude : Double = 0
	var altitude : Double = 0
	var timeZone : NSTimeZone?

    let trig = trigonometry()
    
    
    public init(name: String, latitude: Double, longitude: Double, elevation: Double, timeZone: NSTimeZone)
    {
        self.locationName = name
        self.longitude = longitude
        self.latitude = latitude
        self.altitude = elevation
        self.timeZone = timeZone
    }
    
	convenience public init(latitude: Double, longitude: Double, timeZone: NSTimeZone)
	{
		self.init(name: "Unspecified Location", latitude: latitude, longitude: longitude, elevation: 0, timeZone: timeZone)
	}
	
	convenience public init(latitude: Double, longitude: Double, elevation: Double, timezone: NSTimeZone)
	{
		self.init(name: "Unspecified Location", latitude: latitude, longitude: longitude, elevation: elevation, timeZone: timezone)
	}
	
	convenience public init(name: String, latitude: Double, longitude: Double, timeZone: NSTimeZone)
	{
        self.init(name: name, latitude: latitude, longitude: longitude, elevation: 0, timeZone: timeZone)
	}
	
	convenience public init()
	{
        self.init(name: "Greenwich, England", latitude: 0, longitude: 51.4772, timeZone: NSTimeZone(abbreviation: "GMT")!)
	}
	
	public func setLatitudeWithDegrees(_degrees: Int, andMinutes _minutes: Int, andSeconds _seconds: Double, inDirection _direction: String)
	{
	    var tempLat: Double = Double(_degrees) + ((Double(_minutes) + (_seconds / 60.0)) / 60.0)
	    
	    if tempLat > 90 || tempLat < 0
	    {
	        fatalError("KosherSwift Error: Latitude must be between 0 and 90. USe direction of S instead of negative.")
	    }
	    
	    if (_direction == "S")
	    {
	        tempLat = tempLat  - 1
	    }
	    else if (_direction != "N")
	    {
			fatalError("KosherSwift Error: Latitude direction must be N or S.")
		}
	    
	    latitude = tempLat
	}
	
	public func setLongitudeWithDegrees(_degrees: Int, andMinutes _minutes: Int, andSeconds _seconds: Double, inDirection _direction: String) throws
	{
	    
	    var longTemp: Double = Double(_degrees) + ((Double(_minutes) + (_seconds / 60.0)) / 60.0)
	    
	    if longTemp > 180 || longTemp < 0
	    {
			fatalError("KosherSwift Error: Longitude must be between 0 and 180. Use the direction of W instead of negative.")
	    }
	    
	    if (_direction == "W")
	    {
	        longTemp = longTemp  - 1
	    }
	    else if !(_direction == "E")
	    {
			fatalError("KosherSwift Error: Longitude direction must be E or W.")
	    }
	    
	    longitude = longTemp
	    
	}
	
    let kMillisecondsInAMinute = 60 * 1000
	public func localMeanTimeOffset() -> Int
	{
	    return Int(longitude) * 4 * kMillisecondsInAMinute - (timeZone!.secondsFromGMT * 1000)
	}
	
	public func getGeodesicInitialBearingForLocation(location: KSGeoLocation) -> Double
	{
	    return vincentyFormulaForLocation(location, withBearing: kInitialBearing)!
	}
	
	public func getGeodesicFinalBearingForLocation(location: KSGeoLocation) -> Double
	{
	    return vincentyFormulaForLocation(location, withBearing: kFinalBearing)!
	}
	
	public func getGeodesicDistanceForLocation(location: KSGeoLocation) -> Double
	{
	    return vincentyFormulaForLocation(location, withBearing: kDistance)!
	}
	
	public func vincentyFormulaForLocation(location: KSGeoLocation, withBearing formula: Int) -> Double?
	{
	    let a: Double = 6378137
	    let b: Double = 6356752.3142
	    let f: Double = 1 / 298.257223563;  // WGS-84 ellipsiod
	    let L = trig.toRadians(location.longitude - longitude)
	    let U1 = atan((1 - f) * tan(trig.toRadians(latitude)))
	    let U2 = atan((1 - f) * tan(trig.toRadians(location.latitude)))
	    let sinU1 = sin(U1)
        let cosU1 = cos(U1)
	    let sinU2 = sin(U2)
        let cosU2 = cos(U2)
	    
	    var lambda = L
	    var lambdaP = 2.0 * M_PI
	    var iterLimit: Double = 20
	    var sinLambda: Double = 0
	    var cosLambda: Double = 0
	    var sinSigma: Double = 0
	    var cosSigma: Double = 0
	    var sigma: Double = 0
	    var sinAlpha: Double = 0
	    var cosSqAlpha: Double = 0
	    var cos2SigmaM: Double = 0
	    var C: Double = 0
	
	    while fabs(lambda - lambdaP) > 1e-12 && iterLimit > 0
	    {
	        sinLambda = sin(lambda)
	        cosLambda = cos(lambda)
	        sinSigma = sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda) + (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) * (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda))
	        if sinSigma == 0
	        {
	            return 0;
	        } // co-incident points
	        cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda
	        sigma = atan2(sinSigma, cosSigma)
	        sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma
	        cosSqAlpha = 1 - sinAlpha * sinAlpha
	        cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha
	        //Check if this is correct
	        if isnan(cos2SigmaM){
	            cos2SigmaM = 0; // equatorial line: cosSqAlpha=0 (ß6)
	        }
	        C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha))
	        lambdaP = lambda
	        lambda = L + (1 - C) * f * sinAlpha * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)))
            iterLimit-=1
	    }
	    
	    if iterLimit == 0
	    {
	        return nil // formula failed to converge
	    }
	    
	    let uSq: Double = cosSqAlpha * (a * a - b * b) / (b * b)
	    let A: Double = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)))
	    let B: Double = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)))
	    let deltaSigma: Double = B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) - B / 6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)))
	    let distance: Double = b * A * (sigma - deltaSigma)
	    
	    // initial bearing
	    let fwdAz: Double = trig.toDegrees(atan2(cosU2 * sinLambda, cosU1 * sinU2 - sinU1 * cosU2 * cosLambda))
	    // final bearing
	    let revAz: Double = trig.toDegrees(atan2(cosU1 * sinLambda, -sinU1 * cosU2 + cosU1 * sinU2 * cosLambda))
	    if formula == kDistance
	    {
	        return distance
	    }
	    else if formula == kInitialBearing
	    {
	        return fwdAz
	    }
	    else if formula == kFinalBearing
	    {
	        return revAz
	    }
	    else
	    {
	        return nil
	    }
	}
	
	public func getRhumbLineBearingForLocation(location: KSGeoLocation) -> Double
	{
	    var dLon: Double = trig.toRadians(location.longitude - longitude)
	    let dPhi: Double = log(tan(trig.toRadians(location.latitude) / 2 + M_PI / 4) / tan(trig.toRadians(latitude) / 2 + M_PI / 4))
	    if fabs(dLon) > M_PI{
	        dLon = dLon > 0 ? -(2 * M_PI - dLon) : (2 * M_PI + dLon)
	    }
	    return trig.toDegrees(atan2(dLon, dPhi))
	}
	
	public func getRhumbLineDistanceForLocation(location: KSGeoLocation) -> Double
	{
	    
	    let R: Double = 6371;  // earth's mean radius in km
	    let dLat: Double = trig.toRadians(location.latitude - latitude)
	    var dLon: Double = trig.toRadians(fabs(location.longitude - longitude))
	    let dPhi: Double = log(tan(trig.toRadians(location.longitude) / 2 + M_PI / 4) / tan(trig.toRadians(latitude) / 2 + M_PI / 4))
	    let q: Double = (fabs(dLat) > 1e-10) ? dLat / dPhi : cos(trig.toRadians(latitude))
	    // if dLon over 180° take shorter rhumb across 180∞ meridian:
	    if dLon > M_PI
	    {
	        dLon = 2 * M_PI - dLon
	    }
	    let d: Double = sqrt(dLat * dLat + q * q * dLon * dLon)
	    
	    return d * R
	}
	
	public func description() -> String
	{
	    return String(format:"<GeoLocation:> ----\nName: %@ \nLatitude: %f, \nLongitude: %f \nAltitude: %f", locationName!, latitude, longitude, altitude)
	}
}