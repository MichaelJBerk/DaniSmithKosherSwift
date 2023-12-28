//
//  JewishMonth.swift
//  YidKitiOS
//
//  Created by Daniel Smith on 12/19/23.
//

public struct Daf {
    public let masechtaNumber: Int
    public let daf: Int
    
    static private var masechtosBavliTransliterated = [
        "Berachos",
        "Shabbos",
        "Eruvin",
        "Pesachim",
        "Shekalim",
        "Yoma",
        "Sukkah",
        "Beitzah",
        "Rosh Hashana",
        "Taanis",
        "Megillah",
        "Moed Katan",
        "Chagigah",
        "Yevamos",
        "Kesubos",
        "Nedarim",
        "Nazir",
        "Sotah",
        "Gitin",
        "Kiddushin",
        "Bava Kamma",
        "Bava Metzia",
        "Bava Basra",
        "Sanhedrin",
        "Makkos",
        "Shevuos",
        "Avodah Zarah",
        "Horiyos",
        "Zevachim",
        "Menachos",
        "Chullin",
        "Bechoros",
        "Arachin",
        "Temurah",
        "Kerisos",
        "Meilah",
        "Kinnim",
        "Tamid",
        "Midos",
        "Niddah"
    ]
    
    static let masechtosBavli = [
        "\u{05D1}\u{05E8}\u{05DB}\u{05D5}\u{05EA}",
        "\u{05E9}\u{05D1}\u{05EA}",
        "\u{05E2}\u{05D9}\u{05E8}\u{05D5}\u{05D1}\u{05D9}\u{05DF}",
        "\u{05E4}\u{05E1}\u{05D7}\u{05D9}\u{05DD}",
        "\u{05E9}\u{05E7}\u{05DC}\u{05D9}\u{05DD}",
        "\u{05D9}\u{05D5}\u{05DE}\u{05D0}",
        "\u{05E1}\u{05D5}\u{05DB}\u{05D4}",
        "\u{05D1}\u{05D9}\u{05E6}\u{05D4}",
        "\u{05E8}\u{05D0}\u{05E9} \u{05D4}\u{05E9}\u{05E0}\u{05D4}",
        "\u{05EA}\u{05E2}\u{05E0}\u{05D9}\u{05EA}",
        "\u{05DE}\u{05D2}\u{05D9}\u{05DC}\u{05D4}",
        "\u{05DE}\u{05D5}\u{05E2}\u{05D3} \u{05E7}\u{05D8}\u{05DF}",
        "\u{05D7}\u{05D2}\u{05D9}\u{05D2}\u{05D4}",
        "\u{05D9}\u{05D1}\u{05DE}\u{05D5}\u{05EA}",
        "\u{05DB}\u{05EA}\u{05D5}\u{05D1}\u{05D5}\u{05EA}",
        "\u{05E0}\u{05D3}\u{05E8}\u{05D9}\u{05DD}",
        "\u{05E0}\u{05D6}\u{05D9}\u{05E8}",
        "\u{05E1}\u{05D5}\u{05D8}\u{05D4}",
        "\u{05D2}\u{05D9}\u{05D8}\u{05D9}\u{05DF}",
        "\u{05E7}\u{05D9}\u{05D3}\u{05D5}\u{05E9}\u{05D9}\u{05DF}",
        "\u{05D1}\u{05D1}\u{05D0} \u{05E7}\u{05DE}\u{05D0}",
        "\u{05D1}\u{05D1}\u{05D0} \u{05DE}\u{05E6}\u{05D9}\u{05E2}\u{05D0}",
        "\u{05D1}\u{05D1}\u{05D0} \u{05D1}\u{05EA}\u{05E8}\u{05D0}",
        "\u{05E1}\u{05E0}\u{05D4}\u{05D3}\u{05E8}\u{05D9}\u{05DF}",
        "\u{05DE}\u{05DB}\u{05D5}\u{05EA}",
        "\u{05E9}\u{05D1}\u{05D5}\u{05E2}\u{05D5}\u{05EA}",
        "\u{05E2}\u{05D1}\u{05D5}\u{05D3}\u{05D4} \u{05D6}\u{05E8}\u{05D4}",
        "\u{05D4}\u{05D5}\u{05E8}\u{05D9}\u{05D5}\u{05EA}",
        "\u{05D6}\u{05D1}\u{05D7}\u{05D9}\u{05DD}",
        "\u{05DE}\u{05E0}\u{05D7}\u{05D5}\u{05EA}",
        "\u{05D7}\u{05D5}\u{05DC}\u{05D9}\u{05DF}",
        "\u{05D1}\u{05DB}\u{05D5}\u{05E8}\u{05D5}\u{05EA}",
        "\u{05E2}\u{05E8}\u{05DB}\u{05D9}\u{05DF}",
        "\u{05EA}\u{05DE}\u{05D5}\u{05E8}\u{05D4}",
        "\u{05DB}\u{05E8}\u{05D9}\u{05EA}\u{05D5}\u{05EA}",
        "\u{05DE}\u{05E2}\u{05D9}\u{05DC}\u{05D4}",
        "\u{05E7}\u{05D9}\u{05E0}\u{05D9}\u{05DD}",
        "\u{05DE}\u{05D9}\u{05D3}\u{05D5}\u{05EA}",
        "\u{05E0}\u{05D3}\u{05D4}"
    ]
    
