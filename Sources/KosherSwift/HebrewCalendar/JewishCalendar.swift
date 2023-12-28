//
//  JewishMonth.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/19/23.
//

import Foundation

class JewishCalendar: JewishDate {
    let isInIsrael: Bool
    let moladDate: MoladDate
    
    init(withJewishYear year: Int, andMonth month: JewishMonth, andDay day: Int, isInIsrael: Bool = false) {
        self.isInIsrael = isInIsrael
        self.moladDate = MoladDate.calculate(forJewishDate: JewishDate(withJewishYear: year, andMonth: month, andDay: day))

        super.init(withJewishYear: year, andMonth: month, andDay: day)
    }
    
    
    init(date: Date, isInIsrael: Bool = false) {
        //        let abs = JewishDate.gregorianDateToAbsDate(date: date)
        //        let jewishDate = JewishDate.absDateToJewishDate(absDate: abs)
        self.isInIsrael = isInIsrael
        self.moladDate = MoladDate.calculate(forJewishDate: JewishDate(date: date))

        super.init(date: date)
    }
    
    //    convenience init(gregYear year: Int, month: Int, day: Int, isInIsrael: Bool = false) {
    ////        let jewishDate = JewishDate.absDateToJewishDate(absDate: JewishDate.gregorianDateToAbsDate(year: year, month: month, day: day))
    //
    //        self.init(withJewishYear: jewishDate.year, andMonth: jewishDate.month, andDay: jewishDate.day, isInIsrael: isInIsrael)
    //    }
    
    func copy(year: Int? = nil, month: JewishMonth? = nil, day: Int? = nil, isInIsrael: Bool? = nil) -> JewishCalendar {
        JewishCalendar(withJewishYear: year ?? self.year, andMonth: month ?? self.month, andDay: day ?? self.day, isInIsrael: isInIsrael ?? self.isInIsrael)
    }
    
    var isBirkasHachama: Bool {
        let elapsedDays = jewishCalendarElapsedDays + daysSinceStartOfJewishYear
        
        return elapsedDays % Int(28.0 * 365.25) == 172
    }
    
    var tekufasTishreiElapsedDays: Int {
        let days = Double(jewishCalendarElapsedDays + (daysSinceStartOfJewishYear - 1)) + 0.5
        let solar = Double(year - 1) * 365.25
        
        return Int((days - solar).rounded(.down))
    }
    
    private func getParshaYearType() -> Int? {
        var rhDow = (jewishCalendarElapsedDays + 1) % 7
        if rhDow == 0 { rhDow = 7 }
        let compDow = DayOfWeek(rawValue: rhDow)!
        
        if isJewishLeapYear {
            switch compDow {
            case .monday:
                if isKislevShort {
                    return isInIsrael ? 14 : 6
                } else if isCheshvanLong {
                    return isInIsrael ? 15 : 7
                }
            case .tuesday:
                return isInIsrael ? 15 : 7
            case .thursday:
                if isKislevShort {
                    return 8
                } else if isCheshvanLong {
                    return 9
                }
            case .saturday:
                if isKislevShort {
                    return 10
                } else if isCheshvanLong {
                    return isInIsrael ? 16 : 11
                }
            default:
                return nil
            }
        } else {
            switch compDow {
            case .monday:
                if isKislevShort {
                    return 0
                } else if isCheshvanLong {
                    return isInIsrael ? 12 : 1
                }
            case .tuesday:
                return isInIsrael ? 12 : 1
            case .thursday:
                if isCheshvanLong {
                    return 3
                } else if !isKislevShort {
                    return isInIsrael ? 13 : 2
                }
            case .saturday:
                if isKislevShort {
                    return 4
                } else if isCheshvanLong {
                    return 5
                }
            default:
                return nil
            }
        }
        
        return nil
    }
    
    func getParsha() -> Parsha {
        if dow != .saturday {
            return .none
        }
        
        guard let yearType = getParshaYearType() else {
            return .none
        }
        
        let rhDow = jewishCalendarElapsedDays & 7
        let day = rhDow + daysSinceStartOfJewishYear
        
        return Parsha.parshalist[yearType][Int(day / 7)]
    }
    
