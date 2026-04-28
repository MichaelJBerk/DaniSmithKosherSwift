//
//  JewishCalendar+FormatStyle.swift
//  KosherSwift
//
//  Created by Michael Berk on 4/27/26.
//

import Foundation

public extension JewishCalendar {
	
	enum TehillimCycle: Codable, Sendable, Comparable {
		case monthly
	}
	
	struct TehillimFormatStyle: Codable, Copyable, Foundation.FormatStyle {
		var cycle: JewishCalendar.TehillimCycle
		var inHebrew: Bool = false
		
		init(cycle: JewishCalendar.TehillimCycle = .monthly, hebrew: Bool = false) {
			self.cycle = cycle
			self.inHebrew = hebrew
		}
				
		public func format(_ value: JewishCalendar) -> String {
			let chapters = value.monthlyTehillim
			let formatter = HebrewDateFormatter(hebrewFormat: true, useGershGershayim: false)
			if chapters == [119] {
				var nums: [Int]
				if value.day == 25 {
					nums = [119, 1, 96]
				} else {
					nums = [119, 97, 176]
				}
				let strs: [String]
				if inHebrew {
					strs = nums.map {try! formatter.formatHebrewNumber($0)}
				} else {
					strs = nums.map{"\($0)"}
				}
				return "\(strs[0]): \(strs[1]) - \(strs[2])"
			}
			if chapters.count > 1 {
				let nums = [chapters.first!, chapters.last!]
				let strs: [String]
				if inHebrew {
					strs = nums.map{try! formatter.formatHebrewNumber($0)}
				} else {
					strs = nums.map{"\($0)"}
				}
				return "\(strs[0]) - \(strs[1])"
			}
			guard let first = chapters.first else {return ""}
			let str: String
			if inHebrew {
				str = try! formatter.formatHebrewNumber(first)
			} else {
				str = "\(first)"
			}
			return str
			
		}
		
		public func cycle(_ value: JewishCalendar.TehillimCycle) -> Self {
			var newFS = self
			newFS.cycle = value
			return newFS
		}
		
		public func hebrew(_ value: Bool = true) -> Self {
			var newFS = self
			newFS.inHebrew = value
			return newFS
		}
	}

}


public extension FormatStyle where Self == JewishCalendar.TehillimFormatStyle {
	static var tehillimCycle: Self {
		.init()
	}
}

public extension JewishCalendar {
	
	func formatted<F:Foundation.FormatStyle>(_ style: F) -> F.FormatOutput where F.FormatInput == JewishCalendar {
		style.format(self)
	}
}
