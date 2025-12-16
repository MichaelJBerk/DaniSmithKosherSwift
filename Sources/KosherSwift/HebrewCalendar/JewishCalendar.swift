//
//  JewishMonth.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/19/23.
//

import Foundation

///A class that calculates the dates for Jewish holidays, Daf Yomi, and more
public class JewishCalendar: JewishDate {
	///A Boolean value indicating whether or not the user is in Israel, where different rules may apply
    public let isInIsrael: Bool
	
    public let moladDate: MoladDate?
    
	/// Create a Jewish calendar based on the specified Jewish year, month, and day
	/// - Parameters:
	///   - year: the Jewish year
	///   - month: the Jewish month
	///   - day: The day of the Jewish month.
	///   - isInIsrael: whether or not the user is in Israel, which affects _Yom Tov_ calculations
	///
	/// If 30 is passed in for a month with only 29 days (for example ``JewishMonth/iyar``, or ``JewishMonth/kislev`` in a year with a short kislev),  the date will be converted to the following day (i.e. the 1st of ``JewishMonth/sivan`` or ``JewishMonth/teves``)
    public convenience init(withJewishYear year: Int, andMonth month: JewishMonth, andDay day: Int, isInIsrael: Bool = false) {
        var hebCal = Calendar(identifier: .hebrew)
        hebCal.timeZone = Calendar.current.timeZone
        
        let newMonth = month.toSwiftCalMonth(JewishDate.isJewishLeapYear(year))
        let gregDate = hebCal.date(from: DateComponents(year: year, month: newMonth, day: day))!
        self.init(date: gregDate, isInIsrael: isInIsrael)
    }
    
    
    public init(date: Date, includeTime: Bool = false, isInIsrael: Bool = false) {
        self.isInIsrael = isInIsrael
        self.moladDate = MoladDate.calculate(forJewishDate: JewishDate(date: date))

        super.init(date: date, includeTime: includeTime)
    }
    
    public func copy(year: Int? = nil, month: JewishMonth? = nil, day: Int? = nil, isInIsrael: Bool? = nil) -> JewishCalendar {
        JewishCalendar(withJewishYear: year ?? self.year, andMonth: (month ?? self.month), andDay: day ?? self.day, isInIsrael: isInIsrael ?? self.isInIsrael)
    }
    
    public func copy(date: Date, includeTime: Bool = false, isInIsrael: Bool? = nil) -> JewishCalendar{
        JewishCalendar(date: date, includeTime: includeTime, isInIsrael: isInIsrael ?? self.isInIsrael)
    }
    ///Determine if Birkas Hachama is said on the current day
	///
	/// [Birkas Hachamah](https://en.wikipedia.org/wiki/Birkat_Hachama) is recited every 28 years based on *Tekufas Shmuel* (Julian years) that a year is 365.25 days. The Rambam in [Hilchos Kiddush Hachodesh 9:3](http://hebrewbooks.org/pdfpager.aspx?req=14278&st=&pgnum=323) states that *tekufas Nissan* of year 1 was 7 days + 9 hours before *molad Nissan*. This is calculated as every 10,227 days (28 * 365.25).
    public var isBirkasHachama: Bool {
        let elapsedDays = jewishCalendarElapsedDays + daysSinceStartOfJewishYear
        
        return elapsedDays % Int(28.0 * 365.25) == 172
    }