    func getSpecialShabbos() -> Parsha {
        if dow != .saturday {
            return .none
        }
        
        if (month == .shevat && !isJewishLeapYear) || (month == .adar && isJewishLeapYear) {
            if [25, 27, 29].contains(day) {
                return .shkalim
            }
        }
        
        if (month == .adar && !isJewishLeapYear) || month == .adar2 {
            if day == 1 {
                return .shkalim
            } else if [8, 9, 11, 13].contains(day) {
                return .zachor
            } else if [18, 20, 22, 23].contains(day) {
                return .para
            } else if [25, 27, 29].contains(day) {
                return .hachodesh
            }
        }
        
        if month == .nissan && day == 1 {
            return .hachodesh
        }
        
        return .none
    }
    
    // Chagim checkers
    var isErevRoshChodesh: Bool { day == 29 && month != .elul }
    var isRoshChodesh: Bool { (day == 1 && month != .tishrei) || day == 30 }
    var isErevPesach: Bool { month == .nissan && day == 14 }
    var isPesach: Bool { month == .nissan && (day == 15 || day == 21 || (!isInIsrael && (day == 16 || day == 22))) }
    var isCholHamoedPesach: Bool { month == .nissan && (day >= 17 && day <= 20 || (day == 16 && isInIsrael)) }
    var isYomHashoah: Bool { month == .nissan && ((day == 26 && dow == .thursday) || (day == 28 && dow == .monday) || (day == 27 && dow != .sunday && dow != .friday))}
    var isYomHazikaron: Bool { month == .iyar && ((day == 4 && dow == .tuesday) || ((day == 3 || day == 2) && dow == .wednesday) || (day == 6 && dow == .tuesday)) }
    var isYomHaatzmaut: Bool { month == .iyar && ((day == 5 && dow == .wednesday) || (day == 6 && dow == .tuesday) || ((day == 4 || day == 3) && dow == .thursday)) }
    var isPesachSheni: Bool { month == .iyar && day == 14 }
    var isLagBaomer: Bool { month == .iyar && day == 18 }
    var isYomYerushalaim: Bool { month == .iyar && day == 28 }
    var isErevShavuos: Bool { month == .sivan && day == 5 }
    var isShavuos: Bool { month == .sivan && (day == 6 || (!isInIsrael && day == 7)) }
    var isSeventeenthOfTammuz: Bool { month == .tammuz && ((day == 17 && dow != .friday) || (day == 18 && dow == .sunday)) }
    var isTishaBeav: Bool { month == .av && ((day == 10 && dow == .sunday) || (day == 9 && dow != .saturday)) }
    var isTuBeav: Bool { month == .av && day == 15 }
    var isErevRoshHashana: Bool { month == .elul && day == 29 }
    var isRoshHashana: Bool { month == .tishrei && (day == 1 || day == 2) }
    var isFastOfGedalia: Bool { month == .tishrei && ((day == 3 && dow != .saturday) || (day == 4 && dow == .sunday)) }
    var isErevYomKippur: Bool { month == .tishrei && day == 9 }
    var isYomKippur: Bool { month == .tishrei && day == 10 }
    var isErevSuccos: Bool { month == .tishrei && day == 14 }
    var isSuccos: Bool { month == .tishrei && (day == 15 || (day == 16 && !isInIsrael)) }
    var isCholHamoedSuccos: Bool { month == .tishrei && ((day >= 17 && day <= 20) || (day == 16 && isInIsrael)) }
    var isHoshanaRabba: Bool { month == .tishrei && day == 21 }
    var isSheminiAtzeres: Bool { month == .tishrei && day == 22 }
    var isSimchasTorah: Bool { month == .tishrei && day == 23 && !isInIsrael }
    var isErevChanukah: Bool { month == .kislev && day == 24 } // TODO formatting
    var isChanukah: Bool { (month == .kislev && day >= 25) || (month == .teves && ((day == 1 || day == 2) || (day == 3 && isKislevShort)))}
    var isTenthOfTeves: Bool { month == .teves && day == 10 }
    var isTuBeshvat: Bool { month == .shevat && day == 15 }
    var isFastOfEsther: Bool { (!isJewishLeapYear && month == .adar && ((day == 11 || day == 12) && dow == .thursday) || (day == 13 && !(dow == .friday || dow == .saturday))) || (isJewishLeapYear && month == .adar2 && (((day == 11 || day == 12) && dow == .thursday) || (day == 13 && !(dow == .friday || dow == .saturday)))) }
    var isPurim: Bool { (!isJewishLeapYear && month == .adar && day == 14) || (isJewishLeapYear && month == .adar2 && day == 14) }
    var isShushanPurim: Bool { (!isJewishLeapYear && month == .adar && day == 15) || (isJewishLeapYear && month == .adar2 && day == 15) }
    var isPurimKatan: Bool { isJewishLeapYear && month == .adar && day == 14 }
    var isShushanPurimKatan: Bool { isJewishLeapYear && month == .adar && day == 15 }
    
