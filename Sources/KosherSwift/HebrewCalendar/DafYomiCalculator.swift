//
//  DafYomiCalculator.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/21/23.
//

import Foundation

class DafYomiCalculator {
    private static let dafYomiStart = Calendar.current.date(from: DateComponents(year: 1923, month: 9, day: 11))!
    private static let dafYomiJulianStart = NOAACalculator.getJulianDay(dafYomiStart)
    private static let shekalimChangeDay = Calendar.current.date(from: DateComponents(year: 1975, month: 6, day: 24))!
    private static let shekalimJulianChangeDay = NOAACalculator.getJulianDay(shekalimChangeDay)
    
    private static let dafYomiYerushalmiStart = Calendar.current.date(from: DateComponents(year: 1980, month: 2, day: 2))!
    private static let dayMillis = 1000 * 60 * 60 * 24
    private static let wholeShasDafsYerushalmi = 1554
    
    private static let blattPerMasechtaBavli = [ 64, 157, 105, 121, 22, 88, 56, 40, 35, 31, 32, 29, 27, 122, 112, 91, 66, 49, 90, 82, 119, 119, 176, 113, 24, 49, 76, 14, 120, 110, 142, 61, 34, 34, 28, 22, 4, 9, 5, 73]
    
    // TODO daf yomi yerushalmi
    private static let blattPerMasechtaYerushalmi = [ 68, 37, 34, 44, 31, 59, 26, 33, 28, 20, 13, 92, 65, 71, 22, 22, 42, 26, 26, 33, 34, 22, 19, 85, 72, 47, 40, 47, 54, 48, 44, 37, 34, 44, 9, 57, 37, 19, 13 ]
    
    public static func getDafYomiBavli(jewishCalendar: JewishCalendar) -> Daf? {
        /*
         * The number of daf per masechta. Since the number of blatt in Shekalim changed on the 8th Daf Yomi cycle
         * beginning on June 24, 1975 from 13 to 22, the actual calculation for blattPerMasechta[4] will later be
         * adjusted based on the cycle.
         */
        var blattPerMasechta = [ 64, 157, 105, 121, 22, 88, 56, 40, 35, 31, 32, 29, 27, 122, 112, 91, 66, 49, 90, 82,
                                 119, 119, 176, 113, 24, 49, 76, 14, 120, 110, 142, 61, 34, 34, 28, 22, 4, 9, 5, 73 ]
        
        let calendar = jewishCalendar.gregDate
//            .addingTimeInterval(-86400)//temp fix
        
        var dafYomi: Daf? = nil
        let julianDay = Int(NOAACalculator.getJulianDay(calendar))
        var cycleNo = 0
        var dafNo = 0
        if (calendar.compare(dafYomiStart) == .orderedAscending) {
            return nil
        }
        if (calendar.compare(shekalimChangeDay) == .orderedSame || calendar.compare(shekalimChangeDay) == .orderedDescending) {
            cycleNo = 8 + ((julianDay - Int(shekalimJulianChangeDay)) ~/ 2711)
            dafNo = (julianDay - Int(shekalimJulianChangeDay)) % 2711
        } else {
            cycleNo = 1 + ((julianDay - Int(dafYomiJulianStart)) ~/ 2702)
            dafNo = (julianDay - Int(dafYomiJulianStart)) % 2702
        }
        
        var total = 0
        var masechta = -1
        var blatt = 0
        
        // Fix Shekalim for old cycles.
        if (cycleNo <= 7) {
            blattPerMasechta[4] = 13
        } else {
            blattPerMasechta[4] = 22 // correct any change that may have been changed from a prior calculation
        }
        
        // Finally find the daf.
        for j in 0..<blattPerMasechta.count {
            masechta += 1
            total = total + blattPerMasechta[j] - 1
            if (dafNo < total) {
                blatt = 1 + blattPerMasechta[j] - (total - dafNo)
                // Fiddle with the weird ones near the end.
                if (masechta == 36) {
                    blatt += 21
                } else if (masechta == 37) {
                    blatt += 24
                } else if (masechta == 38) {
                    blatt += 32
                }
                dafYomi = Daf(masechtaNumber: masechta, daf: blatt)
                break
            }
        }
        
        return dafYomi
    }
    
}
