//
//  JewishDateFormatterTests.swift
//  KosherSwift
//
//  Created by Michael Berk on 3/11/26.
//
import Testing 
import KosherSwift
import Foundation



struct JewishDateFormatterTests {

	@Test func testFormatDate() {

		#expect(JewishDate(date: .init(year: 2026, month: 3, day: 12)).formatted(.jewishDate) == "23 Adar 5786")
		let nisanDate = JewishDate(date: Date(year: 2026, month: 4, day: 12))
		#expect(nisanDate.formatted(.jewishDate.hebrew()) == "כ״ה ניסן תשפ״ו")
		#expect(nisanDate.formatted(.jewishDate.hebrew().localize()) == "כ״ה בניסן תשפ״ו")
		#expect(nisanDate.formatted(.jewishDate.hebrew().month()) == "ניסן")
		#expect(nisanDate.formatted(.jewishDate.hebrew().year()) == "תשפ״ו")
		#expect(nisanDate.formatted(.jewishDate.hebrew().day()) == "כ״ה")
		#expect(nisanDate.formatted(.jewishDate.hebrew().month().year()) == "ניסן תשפ״ו")
		#expect(nisanDate.formatted(.jewishDate.hebrew().day().month()) == "כ״ה ניסן")
		#expect(nisanDate.formatted(.jewishDate.hebrew().day().year()) == "כ״ה תשפ״ו")

		#expect(JewishDate(date: .init(year: 1955, month: 5, day: 30)).formatted(.jewishDate.year().hebrew()) == "תשט״ו")

		#expect(JewishDate(date: .init(year: 2022, month: 3, day: 15)).formatted(.jewishDate.month()) == "Adar II")

		#expect(JewishDate(withJewishYear: 5785, andMonth: .tishrei, andDay: 1).formatted(.jewishDate.localize()).contains("Tishrei"))
		
	}

}