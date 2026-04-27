//
//  JewishCalendar+Limudim.swift.swift
//  KosherSwift
//
//  Created by Michael Berk on 4/27/26.
//

import Foundation

struct PsalmGroups: Codable {
	var days: [[Int]]
}

extension JewishCalendar {

	private func getPsalmGroups() -> PsalmGroups {
		let jsonURL = Bundle.module.url(forResource: "PsalmGroups", withExtension: "json",)!
		let groupsData = try! Data(contentsOf: jsonURL)
		return try! JSONDecoder().decode(PsalmGroups.self, from: groupsData)
	}
	
	/// The chapters of _Tehillim_ to be said on the current day of the 30-day cycle
	///
	/// > NOTE: Chapter 119 of _Tehillim_ is split across days 25 and 26
	public var monthlyTehillim: [Int] {
		let groups = getPsalmGroups()
		if day < 29 {
			return groups.days[day - 1]
		}
		if daysInJewishMonth == 30 {
			return groups.days[day - 1]
		}
		if daysInJewishMonth == 29 {
			let combined = groups.days[28] + groups.days[29]
			return combined
		}
		
		return []
	}
}
