//
//  JewishMonth.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/19/23.
//

import Foundation

enum JewishMonth: Int {
    case nissan = 1
    case iyar
    case sivan
    case tammuz
    case av
    case elul
    case tishrei
    case cheshvan
    case kislev
    case teves
    case shevat
    case adar
    case adar2
    
    private static let monthMap: [Int: JewishMonth] = [
        8: .nissan,
        9: .iyar,
        10: .sivan,
        11: .tammuz,
        12: .av,
        13: .elul,
        1: .tishrei,
        2: .cheshvan,
        3: .kislev,
        4: .teves,
        5: .shevat,
//        6: .adar,
//        7: .adar2
    ]
    
    private static let rMonthMap = monthMap.swapKeyValues()
    
    static func fromSwiftCalMonth(month: Int, jewishDate: JewishDate) -> JewishMonth {
        if month == 7 || month == 6 {
            return jewishDate.isJewishLeapYear && month == 7 ? .adar2 : .adar
        }
        
        return monthMap[month]!
    }
    
    func toSwiftCalMonth(_ isJewishLeapYear: Bool) -> Int {
        if self == .adar || self == .adar2 {
            return isJewishLeapYear && self == .adar ? 6 : 7
        }
        
        return JewishMonth.rMonthMap[self]!
    }
}

extension Dictionary where Value : Hashable {
    func swapKeyValues() -> [Value : Key] {
        assert(Set(self.values).count == self.keys.count, "Values must be unique")
        var newDict = [Value : Key]()
        for (key, value) in self {
            newDict[value] = key
        }
        return newDict
    }
}
