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
	///- ``CoreJewishCalendar/isYomTov``
	///- ``CoreJewishCalendar/isErevYomTovSheni``
    override public var isErevYomTov: Bool { isErevShavuos || isErevPesach || isErevSuccos || isErevRoshHashana || isErevYomKippur || isErevSuccos || isHoshanaRabba || isErevChanukah || isErevRoshChodesh || (isCholHamoedPesach && day == 20) }

    override var holidaysToCheck: [JewishHoliday] {
		return [.erevPesach2] + JewishHoliday.allCases.dropLast()
    }
	
	/// Returns `true` if the day has candle lighting.
	///
	/// This will return true on *Erev Shabbos*, *Erev Yom Tov*, the first day of *Rosh Hashana* and the first days of *Yom Tov* out of Israel. Unlike ``CoreJewishCalendar/isTomorrowShabbosOrYomTov``, it returns `false` on *Erev Rosh Chodesh* and *Erev Chanukah*
	/// - Returns: if the day has candle lighting.
	/// ## See Also
	/// - ``CoreJewishCalendar/isTomorrowShabbosOrYomTov``
    public override var hasCandleLighting: Bool {
        return (dow == .friday || (isErevYomTov && !(isErevRoshChodesh || isErevChanukah)) || isErevYomTovSheni)
    }
	
	var additionalChagCheckers: [JewishHoliday: (JewishCalendar) -> Bool] = [
		.erevPesach2: {cal in cal.isErevPesach2 }
	]
	
	///Returns if the day is *Erev* the "second days" of *Pesach*
	public var isErevPesach2: Bool {
		return isCholHamoedPesach && day == 20
	}
	
	override func checkForChag(_ holiday: JewishHoliday) -> Bool {
		let superVal = super.checkForChag(holiday)
		if !superVal {
			if let additionalChecker = additionalChagCheckers[holiday] {
				return additionalChecker(self)
			}
		}
		return superVal
	}
	
	/// Determine what Jewish holiday occurs on the given day
	///
	/// On occasions where multiple holidays occur on the same day, the holiday with the lower raw value will take precedence. For example, when _Rosh Chodesh_ occurs on _Chanukah_, it will returns _Chanukah_.
	/// >Note: ``JewishHoliday/erevPesach2`` is prioritized before other holidays, despite having a higher raw value
	/// - Returns: The ``JewishHoliday`` that occurs on the given day. If there's no holiday on the given day, it returns `nil`.
	public override func getCurrentChag() -> JewishHoliday? {
		super.getCurrentChag()
	}
	
	/// Determine what Jewish holidays occur on the given day
	///
	///On certain occasions, multiple holidays occur on the same day, and this method will return all of them. For example, when _Rosh Chodesh_ occurs on _Chanukah_. This method will return both ``JewishHoliday/roshChodesh`` and ``JewishHoliday/chanukah``, or both ``JewishHoliday/cholHamoedPesach`` and ``JewishHoliday/erevPesach2`` on the last day of _Chol Hamoed Pesach_
	/// - Returns: An array of ``JewishHoliday`` that occurs on the given day. If there are no holidays on the given day, it returns an empty array.
	public func getCurrentChagim() -> [JewishHoliday] {
		var chagim: [JewishHoliday] = []
		for yomTov in holidaysToCheck {
			if checkForChag(yomTov) {
				chagim.append(yomTov)
			}
		}
		return chagim
	}
	
	/// Returns the ``Parsha`` on the current week
	///
	/// Returns the ``Parsha`` on the current week regardless of wheher if it is the weekday or *Shabbos* (where the current *Shabbos*'s *Parsha* will be returned). This is unlike ``CoreJewishCalendar/getUpcomingParsha()`` that returns the following week's parsha on *Shabbos*. If the upcoming *Shabbos* is a *Yom Tov* and has no *Parsha* it will return ``Parsha/none`` (``CoreJewishCalendar/getUpcomingParsha()`` would return the following week's *parsha* instead).
	/// - Returns: the *parsha* on the current week
	public func currentWeekParsha() -> Parsha {
		let dayOfWeek = gregDate.weekday
		if dayOfWeek == DayOfWeek.saturday.rawValue {
			return getParsha()
		}
		
		let daysToShabbos = (DayOfWeek.saturday.rawValue - dayOfWeek + 7) % 7
		let newCalendar = self.advanced(byAdding: .day, value: daysToShabbos)
		return newCalendar.getParsha()
	}

}
