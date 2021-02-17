//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

public struct SurveyQuestion: Codable, SurveyItemProtocol {

	public var type: SurveyQuestionType
	public var typeFull: String

	public var answers: [SurveySelectionQuestionAnswer]

	public var name: String

	public var label: Survey.LocalizedData
	public var labelFull: Survey.LocalizedData

	public var hint: Survey.LocalizedData

	public var relevance: String?
	public var relevanceStepByStep: [String] // for debugging
	public var relevanceUnprocessed: String?

	//public var `required`
	//public var notes
	//public var appearance
	//public var calculation
	//public var `default`
	//
	//public var constraint
	//public var contraint_message // ::English
	//
	//public var read_only

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
