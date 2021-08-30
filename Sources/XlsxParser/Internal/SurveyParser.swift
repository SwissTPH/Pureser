//
//  File.swift
//  
//
//  Created by R. Makhoul on 27/10/2020.
//

import Foundation
import PrintMore
//import HTML
import SurveyTypes

//--------------------------------------------------

//
public struct SurveyParser {

	//
	private static let debug: Bool = false // Settings.debug

	//
	public static func parseIntoSurvey(using sheets: SheetsParser) throws -> Survey {

		let sheets = sheets

		//--------------------------------------------------

		if Self.debug {
			printmore(.info, "surveyLanguages:",
					  String(describing: sheets.languagesAvailable.all))

			printmore(.info, "surveyLanguages.InCommon.ForLabelCluster:",
					  String(describing: sheets.languagesAvailable.forLabelCluster.inCommon))

			printmore(.info, "surveyLanguages.InGroupsAndQuestions.ForLabelCluster:",
					  String(describing: sheets.languagesAvailable.forLabelCluster.inGroupsAndQuestions))

			printmore(.info, "surveyLanguages.InSelectionAnswers.ForLabelCluster:",
					  String(describing: sheets.languagesAvailable.forLabelCluster.inSelectionAnswers))
		}

		//--------------------------------------------------

		var survey: Survey

		// All survey items.
		var surveyItems: [SurveyItem] = []

		// The survey groups cascade, last one appended is current.
		var surveyGroups: [SurveyGroup] = []

		// All parsing warnings.
		var generalWarnings: [SurveyWarning] = []
		var specificWarnings: [SurveyWarning] = []

		//
		func appendWarning(warning: SurveyWarning) {
			generalWarnings.append(warning)
		}

		// For every row (except first which should be already dropped) in the sheet's rows, do:
		// Also, all string values have already been `whitespacesAndNewlines`-trimmed.
		for surveySheetRow: SurveySheet.Row in sheets.survey.processedContentRows {

			// Skip completely empty rows. Although there should not be any.
			if surveySheetRow.isVacant {
				continue
			}

			// Skip rows where the `type`-titled cell is nil or empty.
			guard let typeFull = surveySheetRow.type, !typeFull.isEmpty else {
				continue
			}

			//--------------------------------------------------

			// Parsing warnings of the current item.
			var currentItemWarnings: [SurveyWarning] = []

			// Add the current items warnings to the form's warnings array
			// before execution leaves the current block of code.
			defer {
				specificWarnings += currentItemWarnings
			}

			//
			enum WarningList {
				case generalWarnings
				case specificWarnings
			}

			//
			func appendWarning(to: WarningList, warning: SurveyWarning) {
				if to == .generalWarnings {
					generalWarnings.append(warning)
				}
				if to == .specificWarnings {
					currentItemWarnings.append(warning)
				}
			}

			//--------------------------------------------------

			// Find type and typeOptions.
			let typeAndOptions: FormQuestionTypeAndOptions
			if let _typeAndOptions: FormQuestionTypeAndOptions = FormQuestionTypeAndOptions(fromString: typeFull) {
				typeAndOptions = _typeAndOptions
			} else {
				appendWarning(to: .specificWarnings, warning: SurveyWarning(
					warningKind: SurveyWarningKind.invalidQuestionTypeOptions(
						in: surveySheetRow.name ?? "",
						type: typeFull),
					row: surveySheetRow._reference,
					formItemID: surveySheetRow.name,
					formItemType: surveySheetRow.type
				))

				typeAndOptions =
					.init(type: .unknown, options: .init(unknownType: typeFull))
			}
			let type = typeAndOptions.type
			let typeOptions: FormQuestionTypeOptions? = typeAndOptions.options

			// Find out the current survey item's orginal label.
			/// The current survey item's original label, which consists of an array of translations.
			///
			/// Note: a survey item can be either a group or a question.
			let surveyItemLabelFull: Survey.LocalizedData = surveySheetRow.labelCluster ?? []

			// Find out the current survey item's label.
			/// The current survey item's label, which consists of an array of translations.
			///
			/// Note: a survey item can be either a group or a question.
			let surveyItemLabel: Survey.LocalizedData = surveySheetRow.labelCluster ?? []

			//--------------------------------------------------

			//
			let surveyItemRelevanceUnprocessed: String? = surveySheetRow.relevant

			//--------------------------------------------------

			//
			let surveyItemAgeGroupUnprocessed: String? = surveySheetRow.ageGroup
			//
			let surveyItemAgeGroup: QuestionAgeGroup?
			//
			if let surveyItemAgeGroupUnprocessed = surveyItemAgeGroupUnprocessed, !surveyItemAgeGroupUnprocessed.isEmpty {
				if let _surveyItemAgeGroup: QuestionAgeGroup = QuestionAgeGroup(surveyItemAgeGroupUnprocessed) {
					surveyItemAgeGroup = _surveyItemAgeGroup
				} else {
					appendWarning(to: .specificWarnings, warning: SurveyWarning(
						warningKind: SurveyWarningKind.invalidQuestionAgeGroup(
							in: surveySheetRow.name ?? "",
							agegroup: surveyItemAgeGroupUnprocessed),
						row: surveySheetRow._reference,
						formItemID: surveySheetRow.name,
						formItemType: surveySheetRow.type
					))

					surveyItemAgeGroup = nil
				}
			} else {
				surveyItemAgeGroup = nil
			}

			//--------------------------------------------------

			// MARK: - if begin group
			//
			if [.begin_group, .begin_repeat].contains(type) {

				//
				let groupType: SurveyGroupType = type == .begin_repeat ? .repeatTable : .basic

				//
				var surveyGroupName = surveySheetRow.name

				//
				var surveyGroupLabel = surveyItemLabel

				// If group's label is empty
				surveyGroupLabel = surveyGroupLabel.map { localizedDatum in
					var localizedDatum = localizedDatum
					if localizedDatum.translation == nil || (localizedDatum.translation ?? "").isEmpty {
						localizedDatum.translation = nil
					}
					return localizedDatum
				}

				//
				let surveyGroup = SurveyGroup(
					groupType: groupType,

					name: surveyGroupName,
					label: surveyGroupLabel,

					relevanceUnprocessed: surveyItemRelevanceUnprocessed,

					ageGroup: surveyItemAgeGroup,

					items: []
				)
				surveyGroups.append(surveyGroup)
			}
			// MARK: - if end group
			//
			else if [.end_group, .end_repeat].contains(type) {

				// If there is an "end group" without a "begin group".
				if surveyGroups.isEmpty {
					printmore(.warning, "A group ended without a group starting.")
					appendWarning(to: .generalWarnings, warning: SurveyWarning(
						warningKind: SurveyWarningKind.aGroupEndedWithoutStarting,
						row: surveySheetRow._reference
					))
				} else {
					// Reset the groups by removing the ended group from the array. And assing the
					// returned last element (the ended group) into `endedGroup` constant.
					// .popLast() returns nil if the collection is empty.
					// .removeLast() crashes if the collection is empty. It also has a discardable result.
					let endedGroup = surveyGroups.removeLast()

					// Add the ended group to either (1) survey's items array, or (2) parent-group's items array.
					if surveyGroups.isEmpty {
						surveyItems.append(SurveyItem.group(endedGroup))
					} else {
						surveyGroups[surveyGroups.endIndex-1].items.append(SurveyItem.group(endedGroup))
					}
				}

			}
			// MARK: - else
			//
			else {

				//
				var answers: [SurveySelectionQuestionAnswer] = []

				// If it's a question which type needs answers/choices.
				if [.select_one, .select_multiple, .rank].contains(type) {
					if let choicesSheet: ChoicesSheet = sheets.choices {

						// Find out the selection question's answers.
						answers =
							choicesSheet.processedContentRows
							.filter { (choicesSheetRow: ChoicesSheet.Row) in
								typeOptions?.listName == choicesSheetRow.listName
							}
							.map { (choicesSheetRow: ChoicesSheet.Row) in
								//
								let answerID = choicesSheetRow.name ?? ""

								//
								let translations: Survey.LocalizedData = choicesSheetRow.labelCluster ?? []

								//
								let answerLabel = translations

								//
								return SurveySelectionQuestionAnswer(
									answerID: answerID,
									answerLabel: answerLabel,
									choiceFilters: choicesSheetRow.choiceFilters
								)
							}

						if answers.isEmpty {
							appendWarning(to: .specificWarnings, warning: SurveyWarning(
								warningKind: SurveyWarningKind.referenceToChoicesSheetListButListNotFound(
									inQuestion: surveySheetRow.name ?? "",
									questionType: surveySheetRow.type ?? "",
									listName: typeOptions?.listName ?? ""),
								row: surveySheetRow._reference
							))
						}
					} else {
						appendWarning(to: .specificWarnings, warning: SurveyWarning(
							warningKind: SurveyWarningKind.referenceToChoicesSheetButChoicesWorksheetNotFound(
								inQuestion: surveySheetRow.name ?? "",
								questionType: surveySheetRow.type ?? ""),
							row: surveySheetRow._reference
						))
					}
				}

				//--------------------------------------------------

				//
				let surveyQuestionName = surveySheetRow.name ?? ""

				//
				let surveyQuestionLabelFull = surveyItemLabelFull

				//
				var surveyQuestionLabel = surveyItemLabel

				//
				if true {
					surveyQuestionLabel = surveyQuestionLabel.map { localizedDatum in
						var localizedDatum = localizedDatum

						localizedDatum.translation = localizedDatum.translation?
							.replacingOccurrences(of: "\n", with: "<br />")

						return localizedDatum
					}
				}

				//
				if false {
					surveyQuestionLabel = helperExtractQuestionLabel(surveyQuestionLabel)
				}

				//
				let surveyQuestionHint: Survey.LocalizedData = surveySheetRow.hintCluster ?? []

				//--------------------------------------------------

				let surveyQuestion = SurveyQuestion(
					typeAndOptions: typeAndOptions,
					typeFull: typeFull,

					answers: answers,

					name: surveyQuestionName,

					label: surveyQuestionLabel,
					labelFull: surveyQuestionLabelFull,

					hint: surveyQuestionHint,

					relevanceUnprocessed: surveyItemRelevanceUnprocessed,

					ageGroup: surveyItemAgeGroup,

					choiceFilterUnprocessed: surveySheetRow.choiceFilter,

					warnings: currentItemWarnings
				)

				// Add the current question to either (1) survey's items array, or (2) parent-group's items array.
				if surveyGroups.isEmpty {
					surveyItems.append(SurveyItem.question(surveyQuestion))
				} else {
					surveyGroups[surveyGroups.endIndex-1].items.append(SurveyItem.question(surveyQuestion))
				}
			}
			// MARK: end if -

		} // end for

		//--------------------------------------------------

		// This `while` loop takes care of a situation that the xlsx file ends and some question groups were not closed.
		while !surveyGroups.isEmpty {

			// If there is a "begin group" without an "end group".
			printmore(.warning, "A group started without a group ending.")
			appendWarning(warning: SurveyWarning(
				warningKind: SurveyWarningKind.aGroupStartedWithoutEnding,
				row: sheets.survey.processedContentRows.last?._reference
			))

			// Reset the groups by removing the ended group from the array. And assing the
			// returned last element (the ended group) into `endedGroup` constant.
			// .popLast() returns nil if the collection is empty.
			// .removeLast() crashes if the collection is empty. It also has a discardable result.
			let endedGroup = surveyGroups.removeLast()

			// Add the ended group to either (1) survey's items array, or (2) parent-group's items array.
			if surveyGroups.isEmpty {
				surveyItems.append(SurveyItem.group(endedGroup))
			} else {
				surveyGroups[surveyGroups.endIndex-1].items.append(SurveyItem.group(endedGroup))
			}
		}

		//--------------------------------------------------

		// Prepare all survey items once for the relevnace processing.
		let allSurveyItems: [SurveyItem] = surveyItems + surveyGroups.map { g in SurveyItem.group(g) }

		//
		func relev(surveyItem: SurveyItem) throws -> SurveyItem {
			switch surveyItem {
			case .question(var question):
				if let unprocessedRelevance = question.relevanceUnprocessed, !unprocessedRelevance.isEmpty {
					let t = try RelevanceParser.relevanceHelper(
						unprocessedRelevance: unprocessedRelevance,
						referenceSurveyItems: allSurveyItems,
						datumLanguages: sheets.languagesAvailable.forLabelCluster.inCommon
					)

					question.relevanceStepByStep = t.stepByStep
					question.relevance = t.final
				}

				return .question(question)
			case .group(var group):
				if let unprocessedRelevance = group.relevanceUnprocessed, !unprocessedRelevance.isEmpty {
					let t = try RelevanceParser.relevanceHelper(
						unprocessedRelevance: unprocessedRelevance,
						referenceSurveyItems: allSurveyItems,
						datumLanguages: sheets.languagesAvailable.forLabelCluster.inCommon
					)

					group.relevanceStepByStep = t.stepByStep
					group.relevance = t.final
				}

				// Crucial! This here is so relevance of all nested items will also
				// have their relevance processed.
				group.items = try group.items.map(relev(surveyItem:))

				return .group(group)
			}
		}

		// Process the relevance field.
		surveyItems = try surveyItems.map(relev(surveyItem:))

		//--------------------------------------------------

		// Original default language of form.
		// It is `nil` if not present a default language in the settings sheet.
		// If present, find it in the languages array.
		let defaultLanguage: Survey.DatumLanguage? =
			sheets.actualSettings?.defaultLanguage.flatMap { defaultLanguage in
				sheets.languagesAvailable.all.first { language in
					language.languageLabel == defaultLanguage
				}
			}

		let style: Survey.Style? =
			sheets.actualSettings?.style.flatMap { Survey.Style(rawValue: $0) }

		survey = Survey(
			formTitle: sheets.actualSettings?.formTitle,
			formID: sheets.actualSettings?.formID,
			version: sheets.actualSettings?.version,
			defaultLanguage: defaultLanguage,
			style: style,
			instanceName: sheets.actualSettings?.instanceName,
			publicKey: sheets.actualSettings?.publicKey,
			submissionURL: sheets.actualSettings?.submissionURL,

			languagesAvailable: sheets.languagesAvailable,

			items: surveyItems,

			warnings: .init(
				generalWarnings: !generalWarnings.isEmpty ? generalWarnings : nil,
				specificWarnings: !specificWarnings.isEmpty ? specificWarnings : nil
			)
		)

		return survey
	}

	/// Returns the data after distilling the question label from actual string obtained from excel file.
	///
	///
	static private func helperExtractQuestionLabel(_ surveyQuestionLabel: Survey.LocalizedData) -> Survey.LocalizedData {
		surveyQuestionLabel.map { localizedDatum in
			var localizedDatum = localizedDatum

			guard var surveyQuestionLabel = localizedDatum.translation else {
				return localizedDatum
			}

			// Search and retrieving matches that match the regex, and extract the string.
			let regex = #"^\s*(?:\([^\(\)]*\))?\s*[\[\s]*+(.*?)[\s\]]*+\s*$"#
			let allMatches = surveyQuestionLabel.matchingStrings(regex: regex)
			//print(allMatches)
			if !allMatches.isEmpty && allMatches[0].count > 1 {
				surveyQuestionLabel = allMatches[0][1]
			} else {
				surveyQuestionLabel = ""
			}

			localizedDatum.translation = surveyQuestionLabel

			return localizedDatum
		}
	}

	///
	///
	///
}

//--------------------------------------------------
