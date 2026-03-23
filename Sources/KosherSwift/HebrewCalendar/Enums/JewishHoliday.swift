//
//  JewishHoliday.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/20/23.
//

import Foundation

///A type with a Hebrew, Transliterated, and abbreviated Hebrew name
public protocol HebrewNameRepresentable: Codable {
	///Transliteration of the Hebrew name in English
	var transliteratedName: String {get}
	///Main Hebrew string for the type
	var hebrewName: String {get}
	///Abbreviated Hebrew name of the type
	var hebrewShortName: String {get}
}

///Basic structure conforming to the ``HebrewNameRepresentable`` protocol
public struct HebrewName: HebrewNameRepresentable, Sendable {
	public var transliteratedName: String
	public var hebrewName: String
	public var hebrewShortName: String
}

private struct JewishHolidaysFile: Codable {
	var holidays: [HebrewName]
}

public enum JewishHoliday: Int, CaseIterable, HebrewNameRepresentable, Sendable {
    private static let connections: [[JewishHoliday]] = [
        [.erevPesach, .pesach], [.erevShavuos, .shavuos], [.erevYomKippur, .yomKippur], [.erevRoshHashana, .roshHashana], [.erevSuccos, .succos], [.sheminiAtzeres, .simchasTorah]
    ]
	
	public static let holidayStrings: [HebrewName] = {
		let stringsURL = Bundle.module.url(forResource: "HolidayStrings", withExtension: "json")!
		let holidayData = try! Data(contentsOf: stringsURL)
		let holidayFile = try! JSONDecoder().decode(JewishHolidaysFile.self, from: holidayData)
		return holidayFile.holidays
	}()
    
    case erevPesach, pesach, cholHamoedPesach, pesachSheni, erevShavuos, shavuos, seventeenthOfTammuz, tishaBeav, tuBeav, erevRoshHashana, roshHashana, fastOfGedalia, erevYomKippur, yomKippur, erevSuccos, succos, cholHamoedSuccos, hoshanaRabba, sheminiAtzeres, simchasTorah, erevChanukah, chanukah, tenthOfTeves, tuBeshvat, fastOfEsther, purim, shushanPurim, purimKatan, roshChodesh, yomHashoah, yomHazikaron, yomHaatzmaut, yomYerushalaim, lagBaomer, shushanPurimKatan, isruChag, erevRoshChodesh
	///*Erev* the "second days" of _Pesach_
	case erevPesach2
    
    /// If a erev chag is passed in, return true if this is a non-erev version and vis versa.
    public func isErevConnection(_ other: JewishHoliday) -> Bool {
        for connection in Self.connections {
            if connection.contains(self), connection.contains(other) {
                return true
            }
        }
        
        return false
    }
	
	///Name of the Holiday, transliterated into English
	///
	///This uses Ashkenazi pronunciation in typical American English spelling.
	public var transliteratedName: String {
		return JewishHoliday.holidayStrings[rawValue].transliteratedName
	}
	///Name of the Holiday, in Hebrew
	public var hebrewName: String {
		return JewishHoliday.holidayStrings[rawValue].hebrewName
	}
	///Name of the Holiday, in Hebrew, abbreviated
	public var hebrewShortName: String {
		return JewishHoliday.holidayStrings[rawValue].hebrewShortName
	}
	
	///Determines if the Holiday is _erev_.
	public var isErev: Bool {
		[JewishHoliday.erevPesach, .erevShavuos, .erevRoshHashana, .erevYomKippur, .erevSuccos, .erevChanukah, .erevRoshChodesh].contains(self)
	}
	
	///Determine if the Holiday has a *melacha* (work)  prohibition
	public var isAsurBemelacha: Bool {
		[JewishHoliday.pesach, .shavuos, .succos, .sheminiAtzeres, .simchasTorah, .roshHashana, .yomKippur].contains(self)
	}
	
	///All holidays, excluding those added by KosherSwift
	public static var javaHolidays: [JewishHoliday] {
		return [.erevPesach, .pesach, .cholHamoedPesach, .pesachSheni, .erevShavuos, .shavuos, .seventeenthOfTammuz, .tishaBeav, .tuBeav, .erevRoshHashana, .roshHashana, .fastOfGedalia, .erevYomKippur, .yomKippur, .erevSuccos, .succos, .cholHamoedSuccos, .hoshanaRabba, .sheminiAtzeres, .simchasTorah, .chanukah, .tenthOfTeves, .tuBeshvat, .fastOfEsther, .purim, .shushanPurim, .purimKatan, .roshChodesh, .yomHashoah, .yomHazikaron, .yomHaatzmaut, .yomYerushalaim, .lagBaomer, .shushanPurimKatan, .isruChag]
	}
	
	public static var kosherSwiftHolidays: [JewishHoliday] {
		return [.erevChanukah, .erevRoshChodesh, .erevPesach2]
	}

}
