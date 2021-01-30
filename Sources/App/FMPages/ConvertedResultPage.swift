//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation
import HTML
import Vapor

final class ConvertedDocumentPage {

	//
	private var survey: Survey
	//
	private var uploadPageFormData: UploadPageFormData?

	//
	private var resultsLayoutDisplayOptions: ResultsLayoutDisplayOptions

	//
	private var debug: Bool

	//--------------------------------------------------

	//
	init(survey: Survey, uploadPageFormData: UploadPageFormData? = nil) {

		//
		self.survey = survey
		//
		self.uploadPageFormData = uploadPageFormData

		//
		let printVersion = uploadPageFormData?.printVersion

		//
		self.resultsLayoutDisplayOptions = {
			let resultsLayoutDisplayOptions: ResultsLayoutDisplayOptions

			// Restrict .developer preset to debugging in development environment only.
			if Settings.debug && printVersion == .developer {
				resultsLayoutDisplayOptions = ResultsLayoutDisplayOptions.Presets.developer
			} else {
				switch printVersion {
				case .dataManager:
					resultsLayoutDisplayOptions = ResultsLayoutDisplayOptions.Presets.dataManager
				case .interviewer:
					resultsLayoutDisplayOptions = ResultsLayoutDisplayOptions.Presets.interviewer
				default:
					resultsLayoutDisplayOptions = ResultsLayoutDisplayOptions.Presets.dataManager
				}
			}

			return resultsLayoutDisplayOptions
		}()

		//
		self.debug = Settings.debug && printVersion == .developer
	}

	//--------------------------------------------------
	//--------------------------------------------------

	// MARK: Nesting helpers

	///
	private var nestedSurveyGroups: [SurveyGroup] = []

	///
	private var nestedLevel: Int {
		nestedSurveyGroups.count
	}

	///
	private var currentlyNested: Bool {
		nestedSurveyGroups.count > 0
	}

	///
	private var currentRepeatTableNestedLevel: Int {
		nestedSurveyGroups.filter { surveyGroup in surveyGroup.groupType == .repeatTable }.count
	}

	///
	private var currentlyInsideRepeatTable: Bool {
		nestedSurveyGroups.filter { surveyGroup in surveyGroup.groupType == .repeatTable }.count > 0
	}

	// MARK: SurveyItems helpers

	private func helper(surveyItem: SurveyItem) -> Node {
		let output: Node

		switch surveyItem {
		case .group(let surveyGroup):
			//
			nestedSurveyGroups.append(surveyGroup)

			//
			output = helper(surveyGroup: surveyGroup)

			//
			if currentlyNested {
				nestedSurveyGroups.removeLast()
			}
		case .question(let surveyQuestion):
			//
			output = helper(surveyQuestion: surveyQuestion)
		}

		return output
	}

	private func helper(surveyGroup: SurveyGroup) -> Node {

		let defualtRepeatCount: Int = 5

		return nodeContainer {
			div(class: "survey-group") {
				if resultsLayoutDisplayOptions.displayGroupsID || resultsLayoutDisplayOptions.displayGroupsTitle {
					div(style: "margin-top: 25px;text-align: center;") {
						// for debugging:
						if Settings.Debug.SurveyLocalizedData.surveyGroupLabel {
							Self.debugHelper(localizedData: surveyGroup.label, debugTitle: "Group's original label: ")
						}

						// Group's relevance
						relevanceHelper(surveyItem: surveyGroup)

						// Group's label
						div {
							if resultsLayoutDisplayOptions.displayGroupsID {
								span(class: "faded-l") { "[" }
								span(class: "faded-d") { surveyGroup.name }
								span(class: "faded-l") { "]" }
							}

							if resultsLayoutDisplayOptions.displayGroupsTitle {
								helper(localizedData: surveyGroup.label, ifTranslationIsUnavailable: Placeholders.untitledGroupLabel, htmlClass: .groupsAndQuestions, styleCSS: "margin-top: 3px;", tag: .h2)
							}
						}
					}
				} // end if

				if surveyGroup.groupType == .repeatTable {
					table(class: "repeat-group") {
						thead {
							tr {
								th {
									"Question"
								}
								(1...defualtRepeatCount).map { x in
									th {
										"Person \(x)"
									}
								}
							}
						}
						tbody {
							surveyGroup.items.map { (surveyItem: SurveyItem) -> Node in
								return nodeContainer {
									tr {
										td {
											helper(surveyItem: surveyItem)
										}
										(1...defualtRepeatCount).map { x in
											td {
												"&nbsp;"
											}
										}
									}
								} // end nodeContainer

								if case .group(var surveyGroup) = surveyItem {
									surveyGroup.groupType = .repeatTable
									let surveyItem = SurveyItem.group(surveyGroup)
									return nodeContainer {
										tr {
											td(colspan: "\(1 + defualtRepeatCount)") {
												helper(surveyItem: surveyItem)
											}
										}
									}
								} else if case .question = surveyItem {
									return nodeContainer {
										tr {
											td {
												helper(surveyItem: surveyItem)
											}
											(1...defualtRepeatCount).map { x in
												td {
													"&nbsp;"
												}
											}
										}
									} // end nodeContainer
								} else {
									return nodeContainer()
								}
							} // end .map
						}
					}
				}
				else {
					surveyGroup.items.map { (surveyItem: SurveyItem) -> Node in
						helper(surveyItem: surveyItem)
					} // end .map
				}

			}
		} // end nodeContainer
	}

