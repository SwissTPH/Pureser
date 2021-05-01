//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

public struct SurveySelectionQuestionAnswer: Codable {
	public var answerID: String
	public var answerLabel: Survey.LocalizedData

	public var choiceFilters: [ChoiceFilter]?


	public init(
		answerID: String,
		answerLabel: Survey.LocalizedData,

		choiceFilters: [ChoiceFilter]? = nil
	) {
		self.answerID = answerID
		self.answerLabel = answerLabel

		self.choiceFilters = choiceFilters
	}
}

extension Collection where Element == SurveySelectionQuestionAnswer {

	/// Whether this collection has any answer with choice filters.
	public var hasChoiceFilters: Bool {
		self.contains { (choice: SurveySelectionQuestionAnswer) in
			choice.choiceFilters?.contains { (choiceFilter: ChoiceFilter) in
				!choiceFilter.name.isEmpty
			} ?? false
		}
	}

}

//--------------------------------------------------

/// A filter category for choice filters (cascading questions).
public struct ChoiceFilter: Codable {
	/// The filter's name or key.
	public var name: String
	/// The filter's value.
	public var value: String

	public init(name: String, value: String) {
		self.name = name
		self.value = value
	}
}

//--------------------------------------------------
