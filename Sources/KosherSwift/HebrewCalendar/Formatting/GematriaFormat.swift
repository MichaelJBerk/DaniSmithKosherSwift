//
//  GematriaFormat.swift
//  KosherSwift
//
//  Created by Michael Berk on 5/20/26.
//

import Foundation

public struct GematriaFormat: Codable, Equatable, Hashable {
	public var gershGershayim: Bool
	public var finalFormLetters: Bool
	public var longHebrewYears: Bool
	
	public init(gershGershayim: Bool = true, finalFormLetters: Bool = true, longHebrewYears: Bool = false) {
		self.gershGershayim = gershGershayim
		self.finalFormLetters = finalFormLetters
		self.longHebrewYears = longHebrewYears
	}
}
