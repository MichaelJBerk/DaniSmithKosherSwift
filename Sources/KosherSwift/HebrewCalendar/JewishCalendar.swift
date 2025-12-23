//
//  File.swift
//  KosherSwift
//
//  Created by Michael Berk on 12/23/25.
//

import Foundation

///A class that calculates the dates for Jewish holidays, Daf Yomi, and more
///
///This class may have API changes from the Java implementation. If you would like to use the original KosherJava behavior, use the ``CoreJewishCalendar`` class.
public class JewishCalendar: CoreJewishCalendar {
	
    ///Returns if the current day is *Erev Yom Tov*.
	///
	///This returns `true` for *Erev* - *Pesach* (first and last days), *Shavuos*, *Rosh Hashana*, *Yom Kippur*, *Succos*, *Hoshana Rabba*, *Chanukah*, and *Rosh Chodesh*.
	///
	///## See Also
	///- ``isYomTov``
	///- ``isErevYomTovSheni``
    override public var isErevYomTov: Bool { isErevShavuos || isErevPesach || isErevSuccos || isErevRoshHashana || isErevYomKippur || isErevSuccos || isHoshanaRabba || isErevChanukah || isErevRoshChodesh || (isCholHamoedPesach && day == 20) }

    override var holidaysToCheck: [JewishHoliday] {
        return JewishHoliday.allCases
    }
}
