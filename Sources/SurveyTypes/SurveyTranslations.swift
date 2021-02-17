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


			public init(
				inCommon: [Survey.DatumLanguage],
				inGroupsAndQuestions: [Survey.DatumLanguage],
				inSelectionAnswers: [Survey.DatumLanguage]
			) {
				self.inCommon = inCommon
				self.inGroupsAndQuestions = inGroupsAndQuestions
				self.inSelectionAnswers = inSelectionAnswers
			}
		}


		public init(
			all: [Survey.DatumLanguage],
			forLabelCluster: Survey.LanguagesAvailable.ForLabelCluster
		) {
			self.all = all
			self.forLabelCluster = forLabelCluster
		}

	}

}

//--------------------------------------------------

extension Survey {

	public struct DatumLanguage: Codable {
		public var languageStringID: String /// Make sure `LocalizedDatum.languageStringID` has the same type.
		public var languageLabel: String /// Make sure `LocalizedDatum.languageLabel` has the same type.


		public init(
			languageStringID: String,
			languageLabel: String
		) {
			self.languageStringID = languageStringID
			self.languageLabel = languageLabel
		}
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

		public var datumLanguage: DatumLanguage

		@available(*, deprecated, renamed: "datumLanguage.languageStringID")
		public var languageStringID: String /// Must be same type as `DatumLanguage.languageStringID`.
		{ datumLanguage.languageStringID }
		@available(*, deprecated, renamed: "datumLanguage.languageLabel")
		public var languageLabel: String /// Must be same type as `DatumLanguage.languageLabel`.
		{ datumLanguage.languageLabel }

		public var translation: String?


		public init(
			datumLanguage: Survey.DatumLanguage,
			translation: String? = nil
		) {
			self.datumLanguage = datumLanguage
			self.translation = translation
		}
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
