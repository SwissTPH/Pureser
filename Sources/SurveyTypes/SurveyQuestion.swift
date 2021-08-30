//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

public struct SurveyQuestion: Codable, SurveyItemProtocol {

	private var typeAndOptions: FormQuestionTypeAndOptions
	public var type: SurveyQuestionType {
		get {
			typeAndOptions.type
		}
		set {
			typeAndOptions.type = newValue
		}
	}
	public var typeOptions: FormQuestionTypeOptions? {
		get {
			typeAndOptions.options
		}
		set {
			typeAndOptions.options = newValue
		}
	}
	public var typeFull: String

	public var answers: [SurveySelectionQuestionAnswer]

	public var name: String

	public var label: Survey.LocalizedData
	public var labelFull: Survey.LocalizedData

	public var hint: Survey.LocalizedData

	public var relevance: Survey.LocalizedData?
	public var relevanceStepByStep: [Survey.LocalizedData] // for debugging
	public var relevanceUnprocessed: String?

	public var ageGroup: QuestionAgeGroup?

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

	public var choiceFilterUnprocessed: String?

	public var warnings: [SurveyWarning]? {
		didSet {
			self.warnings = !(self.warnings?.isEmpty ?? true) ? self.warnings : nil
		}
	}


	public init(
		typeAndOptions: FormQuestionTypeAndOptions,
		typeFull: String,

		answers: [SurveySelectionQuestionAnswer],
		name: String,

		label: Survey.LocalizedData,
		labelFull: Survey.LocalizedData,

		hint: Survey.LocalizedData,

		relevance: Survey.LocalizedData? = nil,
		relevanceStepByStep: [Survey.LocalizedData] = [],
		relevanceUnprocessed: String? = nil,

		ageGroup: QuestionAgeGroup? = nil,

		choiceFilterUnprocessed: String?,

		warnings: [SurveyWarning]? = nil
	) {
		self.typeAndOptions = typeAndOptions
		self.typeFull = typeFull

		self.answers = answers
		self.name = name

		self.label = label
		self.labelFull = labelFull

		self.hint = hint

		self.relevance = relevance
		self.relevanceStepByStep = relevanceStepByStep
		self.relevanceUnprocessed = relevanceUnprocessed

		self.ageGroup = ageGroup

		self.choiceFilterUnprocessed = choiceFilterUnprocessed

		self.warnings = !(warnings?.isEmpty ?? true) ? warnings : nil
	}

}

//--------------------------------------------------

extension SurveyQuestion {

	/// Whether this question has any answer with choice filters.
	public var hasAnswersWithChoiceFilters: Bool {
		self.answers.hasChoiceFilters
	}

	/// Whether this question and it's answers are with choice filters.
	public var hasChoiceFilters: Bool {
		!(self.choiceFilterUnprocessed?.isEmpty ?? true)
			&& self.hasAnswersWithChoiceFilters
	}

}

//--------------------------------------------------
