//
//  OmerFormatter.swift
//  KosherSwift
//
//  Created by Michael Berk on 5/20/26.
//

import Foundation

/**A style for formatting a day of the Omer

# Examples
```swift
1.formatted(.omer(style: .short(hebrew: true))) // "א׳ בעומר"
1.formatted(.omer(style: .short(hebrew: true, gematria: .init(gershGershayim: false)))) // "א בעומר"
32.formatted(.omer(style: .short(hebrew: true, gematria: .init(gershGershayim: false)))) // "לב בעומר"
32.formatted(.omer(style: .short(hebrew: true, gematria: .init(gershGershayim: true)))) // "ל״ב בעומר"
33.formatted(.omer(style: .long(nusach: .ashkenaz))) // "הַיּוֹם שְׁלֹשָׁה וּשְׁלֹשִׁים יוֹם, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים לָעֹמֶר: "
33.formatted(.omer(style: .long(nusach: .mizrach))) // "הַיּוֹם שְׁלֹשָׁה וּשְׁלֹשִׁים יוֹם לָעֹמֶר, שֶׁהֵם אַרְבָּעָה שָׁבוּעוֹת וַחֲמִשָּׁה יָמִים:"
```

If the input value is not a day of the omer (i.e. it is not between 1 and 49), this will return an empty string.
 
> Note: The data for the long Omer style is lazily loaded from disk the first time the instance accesses it. If you need the best performance possible, you may want to create a single ``OmerFormatStyle`` instance and modify that when needed.
*/
public struct OmerFormatStyle: Foundation.FormatStyle, Codable, Equatable, Hashable {
	
	///An enum representing formats that an Omer can be displayed in
	public enum OmerStyle: Codable, Equatable, Hashable{
		///A short Omer (i.e. "Omer 33")
		///- Parameter hebrew: Determines if the output should be in Hebrew or English. Defaults to `false`.
		///- Parameter hebrewOmerPrefix: The prefix for the word עומר. By default it is the letter ב, but can be set to ל (or any other prefix).
		///- Parameter gematria: The GematriaFormat to be used when `hebrew` is true.
		case short(hebrew: Bool = false, hebrewOmerPrefix: String = "ב", gematria: GematriaFormat = .init())
		///A long Omer, containing the full text for the omer day (i.e. "הַיּוֹם יוֹם אֶחָד לָעֹמֶר:")
		///- Parameter nusach: The nusach of the Omer text
		case long(nusach: OmerFormatStyle.Nusach)
		
		///Modifies the short Omer style to output in Hebrew.
		///
		///This method does nothing if the style is `long`
		public func hebrew(_ value: Bool = true) -> Self {
			if case let .short(hebrew, hebrewOmerPrefix, gematria) = self {
				return .short(hebrew: true, hebrewOmerPrefix: hebrewOmerPrefix, gematria: gematria)
			}
			return self
		}
		
		///Modifies the hebrew omer prefix of the short Omer style.
		///
		///This method does nothing if the style is `long`
		public func hebrewOmerPrefix(_ value: String) -> Self {
			if case let .short(hebrew, hebrewOmerPrefix, gematria) = self {
				return .short(hebrew: hebrew, hebrewOmerPrefix: value, gematria: gematria)
			}
			return self
		}
		
		///Modifies the Gematria format of the short Omer style
		///
		///This method does nothing if the style is `long`
		public func gematriaFormat(_ value: GematriaFormat) -> Self {
			if case let .short(hebrew, hebrewOmerPrefix, gematria) = self {
				return .short(hebrew: hebrew, hebrewOmerPrefix: hebrewOmerPrefix, gematria: gematria)
			}
			return self
		}
		
		///Modifies the Nusach of the long Omer style
		///
		///This method does nothing if the style is `short`
		public func nusach(_ value: OmerFormatStyle.Nusach) -> Self {
			switch self {
			case .short(_,_,_):
				return self
			case .long(_):
				return .long(nusach: value)
			}
			return .long(nusach: value)
		}
	}
	
	///The Nusach to be used for the long Omer style
	public enum Nusach: Codable {
		case ashkenaz
		case mizrach
	}
	///The Omer style to be used
	var style: OmerStyle
	
	///Initializes the format style
	///
	///- Parameter style: The Omer style to be used
	init(style: OmerStyle) {
		self.style = style
	}

	public func format(_ value: Int) -> String {
		if value <= 0 || value > 49 {
			return ""
		}
		switch style {
		case .short(let hebrew, let hebrewOmerPrefix, let gematria):
			var formatter = HebrewDateFormatter(hebrewFormat: hebrew,
												useGershGershayim: gematria.gershGershayim,
												useFinalFormLetters: gematria.finalFormLetters)
			if hebrew {
				let dayStr = (try? formatter.formatHebrewNumber(value)) ?? "\(value)"
				return dayStr + " " + hebrewOmerPrefix + "עומר"
			} else {
				if value == 33 {
					return JewishHoliday.lagBaomer.transliteratedName
				}
				return "Omer \(value)"
			}
		case .long(let nusach):
			let data = longOmerData[value - 1]
			switch nusach {
			case .ashkenaz:
				return data.ashkenaz
			case .mizrach:
				return data.mizrach
			}
		}
	}
	
	
	private var longOmerData: [OmerData] = {
		return OmerData.load()
	}()
	
}

///Internal structure used for loading Omer data
struct OmerData: Codable, Equatable, Hashable {
	var ashkenaz: String
	var mizrach: String
	var kabbalah: String
	
	///Load Omer data from disk
	static func load() -> [OmerData] {
		let omerUrl = Bundle.module.url(forResource: "Omer", withExtension: "json")!
		let omerData = try! Data(contentsOf: omerUrl)
		return try! JSONDecoder().decode([OmerData].self, from: omerData)
	}
}

public extension FormatStyle where Self == IntegerFormatStyle<Int> {
	///Returns a style for formatting an integer as a day of the Omer.
	static func omer(style: OmerFormatStyle.OmerStyle) -> OmerFormatStyle {
		return OmerFormatStyle(style: style)
	}
}
