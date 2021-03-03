//
//  File.swift
//  
//
//  Created by R. Makhoul on 23/01/2021.
//

import Foundation
import PrintMore
import CoreXLSX
import struct SurveyTypes.Survey

//
//
//
public struct SheetsParser {

	public enum SheetsEnum: String, Codable {
		case survey
		case choices
		case settings
	}

	//
	typealias ParsingError = SheetsParsingError

	public var survey: SurveySheet
	public var choices: ChoicesSheet?
	public var settings: SettingsSheet?
	public var actualSettings: SettingsSheet.Row?
	public var languagesAvailable: Survey.LanguagesAvailable

	//
	public init(fileData: Data, filename: String? = nil) throws {

		if let filename = filename {
			printmore(.info, #"File to be read filename: "\#(filename)"."#)
		}

		let file = try CoreXLSX.XLSXFile(data: fileData)
		printmore(.success, "File was read successfully.")

		//--------------------------------------------------

		var _surveySheet: CoreXLSX.Worksheet? = nil
		var _choicesSheet: CoreXLSX.Worksheet? = nil
		var _settingsSheet: CoreXLSX.Worksheet? = nil

		for wbk in try file.parseWorkbooks() {
			for (name, path) in try file.parseWorksheetPathsAndNames(workbook: wbk) {
				guard let worksheetName = name else {
					continue
				}
				print("This worksheet has a name: \(worksheetName)")

				let worksheet = try file.parseWorksheet(at: path)

				if worksheetName.contains("survey") {
					_surveySheet = worksheet
				} else if worksheetName.contains("choices") {
					_choicesSheet = worksheet
				} else if worksheetName.contains("settings") {
					_settingsSheet = worksheet
				}
			}
		}

		//
		if _surveySheet == nil {
			guard let _ = _surveySheet, let _ = _choicesSheet, let _ = _settingsSheet else {
				var notFoundOnes: [ParsingError] = []

				if _surveySheet == nil { notFoundOnes.append(.surveyWorksheetNotFound) }
				if _choicesSheet == nil { notFoundOnes.append(.choicesWorksheetNotFound) }
				if _settingsSheet == nil { notFoundOnes.append(.settingsWorksheetNotFound) }

				// In case only one was not found.
				if notFoundOnes.count == 1, let theOnlyOne = notFoundOnes.first {
					throw theOnlyOne
				}
				// This `else` is the same as `if notFoundOnes.count > 1`
				// becuase the case of `count == 1` was covered already
				// and code execution would not have reached this point otherwise.
				else {
					throw ParsingError.multipleWorksheetNotFound(notFoundOnes)
				}
			}
		}
		//
		if _choicesSheet == nil {
			print(ParsingError.choicesWorksheetNotFound)
		}
		//
		if _settingsSheet == nil {
			print(ParsingError.settingsWorksheetNotFound)
		}

		let surveySheet: CoreXLSX.Worksheet = _surveySheet!
		let choicesSheet: CoreXLSX.Worksheet? = _choicesSheet
		let settingsSheet: CoreXLSX.Worksheet? = _settingsSheet

		//--------------------------------------------------

		let sharedStrings = try file.parseSharedStrings()

		//--------------------------------------------------

		let survey: SurveySheet = try SurveySheet(worksheet: surveySheet, sharedStrings: sharedStrings)

		let choices: ChoicesSheet? = try choicesSheet.flatMap { choicesSheet in
			try ChoicesSheet(worksheet: choicesSheet, sharedStrings: sharedStrings)
		}

		let settings: SettingsSheet? = try settingsSheet.flatMap { settingsSheet in
			try SettingsSheet(worksheet: settingsSheet, sharedStrings: sharedStrings)
		}
		let actualSettings: SettingsSheet.Row? = try settings.flatMap { settings in
			guard let actualSettings = settings.processedContentRows.first else {
				throw ParsingError.actualSettingsNotFound
			}
			return actualSettings
		}

		//--------------------------------------------------

		/// An array of **all languages available** in the survey.
		///
		/// Note: all of the survey (survey sheet, choices sheet, settings sheet), not just in the survey sheet.
		///
		/// Find out which languages are available in the survey.
		let allLanguages: [Survey.DatumLanguage] =
			[
				survey.columnReferences.labelCluster,
				survey.columnReferences.hintCluster,
				choices?.columnReferences.labelCluster,
			]
			.toUniquelyMergedClusterColumnMetadatas()
			.toSurveyDatumLanguageArray()

		/// An array of languages available in all of the `labelCluster`s of the survey.
		///
		/// Find out which languages are available for `label` in common in both sheets of
		/// "survey groups and questions" and "survey selection answers"
		/// in the survey.
		let onlyLanguagesInCommonForLabelCluster: [Survey.DatumLanguage] =
			allLanguages.filterUniquelyCommon(with: [
				survey.columnReferences.labelCluster,
				choices?.columnReferences.labelCluster,
			])

		/// An array of languages available in only the `labelCluster` of the survey's groups and questions.
		///
		/// Find out which languages are available for `label` in the survey groups and questions.
		let onlyLanguagesInGroupsAndQuestionsForLabelCluster: [Survey.DatumLanguage] =
			allLanguages.filterUniquelyCommon(with: [
				survey.columnReferences.labelCluster,
			])

		/// An array of languages available in only the `labelCluster` of the survey's selection answers.
		///
		/// Find out which languages are available for `label` in the survey selection answers.
		let onlyLanguagesInSelectionAnswersForLabelCluster: [Survey.DatumLanguage] =
			allLanguages.filterUniquelyCommon(with: [
				choices?.columnReferences.labelCluster,
			])

		//
		let languagesAvailable = Survey.LanguagesAvailable(
			all: allLanguages,
			forLabelCluster: .init(
				inCommon: onlyLanguagesInCommonForLabelCluster,
				inGroupsAndQuestions: onlyLanguagesInGroupsAndQuestionsForLabelCluster,
				inSelectionAnswers: onlyLanguagesInSelectionAnswersForLabelCluster
			)
		)

		//--------------------------------------------------

		self.survey = survey
		self.choices = choices
		self.settings = settings
		self.actualSettings = actualSettings
		self.languagesAvailable = languagesAvailable
	}

}