    private static let chagCheckers: [JewishHoliday: (JewishCalendar) -> Bool] = [
        .erevPesach: { cal in cal.isErevPesach },
        .pesach: { cal in cal.isPesach },
        .cholHamoedPesach: { cal in cal.isCholHamoedPesach },
        .pesachSheni: { cal in cal.isPesachSheni },
        .erevShavuos: { cal in cal.isErevShavuos },
        .shavuos: { cal in cal.isShavuos },
        .seventeenthOfTammuz: { cal in cal.isSeventeenthOfTammuz },
        .tishaBeav: { cal in cal.isTishaBeav },
        .tuBeav: { cal in cal.isTuBeav },
        .erevRoshHashana: { cal in cal.isErevRoshHashana },
        .roshHashana: { cal in cal.isRoshHashana },
        .fastOfGedalia: { cal in cal.isFastOfGedalia },
        .erevYomKippur: { cal in cal.isErevYomKippur },
        .yomKippur: { cal in cal.isYomKippur },
        .erevSuccos: { cal in cal.isErevSuccos },
        .succos: { cal in cal.isSuccos },
        .cholHamoedSuccos: { cal in cal.isCholHamoedSuccos },
        .hoshanaRabba: { cal in cal.isHoshanaRabba },
        .sheminiAtzeres: { cal in cal.isSheminiAtzeres },
        .simchasTorah: { cal in cal.isSimchasTorah },
        .chanukah: { cal in cal.isChanukah },
        .tenthOfTeves: { cal in cal.isTenthOfTeves },
        .tuBeshvat: { cal in cal.isTuBeshvat },
        .fastOfEsther: { cal in cal.isFastOfEsther },
        .purim: { cal in cal.isPurim },
        .shushanPurim: { cal in cal.isShushanPurim },
        .purimKatan: { cal in cal.isPurimKatan },
        .erevRoshChodesh: { cal in cal.isErevRoshChodesh },
        .roshChodesh: { cal in cal.isRoshChodesh },
        .yomHashoah: { cal in cal.isYomHashoah },
        .yomHazikaron: { cal in cal.isYomHazikaron },
        .yomHaatzmaut: { cal in cal.isYomHaatzmaut },
        .yomYerushalaim: { cal in cal.isYomYerushalaim },
        .lagBaomer: { cal in cal.isLagBaomer },
        .shushanPurimKatan: { cal in cal.isShushanPurimKatan }
    ]
    
    func getCurrentChag() -> JewishHoliday? {
        for checker in JewishCalendar.chagCheckers {
            if checker.value(self) {
                return checker.key
            }
        }
        
        return nil
    }
    
    var isYomTov: Bool {
        guard let _ = getCurrentChag() else {
            return false
        }
        
        if (isErevYomTov && (!isHoshanaRabba && (isCholHamoedPesach && day != 20) || isTaanis && !isYomKippur)) {
            return false
        }
        
        return true
    }
    