	/// Returns the elapsed days since *Tekufas Tishrei*.
	///
	/// This uses *Tekufas Shmuel* (identical to the [Julian Year](https://en.wikipedia.org/wiki/Julian_year_(astronomy)) with a solar year length of 365.25 days).
	/// >Example:
	/// The notation used below is `D = days`, `H = hours` and `C = chalakim`. *[Molad](https://en.wikipedia.org/wiki/Molad) BaHaRad* was 2D,5H,204C or 5H,204C from the start of *Rosh Hashana* year 1. For *molad Nissan* add 177D, 4H and 438C (6 \* 29D, 12H and 793C), or 177D,9H,642C after *Rosh Hashana* year 1. *Tekufas Nissan* was 7D, 9H and 642C before *molad Nissan* according to the Rambam, or 170D, 0H and 0C after *Rosh Hashana* year 1. *Tekufas Tishrei* was 182D and 3H (365.25 / 2) before *tekufas Nissan*, or 12D and 15H before *Rosh Hashana* of year 1. Outside of Israel we start reciting *Tal Umatar* in *Birkas Hashanim* from 60 days after *tekufas Tishrei*. The 60 days include the day of the *tekufah* and the day we start reciting *Tal Umatar*. 60 days from the tekufah == 47D and 9H from *Rosh Hashana* year 1.
	/// - Returns: the number of elapsed days since *tekufas Tishrei*.
	/// ## See Also
	///- ``isVeseinTalUmatarRecited``
    public var tekufasTishreiElapsedDays: Int {
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
	/// Returns this week's ``Parsha`` if it is *Shabbos*.
	///
	/// It returns ``Parsha/none`` if the date is a weekday or if there is no *parsha* that week (for example *Yom Tov* that falls on a *Shabbos*).
	/// - Returns: the current *parsha*.
    public func getParsha() -> Parsha {
        if dow != .saturday {
            return .none
        }
        
        guard let yearType = getParshaYearType() else {
            return .none
        }
        
        let rhDow = jewishCalendarElapsedDays % 7
        let day = rhDow + daysSinceStartOfJewishYear
        
        return Parsha.parshalist[yearType][Int(day / 7)]
    }

	/// Returns the upcoming ``Parsha``
	///
	/// Returns the upcoming ``Parsha`` regardless of if it is the weekday or *Shabbos* (where next Shabbos's *Parsha* will be returned. This is unlike ``getParsha()`` that returns ``Parsha/none`` if the date is not *Shabbos*. If the upcoming *Shabbos* is a *Yom Tov* and has no *Parsha*, the following week's *Parsha* will be returned.
	/// - Returns: the upcoming *parsha*.
    public func getUpcomingParsha() -> Parsha {
        var newCalendar: JewishCalendar
        let dayOfWeek = gregDate.weekday
        let daysToShabbos = (DayOfWeek.saturday.rawValue - dayOfWeek + 7) % 7
        if dayOfWeek != DayOfWeek.saturday.rawValue {
            let newDate = Calendar.current.date(byAdding: .day, value: daysToShabbos, to: gregDate)!
            newCalendar = self.copy(date: newDate)
        } else {
            let newDate = Calendar.current.date(byAdding: .day, value: 7, to: gregDate)!
            newCalendar = self.copy(date: newDate)
        }
        while newCalendar.getParsha() == .none {
            let newDate = Calendar.current.date(byAdding: .day, value: 7, to: newCalendar.gregDate)!
            newCalendar = newCalendar.copy(date: newDate)
        }
        return newCalendar.getParsha()
    }
    
	/// Returns this week's upcoming ``Parsha``
	///
	/// Returns the upcoming ``Parsha`` regardless of if it is the weekday or *Shabbos* (where next Shabbos's *Parsha* will be returned).  This is unlike ``getParsha()`` that returns ``Parsha/none`` if the date is not *Shabbos*. If the upcoming *Shabbos* is a *Yom Tov* and has no *Parsha*, the following week's *Parsha* will be returned.
	/// - Returns: the upcoming *parsha*.
	@available(*, deprecated, renamed: "getUpcomingParsha", message: "Use GetUpcomingParsha instead, since it more closely follows KosherJava.")
    public func getWeeklyParsha() -> Parsha {
        if dow == .saturday {
            return getParsha()
        }
        
        var nextShabbos = gregDate.next(.saturday)
        var cal = JewishCalendar(date: nextShabbos, isInIsrael: isInIsrael)
        
        while cal.getParsha() == .none {
            nextShabbos = gregDate.next(.saturday)
            cal = JewishCalendar(date: nextShabbos, isInIsrael: isInIsrael)
        }
        
        return cal.getParsha()
    }
	
	//TODO: Implement hagadol, chazon, nachamu, shuva, and shira
	///Returns the week's special Shabbos ``Parsha`` if it is *Shabbos*
	///
	///Returns a ``Parsha`` enum if the *Shabbos* is one of the four *parshiyos* of {@link Parsha#SHKALIM *Shkalim*}, {@link Parsha#ZACHOR *Zachor*}, {@link Parsha#PARA *Para*}, {@link Parsha#HACHODESH *Hachdesh*}, or five other special *Shabbasos* of {@link Parsha#HAGADOL *Hagadol*}, {@link Parsha#CHAZON *Chazon*}, {@link Parsha#NACHAMU *Nachamu*}, {@link Parsha#SHUVA *Shuva*}, {@link Parsha#SHIRA *Shira*}, or {@link Parsha#NONE Parsha.NONE} for a regular *Shabbos* (or any weekday).
	/// - Returns: one of the four *parshiyos* of ``Parsha/shkalim``, ``Parsha/zachor``, ``Parsha/para``, ``Parsha/hachodesh``, or five other special *Shabbasos* of {@link Parsha#HAGADOL *Hagadol*}, {@link Parsha#CHAZON *Chazon*}, {@link Parsha#NACHAMU *Nachamu*}, {@link Parsha#SHUVA *Shuva*}, {@link Parsha#SHIRA *Shira*}, or {@link Parsha#NONE Parsha.NONE} for a regular *Shabbos* (or any weekday).
    public func getSpecialShabbos() -> Parsha {
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
    
    //MARK: - Chagim checkers
	/// Returns if the current day is *Erev Rosh Chodesh*.
	///
	/// Returns `false` for *Erev Rosh Hashana*.
    public var isErevRoshChodesh: Bool { day == 29 && month != .elul }
	///Returns if the day is *Rosh Chodesh*.
	///
	///*Rosh Hashana* will return `false`
    public var isRoshChodesh: Bool { (day == 1 && month != .tishrei) || day == 30 }
	///Returns if the day is *Erev Pesach*
    public var isErevPesach: Bool { month == .nissan && day == 14 }
	/// Returns if the current day is *Pesach* (either  the *Yom Tov* of *Pesach* or *Chol Hamoed Pesach*).
    public var isPesach: Bool { month == .nissan && (day == 15 || day == 21 || (!isInIsrael && (day == 16 || day == 22))) }
	///Returns if the current day is *Chol Hamoed* of *Pesach*
    public var isCholHamoedPesach: Bool { month == .nissan && (day >= 17 && day <= 20 || (day == 16 && isInIsrael)) }
	///Returns if the current day is *Yom Hashoah*
    public var isYomHashoah: Bool { month == .nissan && ((day == 26 && dow == .thursday) || (day == 28 && dow == .monday) || (day == 27 && dow != .sunday && dow != .friday))}
	///Returns if the current day is *Yom Hazikaron*
    public var isYomHazikaron: Bool { month == .iyar && ((day == 4 && dow == .tuesday) || ((day == 3 || day == 2) && dow == .wednesday) || (day == 6 && dow == .tuesday)) }
	///Returns if the current day is *Yom Haatzmaut*
    public var isYomHaatzmaut: Bool { month == .iyar && ((day == 5 && dow == .wednesday) || (day == 6 && dow == .tuesday) || ((day == 4 || day == 3) && dow == .thursday)) }
	///Returns if the current day is *Pesach Sheni*
    public var isPesachSheni: Bool { month == .iyar && day == 14 }
	///Returns if the current day is *Lag Baomer*
    public var isLagBaomer: Bool { month == .iyar && day == 18 }
	///Returns if the current day is *Yom Yerushalayim*
    public var isYomYerushalaim: Bool { month == .iyar && day == 28 }
	///Returns if the current day is *Erev Shavuos*
    public var isErevShavuos: Bool { month == .sivan && day == 5 }
	///Returns if the current day is *Shavuos*
    public var isShavuos: Bool { month == .sivan && (day == 6 || (!isInIsrael && day == 7)) }
	///Returns if the current day is the 17th of *Tammuz*
    public var isSeventeenthOfTammuz: Bool { month == .tammuz && ((day == 17 && dow != .friday) || (day == 18 && dow == .sunday)) }
	///Returns if the current day is *Tisha B'Av*
    public var isTishaBeav: Bool { month == .av && ((day == 10 && dow == .sunday) || (day == 9 && dow != .saturday)) }
	///Returns if the current day is *Tu B'Av*
    public var isTuBeav: Bool { month == .av && day == 15 }
	///Returns if the current day is *Erev Rosh Hashana*
    public var isErevRoshHashana: Bool { month == .elul && day == 29 }
	///Returns if the current day is *Rosh Hashana*
    public var isRoshHashana: Bool { month == .tishrei && (day == 1 || day == 2) }
	///Returns if the current day is the Fast of *Gedalia*
    public var isFastOfGedalia: Bool { month == .tishrei && ((day == 3 && dow != .saturday) || (day == 4 && dow == .sunday)) }
	///Returns if the current day is *Erev Yom Kippur*
    public var isErevYomKippur: Bool { month == .tishrei && day == 9 }
	///Returns if the current day is *Yom Kippur*
    public var isYomKippur: Bool { month == .tishrei && day == 10 }
	///Returns if the current day is *Erev Succos*
    public var isErevSuccos: Bool { month == .tishrei && day == 14 }
	///Returns if the current day is *Succos* (either  the *Yom Tov* of *Succos* or *Chol Hamoed Succos*).
	///
	///This does not include *Hoshana Rabba*, *Shemini Atzeres*, or *Simchas Torah*
    public var isSuccos: Bool { month == .tishrei && (day == 15 || (day == 16 && !isInIsrael)) }
	///Returns if the current day is *Chol Hamoed* of *Succos*
	///
	///This does not include *Hoshana Rabba*
    public var isCholHamoedSuccos: Bool { month == .tishrei && ((day >= 17 && day <= 20) || (day == 16 && isInIsrael)) }
	///Returns if the current day is *Hoshana Rabba*
    public var isHoshanaRabba: Bool { month == .tishrei && day == 21 }
	///Returns if the current day is *Shemini Atzeres*
    public var isSheminiAtzeres: Bool { month == .tishrei && day == 22 }
	///Returns if the current day is *Simchas Torah*
    public var isSimchasTorah: Bool { month == .tishrei && day == 23 && !isInIsrael }
	///Returns if the current day is *Erev Chanukah*
    public var isErevChanukah: Bool { month == .kislev && day == 24 } // TODO formatting?
	///Returns if the current day is *Chanukah*
    public var isChanukah: Bool { (month == .kislev && day >= 25) || (month == .teves && ((day == 1 || day == 2) || (day == 3 && isKislevShort)))}
	///Returns if the current day is the 10th of *Teves*
    public var isTenthOfTeves: Bool { month == .teves && day == 10 }
	///Returns if the current day is *Tu B'Shvat*
    public var isTuBeshvat: Bool { month == .shevat && day == 15 }
	///Returns if the current day is the Fast of *Esther*
    public var isFastOfEsther: Bool { (!isJewishLeapYear && month == .adar && (((day == 11 || day == 12) && dow == .thursday) || (day == 13 && !(dow == .friday || dow == .saturday)))) || (isJewishLeapYear && month == .adar2 && (((day == 11 || day == 12) && dow == .thursday) || (day == 13 && !(dow == .friday || dow == .saturday)))) }
	///Returns if the current day is *Purim*
    public var isPurim: Bool { (!isJewishLeapYear && month == .adar && day == 14) || (isJewishLeapYear && month == .adar2 && day == 14) }
	///Returns if the current day is *Shushan Purim*
    public var isShushanPurim: Bool { (!isJewishLeapYear && month == .adar && day == 15) || (isJewishLeapYear && month == .adar2 && day == 15) }
	///Returns if the current day is *Purim Katan*
    public var isPurimKatan: Bool { isJewishLeapYear && month == .adar && day == 14 }
	///Returns if the current day is *Shushan Purim Katan*
    public var isShushanPurimKatan: Bool { isJewishLeapYear && month == .adar && day == 15 }
	///Returns if the current day is *Isru Chag*
    public var isIsruChag: Bool { month == .sivan && ((day == 7 && isInIsrael) || day == 8 && !isInIsrael) }
    
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
        .erevChanukah: { cal in cal.isErevChanukah },
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
        .shushanPurimKatan: { cal in cal.isShushanPurimKatan },
        .isruChag: { cal in cal.isIsruChag }
    ]
    
	/// Determine what Jewish holiday occurs on the given day
	///
    /// On occasions where multiple holidays occur on the same day, the holiday with the lower raw value will take precedence. For example, when _Rosh Chodesh_ occurs on _Chanukah_, it will returns _Chanukah_. 
    /// - Returns: The ``JewishHoliday`` that occurs on the given day. If there's no holiday on the given day, it returns `nil`.
    public func getCurrentChag() -> JewishHoliday? {
        for yomTov in JewishHoliday.allCases {
            guard let checker = JewishCalendar.chagCheckers[yomTov] else {return nil}
            if checker(self) {
                return yomTov
            }
        }
        
        return nil
    }
    
	///Returns if the current day is a Yom Tov
    public var isYomTov: Bool {
        guard let _ = getCurrentChag() else {
            return false
        }
        
        let isExcludedChag = (isErevYomTov && !(isHoshanaRabba || isCholHamoedPesach))
            || (isTaanis && !isYomKippur)
            || isIsruChag
        
        return !isExcludedChag
    }
	
	///Returns if the *Yom Tov* day has a *melacha* (work)  prohibition.
	///
	///This will return false for a non-*Yom Tov* day, even if it is *Shabbos*.
    public var isYomTovAssurBemelacha: Bool { isPesach || isShavuos || isSuccos || isSheminiAtzeres || isSimchasTorah || isRoshHashana || isYomKippur }
    
	///Returns if it is *Shabbos* or if it is a *Yom Tov* day that has a *melacha* (work)  prohibition.
    public var isAssurBemelacha: Bool { dow == .saturday || isYomTovAssurBemelacha }
    
	/// Returns if tomorrow is *Shabbos* or *Yom Tov*.
	///
	/// This will return `true` on *Erev Shabbos*, *Erev Yom Tov*, the first day of *Rosh Hashana* and *erev* the first days of *Yom Tov* out of Israel.
    public var isTomorrowShabbosOrYomTov: Bool { dow == .friday || isErevYomTov || isErevYomTovSheni }
	
	/// Returns true if the day is the second day of *Yom Tov*. This impacts the second day of *Rosh Hashana* everywhere and the second days of Yom Tov in *chutz laaretz* (out of Israel).
    public var isErevYomTovSheni: Bool {
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
	///Returns if the current day is within the *Aseres Yemei Teshuva*
    public var isAseresYemeiTeshuva: Bool { month == .tishrei && day <= 10 }
	
    ///Returns if the current day is Chol HaMoed of *Pesach* or *Succos*
	///
	/// ## See Also
	///- ``isCholHamoedPesach``
	///- ``isCholHamoedSuccos``
    public var isCholHamoed: Bool { isCholHamoedPesach || isCholHamoedSuccos }
	///Returns if the current day is *Erev Yom Tov*.
	///
	///This returns `true` for *Erev* - *Pesach* (first and last days), *Shavuos*, *Rosh Hashana*, *Yom Kippur*, *Succos* and *Hoshana Rabba*.
	///
	///## See Also
	///- ``isYomTov``
	///- ``isErevYomTovSheni``
    public var isErevYomTov: Bool { isErevRoshChodesh || isErevShavuos || isErevPesach || isErevSuccos || isErevRoshHashana || isErevYomKippur || isErevSuccos || isHoshanaRabba || (isCholHamoedPesach && day == 20) }
    
	///Returns if the current day is a fast day
    public var isTaanis: Bool { isSeventeenthOfTammuz || isTishaBeav || isYomKippur || isFastOfEsther || isFastOfGedalia || isTenthOfTeves }
	/// Return if the day is *Taanis Bechoros*.
	///
	/// It will return true for the 14th of *Nissan* if it is not on *Shabbos*, or if the 12th of *Nissan* occurs on a Thursday.
    public var isTaanisBechoros: Bool { month == .nissan && ((day == 14 && dow != .saturday) || (day == 12 && dow == .thursday)) }
    
    public var dayOfChanukah: Int? {
        if !isChanukah { return nil }
        
        if month == .kislev {
            return day - 24
        } else {
            return isKislevShort ? day + 5 : day + 6
        }
    }
	
	//TODO: KosherJava: There is more to tweak in this method (it does not cover all cases and opinions), and it may be removed.
	///Returns if the day is *Shabbos* and Sunday is *Rosh Chodesh*.
    public var isMacharChodesh: Bool { dow == .saturday && (day == 30 || day == 29) }
    
	///Returns if the current day is *Shabbos Mevorchim*
    public var isShabbosMevorchim: Bool { dow == .saturday && month != .elul && day >= 23 && day <= 29 }
    
	//MARK: - Omer
	
	///Returns the value of the *Omer* day or `nil` if the day isn't in the *Omer*
    public var dayOfOmer: Int? {
        if month == .nissan && day >= 16 {
            return day - 15
        } else if month == .iyar {
            return day + 15
        } else if month == .sivan && day < 6 {
            return day + 44
        }
        
        return nil
    }
	
	//MARK: - Kiddush Levana
	
	///Returns the earliest time of *Kiddush Levana* calculated as 3 days after the molad.
	///
	///This returns the time even if it is during the day when *Kiddush Levana* can't be said.
	/// >Tip: Callers of this property should consider displaying the next *tzais* if the *zman* is between *alos* and *tzais*.
	/// - Returns: the Date representing the moment 3 days after the molad.
    public var earliestKiddushLevana3Days: Date? { moladDate?.gregDate.withAdded(days: 3) }
	///Returns the earliest time of *Kiddush Levana* calculated as 7 days after the *molad*
	///This calculation is based on the [Mechaber](http://en.wikipedia.org/wiki/Yosef_Karo). See the [Bach's](http://en.wikipedia.org/wiki/Yoel_Sirkis) opinion on this time. This method returns the time even if it is during the day when *Kiddush Levana* can't be said.
	/// >Tip: Callers of this property should consider displaying the next *tzais* if the *zman* is between *alos* and *tzais*.
	/// - Returns: the Date representing the moment 7 days after the molad.
    public var earliestKiddushLevana7Days: Date? { moladDate?.gregDate.withAdded(days: 7) }
	
	/// Returns the latest time of Kiddush Levana according to the [Maharil's](http://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin) opinion that it is calculated as halfway between *molad* and *molad*.
	///
	/// This adds half the 29 days, 12 hours and 793 *chalakim* time between *molad* and *molad* (14 days, 18 hours, 22 minutes and 666 milliseconds) to the month's *molad*. This method returns the time even if it is during the day when *Kiddush Levana* can't be recited.
	/// >Tip: Callers of this property should consider displaying *alos* before this time if the *zman* is between *alos* and *tzais*.
	/// - Returns: the Date representing the moment halfway between *molad* and *molad*.
    public var latestZmanKidushLevanaBetweenMoldos: Date? { moladDate?.gregDate.withAdded(days: 14, hours: 18, minutes: 22, seconds: 1, milliseconds: 666) }
	
	/// Returns the latest time of *Kiddush Levana* calculated as 15 days after the *molad.*
	///
	/// This is the opinion brought down in the Shulchan Aruch (Orach Chaim 426). It should be noted that some opinions hold that the [Rema](http://en.wikipedia.org/wiki/Moses_Isserles) who brings down the [Maharil's](http://en.wikipedia.org/wiki/Yaakov_ben_Moshe_Levi_Moelin) opinion of calculating it as {@link #getSofZmanKidushLevanaBetweenMoldos() half way between *molad* and *molad*} is of the opinion of the Mechaber as well. Also see the Aruch Hashulchan. For additional details on the subject, See Rabbi Dovid Heber's very detailed writeup in Siman Daled (chapter 4) of [Shaarei Zmanim](http://www.worldcat.org/oclc/461326125). This method returns the time even if it is during the day when *Kiddush Levana* can't be said.
	/// >Tip: Callers of this property should consider displaying *alos* before this time if the *zman* is between *alos* and *tzais*.
	/// ## See Also
	/// - ``latestZmanKidushLevanaBetweenMoldos``
    public var latestKiddushLevana15Days: Date? { moladDate?.gregDate.withAdded(days: 15) }
    
	//MARK: - Daf Yomi
	
	/// Returns the *Daf Yomi (Bavli)* for the date that the calendar is set to. See ``HebrewDateFormatter/formatDafYomi(daf:)``for the ability to format the *daf* in Hebrew or transliterated *masechta* names.
    public var dafYomiBavli: Daf? { DafYomiCalculator.getDafYomiBavli(cal: self) }
	/// Returns the *Daf Yomi (Yerushalmi)* for the date that the calendar is set to. See ``HebrewDateFormatter/formatDafYomi(daf:)`` for the ability to format the *daf* in Hebrew or transliterated *masechta* names.
    public var dafYomiYerushalmi: Daf? { DafYomiCalculator.getDafYomiYerushalmi(cal: self) }
	
	//MARK: - Mashiv HaRuach/Vesen Bracha

    public var isMashivHaruachRecited: Bool {
        let start = JewishDate(withJewishYear: year, andMonth: .tishrei, andDay: 22)
        let end = JewishDate(withJewishYear: year, andMonth: .nissan, andDay: 15)
        
        return gregDate > start.gregDate && gregDate < end.gregDate
    }
    
    public var isVeseinTalUmatarRecited: Bool {
        if month == .nissan && day < 15 {
            return true
        } else if month.rawValue < JewishMonth.cheshvan.rawValue {
            return false
        } else if isInIsrael {
            return month != .cheshvan || day >= 7
        }
        
        return tekufasTishreiElapsedDays >= 47
    }
    
    public var isMashivHaruachStartDate: Bool { return month == .tishrei && day == 22 }
    public var isMashivHaruachEndDate: Bool { return month == .nissan && day == 15 }
    
    public var isVeseinBerachaRecited: Bool { !isVeseinTalUmatarRecited }
    public var isMoridHatalRecited: Bool { !isMashivHaruachRecited || isMashivHaruachStartDate || isMashivHaruachEndDate }
	
    ///Return the ``JewishCalendar`` for the following day
    public var tomorrow: JewishCalendar {
        JewishCalendar(date: gregDate.withAdded(days: 1)!, isInIsrael: isInIsrael)
    }
    ///Return the ``JewishCalendar`` for the previous day
    public var yesterday: JewishCalendar {
        JewishCalendar(date: gregDate.withAdded(days: -1)!, isInIsrael: isInIsrael)
    }
    
    public var chagStart: JewishCalendar {
        var temp = JewishCalendar(date: gregDate, isInIsrael: isInIsrael)
        while !temp.isErevYomTov {
            temp = temp.yesterday
        }
        
        return temp
    }
    
    public var chagHavdallahDate: JewishCalendar {
        var temp = chagStart.tomorrow
        while temp.isAssurBemelacha {
            temp = temp.tomorrow
        }
        
        return temp.yesterday
    }
    
	///Returns what the current day of *Chol Hamoed* the current day is, or `nil` if it is not *Chol Hamoed*
    public var cholHamoedDay: Int? {
        if !isCholHamoed {
            return nil
        }
        
        var cur = self.copy()
        var i = 0
        while cur.isCholHamoed {
            i += 1
            cur = cur.yesterday
        }
        
        return i
    }
    
	///Returns if Ledavid is said on the current day
    public var isLedavidSaid: Bool {
        month == .elul || (month == .tishrei && day < 22)
    }

    public func getRules(baseRules: TefilaRules) -> TefilaRules {
        baseRules.copy(withCal: self)
    }
    
	///Returns the number of days in the current Jewish month
    public var daysInJewishMonth: Int {
        getDaysInJewishMonth(month: month)
    }
}
