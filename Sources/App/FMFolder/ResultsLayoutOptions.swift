//
//  File.swift
//  
//
//  Created by R. Makhoul on 12/11/2020.
//

import Foundation

//--------------------------------------------------

struct ResultsLayoutDisplayOptions {

	///
	let displaySurveySettingsAndInfo: Bool



	///
	let displayGroupsID: Bool

	///
	let displayGroupsTitle: Bool



	///
	let displayOriginalQuestionLabelForDebugging: Bool



	///
	let displayQuestionAnswerTypeNextToQuestionID: Bool

	///
	let hideTheseQuestionAnswerType: Set<SurveyQuestionType>



	///
	let displaySelectAnswersID: Bool

	///
	let displaySelectTermMoreHumanReadable: Bool



	///
	let fillingOutSurveyMode: Bool

	/// HTML radio and checkbox inputs to be readonly, so they can not be accidentally checked before printing.
	///
	/// Note: if `true` this will technically disable the html radio/checkbox inputs by adding `disabled=""` as
	/// an attribute to the `type="radio"` and `type="checkbox"` html inputs, because these types of
	/// inputs do not support the `readonly=""` attribute.
	///
	/// This matters only if `fillingOutSurveyMode` is true.
	let readonlyAnswerSelectionInput: Bool

	/// This matters only if `fillingOutSurveyMode` is true.
	let displaySelectInputInsideRepeatTable: Bool



	/// Skip (do not show) questions with `SurveyQuestionType` specified.
	let skipQuestionWithType: Set<SurveyQuestionType>

	/// Skip (do not show) questions with Question ID containing "_check" AND is of "note" question type.
	let skipQuestionsWithPatternC: Bool

}

//--------------------------------------------------

extension ResultsLayoutDisplayOptions {
	struct Presets {

		static var developer = ResultsLayoutDisplayOptions(
			displaySurveySettingsAndInfo: true,

			displayGroupsID: true,
			displayGroupsTitle: true,

			displayOriginalQuestionLabelForDebugging: true,

			displayQuestionAnswerTypeNextToQuestionID: true,
			hideTheseQuestionAnswerType: [],

			displaySelectAnswersID: true,
			displaySelectTermMoreHumanReadable: true,

			fillingOutSurveyMode: true,
			readonlyAnswerSelectionInput: false,
			displaySelectInputInsideRepeatTable: false,

			skipQuestionWithType: [],
			skipQuestionsWithPatternC: false
		)

		static var dataManager = ResultsLayoutDisplayOptions(
			displaySurveySettingsAndInfo: true,

			displayGroupsID: false,
			displayGroupsTitle: true,

			displayOriginalQuestionLabelForDebugging: false,

			displayQuestionAnswerTypeNextToQuestionID: true,
			hideTheseQuestionAnswerType: [.integer, .decimal, .calc, .note, .text],

			displaySelectAnswersID: true,
			displaySelectTermMoreHumanReadable: false,

			fillingOutSurveyMode: false,
			readonlyAnswerSelectionInput: true,
			displaySelectInputInsideRepeatTable: false,

			skipQuestionWithType: [.calc],
			skipQuestionsWithPatternC: true
		)

		static var interviewer = ResultsLayoutDisplayOptions(
			displaySurveySettingsAndInfo: false,

			displayGroupsID: false,
			displayGroupsTitle: true,

			displayOriginalQuestionLabelForDebugging: false,

			displayQuestionAnswerTypeNextToQuestionID: false,
			hideTheseQuestionAnswerType: [.integer, .decimal, .calc, .note, .text],

			displaySelectAnswersID: false,
			displaySelectTermMoreHumanReadable: true,

			fillingOutSurveyMode: true,
			readonlyAnswerSelectionInput: true,
			displaySelectInputInsideRepeatTable: false,

			skipQuestionWithType: [.calc],
			skipQuestionsWithPatternC: true
		)

	}
}

//--------------------------------------------------