    var isYomTovAssurBemelacha: Bool { isPesach || isShavuos || isSuccos || isSheminiAtzeres || isSimchasTorah || isRoshHashana || isYomKippur }
    
    var isAssurBemelacha: Bool { dow == .saturday || isYomTovAssurBemelacha }
    
    var isTomorrowShabbosOrYomTov: Bool { dow == .friday || isErevYomTov || isErevYomTovSheni }
    
    var isErevYomTovSheni: Bool {
        if month == .tishrei && day == 1 {
            return true
        }
        
        if isInIsrael { return false }
        
        if month == .nissan {
            return day == 15 || day == 21
        } else if month == .tishrei {
            return day == 15 || day == 22
        } else if month == .sivan {
            return day == 6
        }
        
        return false
    }
    
    var isAseresYemeiTeshuva: Bool { month == .tishrei && day <= 10 }
    
    var isCholHamoed: Bool { isCholHamoedPesach || isCholHamoedSuccos }
    
    var isErevYomTov: Bool { isErevPesach || isErevSuccos || isErevRoshHashana || isErevYomKippur || isErevSuccos || isHoshanaRabba || (isCholHamoedPesach && day == 20) }
    
    var isTaanis: Bool { isSeventeenthOfTammuz || isTishaBeav || isYomKippur || isFastOfEsther || isFastOfGedalia || isTenthOfTeves }
    
    var isTaanisBechoros: Bool { month == .nissan && ((day == 14 && dow != .saturday) || (day == 12 && dow == .thursday)) }
    
    var dayOfChanukah: Int? {
        if !isChanukah { return nil }
        
        if month == .kislev {
            return day - 24
        } else {
            return isKislevShort ? day + 5 : day + 6
        }
    }
    
    var isMacharChodesh: Bool { dow == .saturday && (day == 30 || day == 29) }
    
    var isShabbosMevorchim: Bool { dow == .saturday && month != .elul && day >= 23 && day <= 29 }
    
    var dayOfOmer: Int? {
        if month == .nissan && day >= 16 {
            return day - 15
        } else if month == .iyar {
            return day + 15
        } else if month == .sivan && day < 6 {
            return day + 44
        }
        
        return nil
    }

    var earliestKiddushLevana3Days: Date? { moladDate.gregDate.withAdded(days: 3) }
    var earliestKiddushLevana7Days: Date? { moladDate.gregDate.withAdded(days: 7) }
    var latestZmanKidushLevanaBetweenMoldos: Date? { moladDate.gregDate.withAdded(days: 14, hours: 18, minutes: 22, seconds: 1, milliseconds: 666) }
    var latestKiddushLevana15Days: Date? { moladDate.gregDate.withAdded(days: 15) }
    
    // TODO
    //    var dafYomiYerushalmi: Daf {}
    
    var dafYomiBavli: Daf? { DafYomiCalculator.getDafYomiBavli(jewishCalendar: self) }
    
    var isMashivHaruachRecited: Bool {
        let start = JewishDate(withJewishYear: year, andMonth: .tishrei, andDay: 22)
        let end = JewishDate(withJewishYear: year, andMonth: .nissan, andDay: 15)
        
        return gregDate > start.gregDate && gregDate < end.gregDate
    }
    
    var isVeseinTalUmatarRecited: Bool {
        if month == .nissan && day < 15 {
            return true
        } else if month.rawValue < JewishMonth.cheshvan.rawValue {
            return false
        } else if isInIsrael {
            return month != .cheshvan || day >= 7
        }
        
        return tekufasTishreiElapsedDays >= 47
    }
    
    var isMashivHaruachStartDate: Bool { return month == .tishrei && day == 22 }
    var isMashivHaruachEndDate: Bool { return month == .nissan && day == 15 }
    
    var isVeseinBerachaRecited: Bool { !isVeseinTalUmatarRecited }
    var isMoridHatalRecited: Bool { !isMashivHaruachRecited || isMashivHaruachStartDate || isMashivHaruachEndDate }
}
