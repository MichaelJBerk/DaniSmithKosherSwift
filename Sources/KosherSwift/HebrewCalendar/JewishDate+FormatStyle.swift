//
//  JewishDateFormatter.swift
//  KosherSwift
//
//  Created by Michael Berk on 3/11/26.
//

import Foundation

public extension JewishDate {
	/// A structure that creates a string representation of a Jewish date instance
	struct FormatStyle: Codable, Copyable {

		enum DateItems: Codable {
			case day
			case month
			case year
		}
		private var dateItems: Set<DateItems> = []

		///Determines if the output should be in Hebrew
		var inHebrew: Bool

		///Determines if the text of the string should be localized.
		var shouldLocalize: Bool


		/// Initializes the FormatStyle
		/// - Parameter hebrew: Determines if the output should be in Hebrew. Defaults to `false`.
		/// - Parameter localized: Determines if the text of the string should be localized.  See ``localize`` for more information.
		public init(hebrew: Bool = false, localized: Bool = false) {
			self.inHebrew = hebrew
			self.shouldLocalize = localized
		}

		///FormatString to be given to the HebrewDateFormatter
		fileprivate var formatStringForFormatter: String {
			var strings: [String] = []
			if dateItems.contains(.day) || dateItems.isEmpty {
				strings.append("dd")
			}
			if dateItems.contains(.month) || dateItems.isEmpty {
				strings.append("MMMM")
			}
			if dateItems.contains(.year) || dateItems.isEmpty {
				strings.append("yyyy")
			}
			return strings.joined(separator: " ")
		}

		///Modifies the Jewish date format style to return the date in Hebrew
		public func hebrew() -> Self {
			var newFS = self
			newFS.inHebrew = true
			return newFS
		}

		///Modifies the Jewish date format style to localize the output. 
		/// 
		///For example, the 23rd of Adar in 5786 would return "כ״ג באדר תשפ״ו" if set to `true`, and "כ״ג אדר תשפ״ו" if set to `false`. 
		public func localize() -> Self {
			var newFS = self
			newFS.shouldLocalize = true
			return newFS
		}

		///Modifies the Jewish date format style to include the date
		public func day() -> Self {
			var newFS = self
			newFS.dateItems.insert(.day)
			return newFS
		}

		///Modifies the Jewish date format style to inlcude the month
		public func month()-> Self {
			var newFS = self
			newFS.dateItems.insert(.month)
			return newFS
		}

		///Modifies the Jewish date format style to include the year
		public func year()-> Self {
			var newFS = self
			newFS.dateItems.insert(.year)
			return newFS
		}
	}
}

extension JewishDate.FormatStyle: Foundation.FormatStyle {
	public func format(_ value: JewishDate) -> String {
		let formatter = DateFormatter()
		formatter.calendar = .init(identifier: .hebrew)
		//Use autoupdatingCurrent when not hebrew so AM/PM doesn't appear when localized, etc
		formatter.locale = inHebrew ? .init(identifier: "he") : .autoupdatingCurrent
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		if shouldLocalize {
			formatter.setLocalizedDateFormatFromTemplate(formatStringForFormatter)
		} else {
			formatter.dateFormat = formatStringForFormatter
		}
		return HebrewDateFormatter().formatDate(value, formatter: formatter)
	}
}
public extension JewishDate {
	func formatted() -> String {
		Self.FormatStyle().format(self)
	}

	func formatted<F:Foundation.FormatStyle>(_ style: F) -> F.FormatOutput where F.FormatInput == JewishDate {
		style.format(self)
	}
}
public extension FormatStyle where Self == JewishDate.FormatStyle {
	static var jewishDate: Self {
		.init(hebrew: false, localized: false)
	}
}