	private func helper(surveyQuestion: SurveyQuestion) -> Node {

		if resultsLayoutDisplayOptions.skipQuestionWithType.contains(surveyQuestion.type) {
			return []
		}

		if resultsLayoutDisplayOptions.skipQuestionsWithPatternC
			&& surveyQuestion.name.contains("_check") && surveyQuestion.type == .note {
			return []
		}

		return nodeContainer {
			div(class: "survey-question") {
				div(style: "margin-bottom: 10px;") {
					// for debugging:
					if Settings.Debug.SurveyLocalizedData.surveyQuestionLabel || resultsLayoutDisplayOptions.displayOriginalQuestionLabelForDebugging {
						Self.debugHelper(localizedData: surveyQuestion.labelFull, debugTitle: "Question's original label: ")

						hr(class: "double thin v-spaced red")
					}

					// Question's relevance.
					relevanceHelper(surveyItem: surveyQuestion)

					// Question's info, e.g. question nameID and type.
					div {
						span(class: "faded-l") { "[" }
						span(class: "faded-d") { surveyQuestion.name }
						span(class: "faded-l") { "]" }

						if resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
							span {
								span(class: "faded-l") { "[" }
								span(class: "faded-d") { surveyQuestion.type.rawValue }
								span(class: "faded-l") { "]" }
							}
						}
					}

					// Question's label.
					helper(localizedData: surveyQuestion.label, htmlClass: .groupsAndQuestions, styleCSS: "margin-top: 3px;font-weight: bold;")

					// Question's hint.
					// If hint is present in at least one language then show hint.
					if surveyQuestion.hint.filter({ hint in !(hint.translation ?? "").isEmpty }).count > 0 {
						helper(localizedData: surveyQuestion.hint, htmlClass: .groupsAndQuestions, styleCSS: "margin-top: 3px;font-style: italic;font-size: 11pt;")
					}
				}

				if surveyQuestion.type == .start {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.start) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div { "Start time:" + (false ? " __ : __ : __ (HH:MM:SS)" : "") }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .end {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.end) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div { "End time:" + (false ? " __ : __ : __ (HH:MM:SS)" : "") }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .today {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div { "Today: __ / __ / ____ (DD/MM/YYYY)" }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .date {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div { "Date: __ / __ / ____ (DD/MM/YYYY)" }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .deviceID {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.deviceID) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Device ID:" }
						(1...2).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .simSerial {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.simSerial) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "SIM serial:" }
						(1...2).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .phoneNumber {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.phoneNumber) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Phone number:" }
						(1...2).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .startGeopoint {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.startGeopoint) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Start geopoint:" }
						(1...2).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .geopoint {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.geopoint) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Geopoint:" }
						(1...2).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .barcode {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.barcode) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Barcode:" }
						(1...2).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .range {
					if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.range) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Range:" }
						(1...2).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}

				else if surveyQuestion.type == .integer {
					if !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.integer) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Integer:" }
						(1...1).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .decimal {
					if !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.decimal) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Decimal:" }
						(1...1).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .calc {
					if !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.calc) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Calculate:" }
						(1...3).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}

				else if surveyQuestion.type == .note {
					if !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.note) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Note:" }
						(1...3).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .text {
					if !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.text) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Text:" }
						(1...3).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}

