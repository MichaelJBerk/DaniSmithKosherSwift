//
//  JewishHoliday.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/20/23.
//

import Foundation

public enum JewishHoliday: Int, CaseIterable {
    private static let connections: [[JewishHoliday]] = [
        [.erevPesach, .pesach], [.erevShavuos, .shavuos], [.erevYomKippur, .yomKippur], [.erevRoshHashana, .roshHashana], [.erevSuccos, .succos], [.sheminiAtzeres, .simchasTorah]
    ]
    
    case erevPesach, pesach, cholHamoedPesach, pesachSheni, erevShavuos, shavuos, seventeenthOfTammuz, tishaBeav, tuBeav, erevRoshHashana, roshHashana, fastOfGedalia, erevYomKippur, yomKippur, erevSuccos, succos, cholHamoedSuccos, hoshanaRabba, sheminiAtzeres, simchasTorah, erevChanukah, chanukah, tenthOfTeves, tuBeshvat, fastOfEsther, purim, shushanPurim, purimKatan, erevRoshChodesh, roshChodesh, yomHashoah, yomHazikaron, yomHaatzmaut, yomYerushalaim, lagBaomer, shushanPurimKatan, isruChag
    
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
	public var transliteratedName: String {
		return HebrewDateFormatter.transliteratedHolidays[rawValue]
	}
}
