//
//  Test.swift
//  KosherSwift
//
//  Created by Michael Berk on 12/22/25.
//

import Testing
import KosherSwift
import Foundation

protocol JewishCalendarTestProtocol { }

extension JewishCalendarTestProtocol {
	func _testNextYomTov(yomTov: JewishHoliday, startingCal: CoreJewishCalendar) {
		let falseDays: [JewishHoliday] = [.erevPesach, .erevShavuos, .erevRoshChodesh, .erevSuccos, .erevChanukah, .erevRoshHashana, .erevYomKippur, .seventeenthOfTammuz, .tenthOfTeves, .fastOfGedalia, .fastOfEsther, .tishaBeav, .isruChag]
		guard let cal = getNext(yomTov: yomTov, startingCal: startingCal) else {
			Issue.record()
			return
		}

		var expectTrue = !falseDays.contains(yomTov)

		if yomTov == .erevPesach && cal.isCholHamoed {
			expectTrue = false
		}
		if expectTrue {
			#expect(cal.isYomTov)
		} else {
			#expect(!cal.isYomTov)
		}
	}

	func getNext(yomTov: JewishHoliday, startingCal: CoreJewishCalendar) -> CoreJewishCalendar? {
		var cal = startingCal
		var loop = true
		var loopAmount = 0

		let loopMax = [JewishHoliday.purimKatan, .shushanPurimKatan].contains(yomTov) ? 1540 : 386
		while loop {
			cal = cal.advanced(byAdding: .day, value: 1)
			loop = cal.getCurrentChag() != yomTov
			loopAmount += 1
			if loopAmount >= loopMax {
				return nil
			}
		}
		return cal
	}
}

struct JewishCalendarTests: JewishCalendarTestProtocol {
	
	@Test(arguments: JewishHoliday.allCases)
	func testNextYomTov(yomTov: JewishHoliday) {
		_testNextYomTov(yomTov: yomTov, startingCal: JewishCalendar(date: .now))

		// Write your test here and use APIs like `#expect(...)` to check expected conditions.
	}
	@Test(arguments: JewishHoliday.allCases)
	func testErev(yomTov: JewishHoliday) throws {
		let trueDays = [JewishHoliday.erevPesach2, .erevPesach, .erevShavuos, .erevSuccos, .erevYomKippur, .erevRoshHashana, .hoshanaRabba, .erevRoshChodesh, .erevChanukah]
		guard let cal = getNext(yomTov: yomTov, startingCal: JewishCalendar(date: .init(year: 2025, month: 12, day: 1))) else {
			Issue.record()
			return
		}
		if trueDays.contains(yomTov) {
			#expect(cal.isErevYomTov)
		} else {
			#expect(!cal.isErevYomTov)
		}
		if ![JewishHoliday.erevPesach2, .erevPesach, .erevSuccos, .erevShavuos, .erevYomKippur, .erevRoshHashana, .hoshanaRabba, .succos, .pesach, .roshHashana, .sheminiAtzeres].contains(cal.getCurrentChag()), cal.dow != .friday {
			#expect(!cal.hasCandleLighting)
		}

	}

	@Test
	func testHasCandleLighting() throws {
		let calendar = Calendar.current

		var now = Date(year: 2025, month: 1, day: 1)

		let endDate = calendar.date(byAdding: .year, value: 20, to: now)!
		while now != endDate {
			let cal = JewishCalendar(date: now)
			let yt = cal.getCurrentChag()
			if [JewishHoliday.erevPesach, .erevSuccos, .erevShavuos, .erevYomKippur, .erevRoshHashana, .hoshanaRabba, .sheminiAtzeres].contains(yt) || cal.dow == .friday || (cal.isCholHamoedPesach && cal.day == 20) || [JewishHoliday.pesach, .shavuos, .roshHashana, .succos].contains(yt) && cal.isErevYomTovSheni {
				#expect(cal.hasCandleLighting, "Failed on \(now) \(cal.getCurrentChag())")
			} else {
				#expect(!cal.hasCandleLighting, "Failed on \(now) \(cal.getCurrentChag())")
			}
			now = calendar.date(byAdding: .day, value: 1, to: now)!
		}
	}
	@Test func testErevPeach2() throws {
		var cal = JewishCalendar(date: Date(year: 2024, month: 4, day: 28))
		#expect(cal.isErevPesach2)
		#expect(cal.getCurrentChagim() == [.erevPesach2, .cholHamoedPesach])
		#expect(cal.getCurrentChag() == .erevPesach2)
		let hdf = HebrewDateFormatter()
		#expect(try hdf.formatYomTov(cal) == JewishHoliday.erevPesach2.transliteratedName)
		cal = JewishCalendar(date: Date(year: 2024, month: 4, day: 26))
		#expect(try hdf.formatYomTov(cal) == JewishHoliday.cholHamoedPesach.transliteratedName)
	}

