//
//  File.swift
//  
//
//  Created by R. Makhoul on 05/12/2020.
//

import Foundation

//--------------------------------------------------

extension Survey {

	public struct LanguagesAvailable: Codable {

		public var all: [Survey.DatumLanguage]

		public var forLabelCluster: ForLabelCluster

		public struct ForLabelCluster: Codable {
			public var inCommon: [Survey.DatumLanguage]
			public var inGroupsAndQuestions: [Survey.DatumLanguage]
			public var inSelectionAnswers: [Survey.DatumLanguage]
		}

	}

}

//--------------------------------------------------

extension Survey {

	public struct DatumLanguage: Codable {
		var languageStringID: String /// Make sure `LocalizedDatum.languageStringID` has the same type.
		var languageLabel: String /// Make sure `LocalizedDatum.languageLabel` has the same type.
	}

}

extension Survey.DatumLanguage: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		return lhs.languageLabel == rhs.languageLabel
			&& lhs.languageStringID == rhs.languageStringID
	}
}

extension Collection where Element == Survey.DatumLanguage {

}

//--------------------------------------------------

extension Survey {

	public typealias LocalizedData = [LocalizedDatum]

	public struct LocalizedDatum: Codable {

		var datumLanguage: DatumLanguage

		@available(*, deprecated, renamed: "datumLanguage.languageStringID")
		var languageStringID: String /// Must be same type as `DatumLanguage.languageStringID`.
		{ datumLanguage.languageStringID }
		@available(*, deprecated, renamed: "datumLanguage.languageLabel")
		var languageLabel: String /// Must be same type as `DatumLanguage.languageLabel`.
		{ datumLanguage.languageLabel }

		var translation: String?
	}

}

extension Survey.LocalizedDatum {

	public var isVacant: Bool {
		self.translation?.isEmpty ?? true
	}

	public var nilIfVacant: Self? {
		return self.isVacant ? nil : self
	}

}

extension Collection where Element == Survey.LocalizedDatum {

	public var isVacant: Bool {
		self.isEmpty || self.allSatisfy { $0.isVacant }
	}

}

extension Array where Element == Survey.LocalizedDatum {

	/// Filters and returns only the common ones.
	public func filterUsingDatumLanguages(_ array: [Survey.DatumLanguage]) -> [Survey.LocalizedDatum] {
		let arrayA = self
		let arrayB = array

		return arrayA.filter { localizedDatum in
			arrayB.contains(localizedDatum.datumLanguage)
		}
	}

}


//--------------------------------------------------