				else if surveyQuestion.type == .audit {
					if !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.audit) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Audit:" }
						(1...3).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .rank {
					if !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.rank) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Rank:" }
						(1...3).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}
				else if surveyQuestion.type == .trigger {
					if !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.trigger) && !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
						div(class: "faded-dd") { "Trigger:" }
						(1...3).map { _ in br() }
					} else {
						(1...1).map { _ in br() }
					}
				}

				else if surveyQuestion.type == .selectOne || surveyQuestion.type == .selectMultiple {
					if !surveyQuestion.answers.isEmpty {
						if true {
							if resultsLayoutDisplayOptions.fillingOutSurveyMode || !resultsLayoutDisplayOptions.displayQuestionAnswerTypeNextToQuestionID {
								if surveyQuestion.type == .selectOne && !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.selectOne) {
									div(class: "faded-dd") {
										if resultsLayoutDisplayOptions.displaySelectTermMoreHumanReadable {
											"Choose only one option:"
										} else {
											"Select one:"
										}
									}
								} else if surveyQuestion.type == .selectMultiple && !resultsLayoutDisplayOptions.hideTheseQuestionAnswerType.contains(.selectMultiple) {
									div(class: "faded-dd") {
										if resultsLayoutDisplayOptions.displaySelectTermMoreHumanReadable {
											"Choose one or more options:"
										} else {
											"Select multiple:"
										}
									}
								} else {
									//
								}
							}

							table(class: "answers") {
								tbody {
									surveyQuestion.answers.map { (surveySelectionQuestionAnswer: SurveySelectionQuestionAnswer) -> Node in nodeContainer {
										tr {
											if surveyQuestion.type == .selectOne && resultsLayoutDisplayOptions.fillingOutSurveyMode && (!currentlyInsideRepeatTable || currentlyInsideRepeatTable && resultsLayoutDisplayOptions.displaySelectInputInsideRepeatTable) {
												td(class: "answer-input-td") {
													input(disabled: resultsLayoutDisplayOptions.readonlyAnswerSelectionInput, name: surveyQuestion.name, type: "radio", value: surveySelectionQuestionAnswer.answerID)
												}
											}
											else if surveyQuestion.type == .selectMultiple && resultsLayoutDisplayOptions.fillingOutSurveyMode && (!currentlyInsideRepeatTable || currentlyInsideRepeatTable && resultsLayoutDisplayOptions.displaySelectInputInsideRepeatTable) {
												td(class: "answer-input-td") {
													input(disabled: resultsLayoutDisplayOptions.readonlyAnswerSelectionInput, name: surveyQuestion.name, type: "checkbox", value: surveySelectionQuestionAnswer.answerID)
												}
											}

											if resultsLayoutDisplayOptions.displaySelectAnswersID {
												td(class: "answer-string-id-td") {
													span(class: "faded-l") { "[" }
													span(class: "faded-d") { surveySelectionQuestionAnswer.answerID }
													span(class: "faded-l") { "]" }
												}
											}

											td(class: "answer-text-td") {
												if Settings.Debug.SurveyLocalizedData.surveyQuestionSelectionAnswerLabel {
													Self.debugHelper(localizedData: surveySelectionQuestionAnswer.answerLabel, debugTitle: "Answer's original label: ")
												}

												helper(localizedData: surveySelectionQuestionAnswer.answerLabel, htmlClass: .selectionAnswers, styleCSS: "")
											}
										}
									}} // end .map & nodeContainer
								}
							}
						} else {
							surveyQuestion.answers.map { (surveySelectionQuestionAnswer: SurveySelectionQuestionAnswer) -> Node in nodeContainer {
								div {
									"[" + surveySelectionQuestionAnswer.answerID + "]"
									helper(localizedData: surveySelectionQuestionAnswer.answerLabel, htmlClass: .selectionAnswers, styleCSS: "")
								}
							}} // end .map & nodeContainer
						}
					} else {
						span(class: "faded-l") { "No answers were provided." }
					}
				}

				else {
					span(class: "faded-l") { "Question type is unknown (" + surveyQuestion.typeFull + ")." }
				}

			}
		}
	}

	//--------------------------------------------------

	private func relevanceHelper(surveyItem: SurveyItemProtocol) -> Node {
		nodeContainer {
			// for debugging:
			if Settings.debug && self.debug {
				if true {
					table {
						thead {
							tr {
								th(colspan: "2") {
									"Relevance step-by-step"
								}
							}
						}
						tbody {
							(0..<surveyItem.relevanceStepByStep.count).map { step in
								tr {
									td { "\(step)" }
									td { surveyItem.relevanceStepByStep[step] }
								}
							}
						}
					}
					br()
				}

				div {
					div(class: "dbg-lightgrey", style: "font-style: italic;") { "Original relevance: " }
					div(class: "dbg-darkgrey") { surveyItem.relevanceUnprocessed ?? Placeholders.unknownRelevance }
				}

				hr(class: "double thin v-spaced red")
			}

			// Relevance
			if surveyItem.relevance != nil {
				div(class: "relevance") {
					div {
						div(class: "faded-l") { "&bull; Relevant when: " }
						div(class: "faded-d") { surveyItem.relevance ?? Placeholders.unknownRelevance }
					}
				}
			}
		}
	}

	//--------------------------------------------------
	//--------------------------------------------------

	// MARK: LocalizedData helpers

	static func debugHelper(localizedData: Survey.LocalizedData, debugTitle: String) -> Node {
		nodeContainer {
			div {
				div(class: "dbg-lightgrey", style: "font-weight: bold;text-align: center;font-style: italic;") { debugTitle }

				table(class: "dbg-darkgrey", style: "width: 100%;") {
					thead {
						tr {
							th(style: "width: 25%;") { "Language StringID" }
							th(style: "width: 25%;") { "Language Label" }
							th(style: "width: 50%;") { "Translation" }
						}
					}
					tbody {
						localizedData.map { localizedDatum in
							tr {
								td { localizedDatum.languageStringID }
								td { localizedDatum.languageLabel }
								td {
									if let translation = localizedDatum.translation, !translation.isEmpty {
										translation
									} else {
										span(style: "color: rgb(243, 62, 43);") {
											"Translation not available."
										}
									}
								}
							}
						} // end .map
					}
				}
			}
		}
	}

	enum SurveyTranslationHTMLTag: String {
		case h2
		case div
		case span
	}

	enum SurveyTranslationHTMLClass: String {
		case groupsAndQuestions = "group-question"
		case selectionAnswers = "selection-answer"

		var className: String { "survey-translated-" + self.rawValue }
	}

	static func helper(
		survey: Survey,
		localizedData: Survey.LocalizedData,
		ifTranslationIsUnavailable placeholderIfNil: String? = nil,
		htmlClass: SurveyTranslationHTMLClass,
		styleCSS: String,
		tag: SurveyTranslationHTMLTag = .div
	) -> Node {
		nodeContainer {
			localizedData.map { localizedDatum -> Node in
				let displayCSS = localizedDatum.languageLabel != survey.defaultLanguage.languageLabel ? "display: none;" : ""

				let translation: String
				if let _translation = localizedDatum.translation, !_translation.isEmpty {
					translation = _translation
				} else if let placeholderIfNil = placeholderIfNil {
					translation = placeholderIfNil
				} else {
					return nodeContainer()
				}

				return nodeContainer {
					if tag == .h2 {
						h2(
							class: "survey-translation survey-translated-" + htmlClass.rawValue + " survey-lang-" + localizedDatum.languageStringID,
							style: "margin-top: 3px;" + displayCSS + styleCSS
						) {
							translation
						}
					} else if tag == .span {
						span(
							class: "survey-translation survey-translated-" + htmlClass.rawValue + " survey-lang-" + localizedDatum.languageStringID,
							style: displayCSS + styleCSS
						) {
							translation
						}
					} else {
						div(
							class: "survey-translation survey-translated-" + htmlClass.rawValue + " survey-lang-" + localizedDatum.languageStringID,
							style: displayCSS + styleCSS
						) {
							translation
						}
					}
				}
			} // end .map
		}
	}

	private func helper(
		localizedData: Survey.LocalizedData,
		ifTranslationIsUnavailable placeholderIfNil: String? = nil,
		htmlClass: SurveyTranslationHTMLClass,
		styleCSS: String,
		tag: SurveyTranslationHTMLTag = .div
	) -> Node {
		nodeContainer {
			var localizedData = localizedData

			if Settings.SurveyLocalizedData.onlyCommonLanguagesForLabelCluster {
				localizedData = localizedData.filterUsingDatumLanguages(survey.languagesInCommonForLabelCluster)
			}

			return Self.helper(
				survey: self.survey,
				localizedData: localizedData,
				ifTranslationIsUnavailable: placeholderIfNil,
				htmlClass: htmlClass,
				styleCSS: styleCSS,
				tag: tag
			)
		}
	}



	//--------------------------------------------------



	// MARK: Page HTML

	func pageHTML() -> Node {

		//
		var _pageCSS: [String] = []

		_pageCSS.append(
			"""
			body {
				font-family: "Times New Roman", Times, serif;
			}
			"""
		)

		_pageCSS.append(
			"""
			.dbg-lightgrey {
				color: #99ccff;
			}
			.dbg-darkgrey {
				color: #66b3ff;
			}

			hr.thin {
				height: 1px;
				border: 0;
				border-top: 1px solid #333;
			}
			hr.double.thin {
				border-width: 3px;
			}
			hr.thin.v-spaced {
				margin: 15px auto;
			}
			hr.red.thin {
				border-color: #ff0066;
			}
			"""
		)

		_pageCSS.append(
			"""
			.faded-l {
				color: #9E9E9E;
			}
			.faded-d {
				color: #7D7D7D;
			}
			.faded-dd {
				color: #6C6C6C;
			}

			.faded-l {
				color: #333;
			}
			.faded-d {
				color: #333;
			}
			.faded-dd {
				color: #333;
			}
			"""
		)

		_pageCSS.append(
			"""
			table {
				border-collapse: separate;
				border-spacing: 0;
			}
			table > * > tr > th,
			table > * > tr > td {
				border-right: 1px solid #D1D1D1;
				border-bottom: 1px solid #D1D1D1;
			}
			table > * > tr > th:first-of-type,
			table > * > tr > td:first-of-type {
				border-left: 1px solid #D1D1D1;
			}
			table > :first-child > tr:first-of-type > th,
			table > :first-child > tr:first-of-type > td {
				border-top: 1px solid #D1D1D1;
			}

			table > :first-child > tr:first-of-type > th:first-of-type,
			table > :first-child > tr:first-of-type > td:first-of-type {
				border-top-left-radius: 6px;
			}
			table > :first-child > tr:first-of-type > th:last-of-type,
			table > :first-child > tr:first-of-type > td:last-of-type {
				border-top-right-radius: 6px;
			}
			table > :last-child > tr:last-of-type > td:first-of-type {
				border-bottom-left-radius: 6px;
			}
			table > :last-child > tr:last-of-type > td:last-of-type {
				border-bottom-right-radius: 6px;
			}
			"""
		)

		_pageCSS.append(
			"""
			div.tools {
				margin: 5px 0px 35px;
				padding: 10px;
				border: 1px solid DodgerBlue;
				border-radius: 6px;

				text-align: center;
			}

			div.tools input.tool-button {
				width: 25%;
			}

			div.tools > .tool-select {
				width: 25%;
			}
			"""
		)

		_pageCSS.append(
			"""
			div.survey-info-con {
				margin: 12px 0px;
			}
			table.survey-info {
				width: 100%;
			}
			table.survey-info th, table.survey-info td {
				padding: 3px 6px;
				text-align: center;

				width: 50%;
			}
			"""
		)

		_pageCSS.append(
			"""
			table.answers {
				width: 100%;
				margin: 0px auto;
			}
			table.answers th,
			table.answers td {
				padding: 3px 6px;
			}
			table.answers tr td.answer-string-id-td {
				white-space: nowrap;
				text-align: center;
			}
			table.answers tr td.answer-text-td {
				width: 90%;
				text-align: left;
			}
			table.answers tr td.answer-input-td {
				text-align: center;
			}
			"""
		)

		_pageCSS.append(
			"""
			table.repeat-group {
				width: 100%;
				margin: 0px auto;
			}
			table.repeat-group > * > tr > th,
			table.repeat-group > * > tr > td {
				border-color: #919191 !important;
			}
			table.repeat-group > thead > tr > th,
			table.repeat-group > tbody > tr > th {
				padding: 6px 5px;
			}
			table.repeat-group > tbody > tr > td {
				padding: 12px 10px;
			}
			"""
		)

		_pageCSS.append(
			"""
			div.survey-group {
				margin: 8px 0px;
				padding: 8px;
				border: 1px solid #818181;
				border-radius: 6px;
			}

			div.survey-question {
				margin: 8px 0px;
				padding: 10px;
				border: 1px solid #717171;
				border-radius: 6px;
			}
			table.repeat-group td > div.survey-question {
				margin: 0;
				padding: 0;
				border: none;
			}
			"""
		)

		if Settings.Feature.itemRelevance {
			let relevanceSegmentBorderRadius = "5px"
			_pageCSS.append(
				"""
				.relevance {

				}

				.relevance > div {
					margin-bottom: 20px;
				}

				/*
				.relevance-precondition {
					--color: #c1c1d4;
					--border-radius: 5px;

					color: var(--color);
					border: 1px solid var(--color);
					border-radius: var(--border-radius);
					padding: 1px;
				}
				*/

				.relevance-precondition * {
					padding: 3px 5px;
					line-height: 30px;
					font-style: normal;
				}

				.relevance-precondition > .relevance-segment {
					--border-radius: \(relevanceSegmentBorderRadius);
				}
				.relevance-precondition > .relevance-segment.rsg-qs {
					--color: #6589ff;

					color: var(--color);
					border: 1px solid var(--color);
					border-radius: var(--border-radius);
				}
				.relevance-precondition > .relevance-segment.rsg-co {
					--color: #c08c80;

					color: var(--color);
					border: none;
					border-radius: var(--border-radius);
				}
				.relevance-precondition > .relevance-segment.rsg-as {
					--color: #5da2a3;

					color: var(--color);
					border: 1px solid var(--color);
					border-radius: var(--border-radius);
				}
				.relevance-precondition > .relevance-segment.rsg-tp {
					--color: #c08c80;

					color: var(--color);
					border: none;
					border-radius: var(--border-radius);

					margin-right: -5px;
				}

				.relevance-precondition > .relevance-segment.rsg-lo {
					--color: #8c4099;

					color: var(--color);
					border: 3px double var(--color);
					border-radius: var(--border-radius);
				}
				.relevance-precondition > .relevance-segment.rsg-lp {
					--color: #8c4099;

					color: var(--color);
					border: 3px double var(--color);
					border-radius: var(--border-radius);
				}

				.relevance-precondition > .relevance-segment.rsg-nf {
					--color: rgb(243, 62, 43);

					color: var(--color);
					border: 1px solid var(--color);
					border-radius: var(--border-radius);
				}
				"""
			)
		}

		_pageCSS.append(
			"""
			@media print {
				div.tools {
					display: none;
				}
				div.survey-question {
					break-inside: avoid;
				}
			}
			"""
		)

		// Final page CSS.
		let pageCSS = _pageCSS.joined(separator: "\n/* =============== =============== */\n")

		//--------------------------------------------------

		let pageHTML: Node = nodeContainer {
			Node.documentType("html")
			html(lang: "en-UK") {
				head {
					meta(charset: "utf-8")
					meta(charset: "utf-8", content: "text/html", httpEquiv: "Content-Type")
					meta(content: "en-UK", httpEquiv: "content-language")

					title { FixedText.webAppNamePublic + " / Converted Document" }


					style {
						pageCSS
					}


					script {
						"""
						window.onload = function () {

							function select_survey_language_func() {

								var selectedValue = this.value;

								var allTranslations = ".survey-translation";
								var specificTranslation = allTranslations + ".survey-lang-" + selectedValue;

								if(selectedValue == "-show-all-") {
									document.querySelectorAll(allTranslations).forEach(function(el) {
										el.style.display = 'block';
									});
								} else {
									document.querySelectorAll(allTranslations).forEach(function(el) {
										el.style.display = 'none';
									});
									document.querySelectorAll(specificTranslation).forEach(function(el) {
										el.style.display = 'block';
									});
								}

								return;
							}

							var selectEl = document.getElementById("select_survey_language");
							if (typeof(selectEl) != 'undefined' && selectEl != null) {
								selectEl.addEventListener('change', select_survey_language_func);
							}

						"""
						+

						(!Settings.SurveyLocalizedData.onlyCommonLanguagesForLabelCluster ?
						"""

							function select_survey_language_sheet1_label_func() {

								var selectedValue = this.value;

								var allTranslations = ".survey-translation.\(SurveyTranslationHTMLClass.groupsAndQuestions.className)";
								var specificTranslation = allTranslations + ".survey-lang-" + selectedValue;

								if(selectedValue == "-show-all-") {
									document.querySelectorAll(allTranslations).forEach(function(el) {
										el.style.display = 'block';
									});
								} else {
									document.querySelectorAll(allTranslations).forEach(function(el) {
										el.style.display = 'none';
									});
									document.querySelectorAll(specificTranslation).forEach(function(el) {
										el.style.display = 'block';
									});
								}

								return;
							}

							var selectEl = document.getElementById("select_survey_language_sheet1_label");
							if (typeof(selectEl) != 'undefined' && selectEl != null) {
								selectEl.addEventListener('change', select_survey_language_sheet1_label_func);
							}


							function select_survey_language_sheet2_label_func() {

								var selectedValue = this.value;

								var allTranslations = ".survey-translation.\(SurveyTranslationHTMLClass.selectionAnswers.className)";
								var specificTranslation = allTranslations + ".survey-lang-" + selectedValue;

								if(selectedValue == "-show-all-") {
									document.querySelectorAll(allTranslations).forEach(function(el) {
										el.style.display = 'block';
									});
								} else {
									document.querySelectorAll(allTranslations).forEach(function(el) {
										el.style.display = 'none';
									});
									document.querySelectorAll(specificTranslation).forEach(function(el) {
										el.style.display = 'block';
									});
								}

								return;
							}

							var selectEl = document.getElementById("select_survey_language_sheet2_label");
							if (typeof(selectEl) != 'undefined' && selectEl != null) {
								selectEl.addEventListener('change', select_survey_language_sheet2_label_func);
							}

						"""
						: "")

						+
						"""
						}
						"""
					}
					//--------------------------------------------------

				} // end head
				body {

					//--------------------------------------------------
					div(style: "margin: 35px auto;width: 800px;padding: 2px;") {
						div(class: "tools") {
							a(href: "/") {
								input(class: "tool-button", id: "", name: "", style: "", title: "", type: "button", value: "⬅️ Back")
							}
							(1...3).map { _ in "&nbsp;" }
							input(class: "tool-button", id: "", name: "", style: "", title: "", type: "button", value: "Print 🖨", customAttributes: ["onclick": "window.print(); return false;"])

							if survey.languagesInCommonForLabelCluster.count > 1 && Settings.SurveyLocalizedData.onlyCommonLanguagesForLabelCluster {

								div(style: "margin-top: 20px;") {
									span { "Select survey's language:" }
									select(class: "tool-select", id: "select_survey_language") {
										if survey.languages.count > 1 {
											option(selected: false, value: "-show-all-") {
												"Show all"
											}
										}
										survey.languagesInCommonForLabelCluster.map { (language: Survey.DatumLanguage) -> Node in
											let isDefault = language.languageLabel == survey.defaultLanguage.languageLabel

											return option(selected: isDefault, value: language.languageStringID) {
												(isDefault ? "Default - " : "") + language.languageLabel
											}
										}
									}
								}

							}
							if survey.languages.count > 1 && !Settings.SurveyLocalizedData.onlyCommonLanguagesForLabelCluster {
								if survey.languages == survey.languagesInGroupsAndQuestionsForLabelCluster
									&& survey.languages == survey.languagesInSelectionAnswersForLabelCluster {

									div(style: "margin-top: 20px;") {
										span { "Choose survey's language:" }
										select(class: "tool-select", id: "select_survey_language") {
											if survey.languages.count > 1 {
												option(selected: false, value: "-show-all-") {
													"Show all"
												}
											}
											survey.languages.map { (language: Survey.DatumLanguage) -> Node in
												let isDefault = language.languageLabel == survey.defaultLanguage.languageLabel

												return option(selected: isDefault, value: language.languageStringID) {
													(isDefault ? "Default - " : "") + language.languageLabel
												}
											}
										}
									}

								} else {

									div(style: "margin-top: 20px;") {
										span(style: "display: block;text-decoration: underline;") { "Choose survey's language" }
										span { "&nbsp;" }

										span { "Groups & questions" }
										select(class: "tool-select", id: "select_survey_language_sheet1_label") {
											if survey.languagesInGroupsAndQuestionsForLabelCluster.count > 1 {
												option(selected: false, value: "-show-all-") {
													"Show all"
												}
											}
											survey.languagesInGroupsAndQuestionsForLabelCluster.map { (language: Survey.DatumLanguage) -> Node in
												let isDefault = language.languageLabel == survey.defaultLanguage.languageLabel

												return option(selected: isDefault, value: language.languageStringID) {
													(isDefault ? "Default - " : "") + language.languageLabel
												}
											}
										}

										br()

										span { "Questions' answers" }
										select(class: "tool-select", id: "select_survey_language_sheet2_label") {
											if survey.languagesInSelectionAnswersForLabelCluster.count > 1 {
												option(selected: false, value: "-show-all-") {
													"Show all"
												}
											}
											survey.languagesInSelectionAnswersForLabelCluster.map { (language: Survey.DatumLanguage) -> Node in
												let isDefault = language.languageLabel == survey.defaultLanguage.languageLabel

												return option(selected: isDefault, value: language.languageStringID) {
													(isDefault ? "Default - " : "") + language.languageLabel
												}
											}
										}
									}

								} // end if
							} // end if
						}
						div(style: "text-align: center;") {
							h3(style: "margin: 0 auto;text-decoration: underline;") { "Survey" }
							h1(style: "margin: 3px auto 5px;") {
								survey.title
							}

							if resultsLayoutDisplayOptions.displaySurveySettingsAndInfo {
								div(class: "survey-info-con") {
									table(class: "survey-info") {
										tbody {
											tr {
												td { "Version" }
												td { survey.version }
											}
											tr {
												td { "Form ID" }
												td { survey.formID }
											}
											tr {
												td { "Style" }
												td { survey.style }
											}
											tr {
												td { "Default Language" }
												td { survey.defaultLanguage.languageLabel }
											}
											if Settings.SurveyLocalizedData.onlyCommonLanguagesForLabelCluster && survey.languagesInCommonForLabelCluster.count > 1 || !Settings.SurveyLocalizedData.onlyCommonLanguagesForLabelCluster && survey.languages.count > 1 {
												tr {
													td { "Available Languages" }
													td {
														if Settings.SurveyLocalizedData.onlyCommonLanguagesForLabelCluster {
															survey.languagesInCommonForLabelCluster
																.map { (language: Survey.DatumLanguage) in language.languageLabel }
																.joined(separator: ", ")
																+ "."
														} else {
															survey.languages
																.map { (language: Survey.DatumLanguage) in language.languageLabel }
																.joined(separator: ", ")
																+ "."
														}
													}
												}
											} // end if
										} // end tbody
									} // end table
								}
							} // end if
						}

						survey.items.map { (surveyItem) -> Node in
							helper(surveyItem: surveyItem)
						}
					}
					//--------------------------------------------------

				} // end body
			} // end html
		}

		return pageHTML
	}

	func htmlResponse() -> Response {

		let httpBody: String = self.pageHTML().renderAsString()
		let httpContentType: String = "text/html"

		return .init(
			status: .ok,
			headers: .init([("Content-Type", httpContentType)]),
			body: Response.Body(string: httpBody)
		)
	}

}
