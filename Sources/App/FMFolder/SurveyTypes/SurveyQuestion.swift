//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

public struct SurveyQuestion: Codable, SurveyItemProtocol {

	var type: SurveyQuestionType
	var typeFull: String

	var answers: [SurveySelectionQuestionAnswer]

	var name: String

	var label: Survey.LocalizedData
	var labelFull: Survey.LocalizedData

	var hint: Survey.LocalizedData

	var relevance: String?
	var relevanceStepByStep: [String] // for debugging
	var relevanceUnprocessed: String?

	//var `required`
	//var notes
	//var appearance
	//var calculation
	//var `default`
	//
	//var constraint
	//var contraint_message // ::English
	//
	//var read_only

	public init(
		type: SurveyQuestionType,
		typeFull: String,

		answers: [SurveySelectionQuestionAnswer],
		name: String,

		label: Survey.LocalizedData,
		labelFull: Survey.LocalizedData,

		hint: Survey.LocalizedData,

		relevance: String? = nil,
		relevanceStepByStep: [String] = [],
		relevanceUnprocessed: String? = nil
	) {
		self.type = type
		self.typeFull = typeFull

		self.answers = answers
		self.name = name

		self.label = label
		self.labelFull = labelFull

		self.hint = hint

		self.relevance = relevance
		self.relevanceStepByStep = relevanceStepByStep
		self.relevanceUnprocessed = relevanceUnprocessed
	}

	public init(
		type typeRawValue: String,
		typeFull: String,

		answers: [SurveySelectionQuestionAnswer],
		name: String,

		label: Survey.LocalizedData,
		labelFull: Survey.LocalizedData,

		hint: Survey.LocalizedData,

		relevance: String? = nil,
		relevanceStepByStep: [String] = [],
		relevanceUnprocessed: String? = nil
	) {
		let typeRawValue = typeRawValue.trimmingCharacters(in: .whitespacesAndNewlines)
		let type = SurveyQuestionType(rawValue: typeRawValue) ?? .unknown

		self.init(
			type: type,
			typeFull: typeFull,

			answers: answers,
			name: name,

			label: label,
			labelFull: labelFull,

			hint: hint,

			relevance: relevance,
			relevanceStepByStep: relevanceStepByStep,
			relevanceUnprocessed: relevanceUnprocessed
		)
	}

}

//--------------------------------------------------