    static let masechtosYerushalmiTransliterated = [
        "Berachos",
        "Pe'ah",
        "Demai",
        "Kilayim",
        "Shevi'is",
        "Terumos",
        "Ma'asros",
        "Ma'aser Sheni",
        "Chalah",
        "Orlah",
        "Bikurim",
        "Shabbos",
        "Eruvin",
        "Pesachim",
        "Beitzah",
        "Rosh Hashanah",
        "Yoma",
        "Sukah",
        "Ta'anis",
        "Shekalim",
        "Megilah",
        "Chagigah",
        "Moed Katan",
        "Yevamos",
        "Kesuvos",
        "Sotah",
        "Nedarim",
        "Nazir",
        "Gitin",
        "Kidushin",
        "Bava Kama",
        "Bava Metzia",
        "Bava Basra",
        "Sanhedrin",
        "Makos",
        "Shevuos",
        "Avodah Zarah",
        "Horayos",
        "Nidah",
        "No Daf Today"
    ]
    
    static let masechtosYerushlmi = [
        "\u{05d1}\u{05e8}\u{05db}\u{05d5}\u{05ea}",
        "\u{05e4}\u{05d9}\u{05d0}\u{05d4}",
        "\u{05d3}\u{05de}\u{05d0}\u{05d9}",
        "\u{05db}\u{05dc}\u{05d0}\u{05d9}\u{05d9}\u{05dd}",
        "\u{05e9}\u{05d1}\u{05d9}\u{05e2}\u{05d9}\u{05ea}",
        "\u{05ea}\u{05e8}\u{05d5}\u{05de}\u{05d5}\u{05ea}",
        "\u{05de}\u{05e2}\u{05e9}\u{05e8}\u{05d5}\u{05ea}",
        "\u{05de}\u{05e2}\u{05e9}\u{05e8} \u{05e9}\u{05e0}\u{05d9}",
        "\u{05d7}\u{05dc}\u{05d4}",
        "\u{05e2}\u{05d5}\u{05e8}\u{05dc}\u{05d4}",
        "\u{05d1}\u{05d9}\u{05db}\u{05d5}\u{05e8}\u{05d9}\u{05dd}",
        "\u{05e9}\u{05d1}\u{05ea}",
        "\u{05e2}\u{05d9}\u{05e8}\u{05d5}\u{05d1}\u{05d9}\u{05df}",
        "\u{05e4}\u{05e1}\u{05d7}\u{05d9}\u{05dd}",
        "\u{05d1}\u{05d9}\u{05e6}\u{05d4}",
        "\u{05e8}\u{05d0}\u{05e9} \u{05d4}\u{05e9}\u{05e0}\u{05d4}",
        "\u{05d9}\u{05d5}\u{05de}\u{05d0}",
        "\u{05e1}\u{05d5}\u{05db}\u{05d4}",
        "\u{05ea}\u{05e2}\u{05e0}\u{05d9}\u{05ea}",
        "\u{05e9}\u{05e7}\u{05dc}\u{05d9}\u{05dd}",
        "\u{05de}\u{05d2}\u{05d9}\u{05dc}\u{05d4}",
        "\u{05d7}\u{05d2}\u{05d9}\u{05d2}\u{05d4}",
        "\u{05de}\u{05d5}\u{05e2}\u{05d3} \u{05e7}\u{05d8}\u{05df}",
        "\u{05d9}\u{05d1}\u{05de}\u{05d5}\u{05ea}",
        "\u{05db}\u{05ea}\u{05d5}\u{05d1}\u{05d5}\u{05ea}",
        "\u{05e1}\u{05d5}\u{05d8}\u{05d4}",
        "\u{05e0}\u{05d3}\u{05e8}\u{05d9}\u{05dd}",
        "\u{05e0}\u{05d6}\u{05d9}\u{05e8}",
        "\u{05d2}\u{05d9}\u{05d8}\u{05d9}\u{05df}",
        "\u{05e7}\u{05d9}\u{05d3}\u{05d5}\u{05e9}\u{05d9}\u{05df}",
        "\u{05d1}\u{05d1}\u{05d0} \u{05e7}\u{05de}\u{05d0}",
        "\u{05d1}\u{05d1}\u{05d0} \u{05de}\u{05e6}\u{05d9}\u{05e2}\u{05d0}",
        "\u{05d1}\u{05d1}\u{05d0} \u{05d1}\u{05ea}\u{05e8}\u{05d0}",
        "\u{05e9}\u{05d1}\u{05d5}\u{05e2}\u{05d5}\u{05ea}",
        "\u{05de}\u{05db}\u{05d5}\u{05ea}",
        "\u{05e1}\u{05e0}\u{05d4}\u{05d3}\u{05e8}\u{05d9}\u{05df}",
        "\u{05e2}\u{05d1}\u{05d5}\u{05d3}\u{05d4} \u{05d6}\u{05e8}\u{05d4}",
        "\u{05d4}\u{05d5}\u{05e8}\u{05d9}\u{05d5}\u{05ea}",
        "\u{05e0}\u{05d9}\u{05d3}\u{05d4}",
        "\u{05d0}\u{05d9}\u{05df} \u{05d3}\u{05e3} \u{05d4}\u{05d9}\u{05d5}\u{05dd}"
    ]
    
    public var masechtaTransliterated: String {
        Daf.masechtosBavliTransliterated[masechtaNumber]
    }
    
    public var masechta: String {
        Daf.masechtosBavli[masechtaNumber]
    }
    
    public var yerushlmiMasechtaTransliterated: String {
        Daf.masechtosYerushalmiTransliterated[masechtaNumber]
    }
    
    public var yerushalmiMasechta: String {
        Daf.masechtosYerushlmi[masechtaNumber]
    }
}
