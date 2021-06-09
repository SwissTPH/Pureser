//
//  File.swift
//  
//
//  Created by R. Makhoul on 12/11/2020.
//

import Foundation
import enum SurveyTypes.SurveyQuestionType

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
	@available(*, deprecated, message: "use 'displayQuestionAnswerTypeLevel > .none'")
	var displayQuestionAnswerTypeNextToQuestionID: Bool {
		displayQuestionAnswerTypeLevel > .none
	}

	/// The level of detail to display of the question's answer type (a.k.a.
	/// question's type) next to the question ID (a.k.a. question's name), in
	/// the converted document page.
	let displayQuestionAnswerTypeLevel: DisplayQuestionAnswerTypeLevel

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



	/// The control for the display of question's and answers' choice filter related information.
	let displayChoiceFilter: DisplayQuestionAndAnswerChoiceFilter

}

extension ResultsLayoutDisplayOptions {

	/// The levels of detail to display of the question's answer type (a.k.a.
	/// question's type) next to the question ID (a.k.a. question's name), in
	/// the converted document page.
	///
	enum DisplayQuestionAnswerTypeLevel: Comparable {
		/// Will not display question's type.
		case none

		/// Will display a very compacted question's type.
		///
		/// E.g. (unprocessed question's type => what will be displayed):
		/// - `text` => `text`
		/// - `select_one yes_no` => `select_one`
		/// - `select_one yes_no or_other` => `select_one`
		/// - `select_multiple_from_file file.xml` => `select_multiple_from_file`
		case minimal

		/// Will display a compacted question's type.
		///
		/// E.g. (unprocessed question's type => what will be displayed):
		/// - `text` => `text`
		/// - `select_one yes_no` => `select_one`
		/// - `select_one yes_no or_other` => `select_one or_other`
		/// - `select_multiple_from_file file.xml` => `select_multiple_from_file`
		case compacted

		/// Will display a detailed question's type.
		///
		/// E.g. (unprocessed question's type => what will be displayed):
		/// - `text` => `text`
		/// - `select_one yes_no` => `select_one yes_no`
		/// - `select_one yes_no or_other` => `select_one yes_no or_other`
		/// - `select_multiple_from_file file.xml` => `select_multiple_from_file file.xml`
		case detailed

		#if swift(<5.3)
		private var comparisonValue: Int {
			switch self {
			case .none: return 0
			case .minimal: return 1
			case .compacted: return 2
			case .detailed: return 3
			}
		}

		static func < (lhs: Self, rhs: Self) -> Bool {
			return lhs.comparisonValue < rhs.comparisonValue
		}
		#endif
	}

	/// The control options for the display of question's and answers' choice filter related information.
	///
	enum DisplayQuestionAndAnswerChoiceFilter: Equatable {
		/// Will not display question's and answers' choice filter related information.
		case none

		/// In case the question and its answers have choice filter/s,
		/// display the answer list when the count of answes is up to the specified `limit`,
		/// otherwise, omit the answer list and display a textfield instead.
		case upToLimitOtherwiseTextField(limit: Int)
		var upToLimit: Int? {
			if case .upToLimitOtherwiseTextField(limit: let limit) = self {
				return limit
			}
			return nil
		}

		/// Will display detailed question's and answers' choice filter related information.
		case detailed
	}

}

//--------------------------------------------------

extension ResultsLayoutDisplayOptions {
	struct Presets {

		static var developer = ResultsLayoutDisplayOptions(
			displaySurveySettingsAndInfo: true,

			displayGroupsID: true,
			displayGroupsTitle: true,

			displayOriginalQuestionLabelForDebugging: true,

			displayQuestionAnswerTypeLevel: .detailed,
			hideTheseQuestionAnswerType: [],

			displaySelectAnswersID: true,
			displaySelectTermMoreHumanReadable: true,

			fillingOutSurveyMode: true,
			readonlyAnswerSelectionInput: false,
			displaySelectInputInsideRepeatTable: false,

			skipQuestionWithType: [],
			skipQuestionsWithPatternC: false,

			displayChoiceFilter: .detailed
		)

		static var dataManager = ResultsLayoutDisplayOptions(
			displaySurveySettingsAndInfo: true,

			displayGroupsID: false,
			displayGroupsTitle: true,

			displayOriginalQuestionLabelForDebugging: false,

			displayQuestionAnswerTypeLevel: .compacted, // .detailed,
            hideTheseQuestionAnswerType: [.integer, .decimal, .calculate, .note, .text],

			displaySelectAnswersID: true,
			displaySelectTermMoreHumanReadable: false,

			fillingOutSurveyMode: false,
			readonlyAnswerSelectionInput: true,
			displaySelectInputInsideRepeatTable: false,

            skipQuestionWithType: [.calculate],
			skipQuestionsWithPatternC: true,

			displayChoiceFilter: .upToLimitOtherwiseTextField(limit: 10)
		)

		static var interviewer = ResultsLayoutDisplayOptions(
			displaySurveySettingsAndInfo: false,

			displayGroupsID: false,
			displayGroupsTitle: true,

			displayOriginalQuestionLabelForDebugging: false,

			displayQuestionAnswerTypeLevel: .none,
            hideTheseQuestionAnswerType: [.integer, .decimal, .calculate, .note, .text],

			displaySelectAnswersID: false,
			displaySelectTermMoreHumanReadable: true,

			fillingOutSurveyMode: true,
			readonlyAnswerSelectionInput: true,
			displaySelectInputInsideRepeatTable: false,

			skipQuestionWithType: [.calc],
			skipQuestionsWithPatternC: true,

			displayChoiceFilter: .upToLimitOtherwiseTextField(limit: 10)
		)

	}
}

//--------------------------------------------------