	typealias CurrentWeekParshaArgs = (date: Date, parsha: Parsha)

	//TODO: Test inIsrael
	@Test(arguments: [
		CurrentWeekParshaArgs(date: Date(year: 2026, month: 1, day: 13), parsha: .vaera),
		CurrentWeekParshaArgs(date: Date(year: 2026, month: 3, day: 31), parsha: .none),
		CurrentWeekParshaArgs(date: Date(year: 2026, month: 4, day: 5), parsha: .shmini),
	]) func currentWeekParshaTest(arguments: CurrentWeekParshaArgs) throws {
		#expect(JewishCalendar(date: arguments.date, isInIsrael: false).currentWeekParsha() == arguments.parsha)
	}

	// @Test func erevStuff() throws {
	// 	let cal = JewishCalendar(date: .init(year: 2025, month: 11, day: 19))
	// 	#expect(cal.isTomorrowShabbosOrYomTov)
	// }
	
	@Test
	func testMonthlyTehillimNotEmpty() {
		var cal = JewishCalendar(withJewishYear: 5786, andMonth: .tishrei, andDay: 1, isInIsrael: false)
		while cal.year == 5786 {
			#expect(cal.monthlyTehillim.isEmpty == false)
			cal = cal.advanced(byAdding: .day, value: 1)
		}
	}
	
	@Test
	func testMonthlyTehillimDay29() {
		let cal1Iyar = JewishCalendar(withJewishYear: 5786, andMonth: .iyar, andDay: 1, isInIsrael: false)
		#expect(cal1Iyar.monthlyTehillim == [1,2,3,4,5,6,7,8,9])
		let cal29Iyar = JewishCalendar(withJewishYear: 5786, andMonth: .iyar, andDay: 29, isInIsrael: false)
		#expect(cal29Iyar.monthlyTehillim == [140,141,142,143,144,145,146,147,148,149,150])
		let cal29Sivan = JewishCalendar(withJewishYear: 5786, andMonth: .sivan, andDay: 29, isInIsrael: false)
		#expect(cal29Sivan.monthlyTehillim == [140,141,142,143,144])
		let cal30Sivan = JewishCalendar(withJewishYear: 5786, andMonth: .sivan, andDay: 30, isInIsrael: false)
		#expect(cal30Sivan.monthlyTehillim == [145,146,147,148,149,150])
	}

}

struct CoreJewishCalendarTests: JewishCalendarTestProtocol {

	@Test(arguments: JewishHoliday.javaHolidays)
	func testNextYomTov(yomTov: JewishHoliday) throws {
		_testNextYomTov(yomTov: yomTov, startingCal: CoreJewishCalendar(date: .now))
		
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
	@Test(arguments: JewishHoliday.allCases)
	func testErev(yomTov: JewishHoliday) throws {
		let trueDays = [JewishHoliday.erevPesach, .erevShavuos, .erevSuccos, .erevYomKippur, .erevRoshHashana, .hoshanaRabba]
		guard let cal = getNext(yomTov: yomTov, startingCal: CoreJewishCalendar(date: .now)) else {
			if !JewishHoliday.javaHolidays.contains(yomTov) {
				return
			}
			Issue.record()
			return
		}

		if trueDays.contains(yomTov) {
			#expect(cal.isErevYomTov)
		} else {
			#expect(!cal.isErevYomTov)
		}

	}
	
	///Test that erev chanukah and erev rosh chodesh aren't erev yom tov
	@Test(arguments: [JewishHoliday.erevChanukah, .erevRoshChodesh]) 
	func testErevCore(yomTov: JewishHoliday) throws {
		guard let nextErevDate = getNext(yomTov: yomTov, startingCal: JewishCalendar(date: .now))?.gregDate else {
			Issue.record()
			return
		}
		let cal = CoreJewishCalendar(date: nextErevDate)
		#expect(!cal.isErevYomTov)



	}

	@Test
	func testHasCandleLighting() throws {
		let calendar = Calendar.current

		var now = Date(year: 2025, month: 1, day: 1)

		let endDate = calendar.date(byAdding: .year, value: 20, to: now)!
		while now != endDate {
			let cal = CoreJewishCalendar(date: now)
			let yt = cal.getCurrentChag()
			if [JewishHoliday.erevPesach, .erevSuccos, .erevShavuos, .erevYomKippur, .erevRoshHashana, .hoshanaRabba, .sheminiAtzeres].contains(yt) || cal.dow == .friday || (cal.isCholHamoedPesach && cal.day == 20) || [JewishHoliday.pesach, .shavuos, .roshHashana, .succos].contains(yt) && cal.isErevYomTovSheni {
				#expect(cal.hasCandleLighting, "Failed on \(now) \(cal.getCurrentChag())")
			} else {
				#expect(!cal.hasCandleLighting, "Failed on \(now) \(cal.getCurrentChag())")
			}
			now = calendar.date(byAdding: .day, value: 1, to: now)!
		}
	}

}
