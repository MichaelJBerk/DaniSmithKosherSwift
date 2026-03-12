//
//  JewishDateConstants.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/19/23.
//

import Foundation

extension JewishDateProtocol {
    static var jewishEpoch: Int {-1373429}
    
    /// The number  of <em>chalakim</em> (18) in a minute.
    static var chalakimPerMinute: Int {18}
    
    /// The number  of <em>chalakim</em> (1080) in an hour.
    static var chalakimPerHour: Int {1080}
    
    /// The number of <em>chalakim</em> (25,920) in a 24 hour day.
    static var chalakimPerDay: Int {25920} // 24 * 1080
    /// The number  of <em>chalakim</em> in an average Jewish month. A month has 29 days, 12 hours and 793
    /// <em>chalakim</em> (44 minutes and 3.3 seconds) for a total of 765,433 <em>chalakim</em>
    static var chalakimPerMonth: Double {765433.0}
     // (29 * 24 + 12) * 1080 + 793
    /// Days from the beginning of Sunday till molad BaHaRaD. Calculated as 1 day, 5 hours and 204 chalakim = (24 + 5) *
    /// 1080 + 204 = 31524
    static var chalakimMoladTohu: Int {31524}
    
    /// A short year where both {@link #CHESHVAN} and {@link #KISLEV} are 29 days.
    ///
    /// @see #getCheshvanKislevKviah()
    /// @see HebrewDateFormatter#getFormattedKviah(int)
    static var chaserim: Int {0}
    
    /// An ordered year where {@link #CHESHVAN} is 29 days and {@link #KISLEV} is 30 days.
    ///
    /// @see #getCheshvanKislevKviah()
    /// @see HebrewDateFormatter#getFormattedKviah(int)
    static var kesidran: Int {1}
    
    /// A long year where both {@link #CHESHVAN} and {@link #KISLEV} are 30 days.
    ///
    /// @see #getCheshvanKislevKviah()
    /// @see HebrewDateFormatter#getFormattedKviah(int)
    static var shelaimim: Int {2}
}
