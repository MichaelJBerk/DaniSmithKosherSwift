//
//  ZmanimCalendarTests.swift
//  KosherSwift
//
//  Created by Michael Berk on 1/13/26
//
import Testing
import KosherSwift
import Foundation

struct ZmanimCalendarTests {
	let nycLocation = GeoLocation(lat: 40.7580, lng: -73.9855, timezone: .init(identifier: "America/New_York")!)


	typealias NextHavdalaArguments = (startDate: Date, expectedDate: Date, inIsrael: Bool)
	@Test(arguments: [
		NextHavdalaArguments(
			startDate: Date(year: 2026, month: 1, day: 11),
			expectedDate: Date(year: 2026, month: 1, day: 17),
			inIsrael: false
		),
		NextHavdalaArguments(
			startDate: Date(year: 2026, month: 3, day: 31),
			expectedDate: Date(year: 2026, month: 4, day: 4),
			inIsrael: false
		),
		NextHavdalaArguments(
			startDate: Date(year: 2026, month: 5, day: 21),
			expectedDate: Date(year: 2026, month: 5, day: 23),
			inIsrael: false
		),
		NextHavdalaArguments(
			startDate: Date(year: 2026, month: 9, day: 11),
			expectedDate: Date(year: 2026, month: 9, day: 13),
			inIsrael: false	
		),
		NextHavdalaArguments(
			startDate: Date(year: 2025, month: 4, day: 11),
			expectedDate: Date(year: 2025, month: 4, day: 14),
			inIsrael: false
		),
		NextHavdalaArguments(
			startDate: Date(year: 2026, month: 1, day: 11),
			expectedDate: Date(year: 2026, month: 1, day: 17),
			inIsrael: true
		),
		NextHavdalaArguments(
			startDate: Date(year: 2026, month: 3, day: 31),
			expectedDate: Date(year: 2026, month: 4, day: 2),
			inIsrael: true
		),
		NextHavdalaArguments(
			startDate: Date(year: 2026, month: 5, day: 21),
			expectedDate: Date(year: 2026, month: 5, day: 23),
			inIsrael: true
		),
		NextHavdalaArguments(
			startDate: Date(year: 2026, month: 9, day: 11),
			expectedDate: Date(year: 2026, month: 9, day: 13),
			inIsrael: true
		),
		NextHavdalaArguments(
			startDate: Date(year: 2025, month: 4, day: 11),
			expectedDate: Date(year: 2025, month: 4, day: 13),
			inIsrael: true
		),
	])
	func testNextHavdala(arguments: NextHavdalaArguments) {
		var actualDate = arguments.startDate
		while (actualDate != arguments.expectedDate) {
			let actualHavdala = ZmanimCalendar(location: nycLocation, date: actualDate).nextHavdala(inIsreal: arguments.inIsrael)
			let expectedHavdala = ZmanimCalendar(location: nycLocation, date: arguments.expectedDate).havdalah()
			#expect(actualHavdala == expectedHavdala)	
			actualDate = Calendar.current.date(byAdding: .day, value: 1, to: actualDate)!
		}
	}


}
