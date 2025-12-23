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

		let loopMax = [JewishHoliday.purimKatan, .shushanPurimKatan].contains(yomTov) ? 1540 : 385
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
		let trueDays = [JewishHoliday.erevPesach, .erevShavuos, .erevSuccos, .erevYomKippur, .erevRoshHashana, .hoshanaRabba, .erevRoshChodesh, .erevChanukah]
		guard let cal = getNext(yomTov: yomTov, startingCal: JewishCalendar(date: .init(year: 2025, month: 12, day: 1))) else {
			Issue.record()
			return
		}
		if trueDays.contains(yomTov) {
			#expect(cal.isErevYomTov)
		} else {
			#expect(!cal.isErevYomTov)
		}
		if ![JewishHoliday.erevPesach, .erevSuccos, .erevShavuos, .erevYomKippur, .erevRoshHashana, .hoshanaRabba, .succos, .pesach, .roshHashana, .sheminiAtzeres].contains(cal.getCurrentChag()), cal.dow != .friday {
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

	// @Test func erevStuff() throws {
	// 	let cal = JewishCalendar(date: .init(year: 2025, month: 11, day: 19))
	// 	#expect(cal.isTomorrowShabbosOrYomTov)
	// }

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
