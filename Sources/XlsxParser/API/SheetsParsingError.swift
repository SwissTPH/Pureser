//
//  File.swift
//  
//
//  Created by R. Makhoul on 02/03/2021.
//

import Foundation


//
//
//
public enum SheetsParsingError: Error, CustomStringConvertible {

	case surveyWorksheetNotFound
	case choicesWorksheetNotFound
	case settingsWorksheetNotFound
	case multipleWorksheetNotFound([Self])

	case surveyWorksheetIsEmpty
	case choicesWorksheetIsEmpty
	case settingsWorksheetIsEmpty

	case surveyWorksheetHeaderRowNotFound
	case choicesWorksheetHeaderRowNotFound
	case settingsWorksheetHeaderRowNotFound

	case surveyWorksheetContentRowsNotFound
	case choicesWorksheetContentRowsNotFound
	case settingsWorksheetContentRowsNotFound

	case actualSettingsNotFound

	case columnNotFound(title: String, inWorksheet: String)
	case columnByTitleOrSynonymsNotFound(titleAnyOf: [String], inWorksheet: String)
	case columnsNotFound(titleContaining: String, inWorksheet: String)


	//--------------------------------------------------

	private var _description: String {
		switch self {

		case .surveyWorksheetNotFound:
			return #"The "survey" worksheet is missing."#
		case .choicesWorksheetNotFound:
			return #"The "choices" worksheet is missing."#
		case .settingsWorksheetNotFound:
			return #"The "settings" worksheet is missing."#
		case .multipleWorksheetNotFound(let array):
			let x = array
				.compactMap { x in
					let o: String?
					switch x {
					case .surveyWorksheetNotFound:
						o = "survey"
					case .choicesWorksheetNotFound:
						o = "choices"
					case .settingsWorksheetNotFound:
						o = "settings"
					default:
						o = nil
					}
					return o.flatMap { (x: String) in
						"\"\(x)\""
					}
				}
				.joined(separator: ", ")
			return "Multiple worksheets are missing: " + x + "."
				+ #" The "survey" sheet is requird, the "choices" and "settings" sheets are optional."#

		case .surveyWorksheetIsEmpty:
			return #"The "survey" worksheet is blank."#
		case .choicesWorksheetIsEmpty:
			return #"The "choices" worksheet is blank."#
		case .settingsWorksheetIsEmpty:
			return #"The "settings" worksheet is blank."#

		case .surveyWorksheetHeaderRowNotFound:
			return #"The "survey" worksheet's header row is missing."#
		case .choicesWorksheetHeaderRowNotFound:
			return #"The "choices" worksheet's header row is missing."#
		case .settingsWorksheetHeaderRowNotFound:
			return #"The "settings" worksheet's header row is missing."#

		case .surveyWorksheetContentRowsNotFound:
			return #"The "survey" worksheet's content rows are missing."#
		case .choicesWorksheetContentRowsNotFound:
			return #"The "choices" worksheet's content rows are missing."#
		case .settingsWorksheetContentRowsNotFound:
			return #"The "settings" worksheet's content rows are missing."#

		case .actualSettingsNotFound:
			return #"The "settings" worksheet's actual settings row is not found."#

		case .columnNotFound(title: let title, inWorksheet: let inWorksheet):
			return #"Can not find column in worksheet "\#(inWorksheet)" with header title "\#(title)"."#
		case .columnByTitleOrSynonymsNotFound(titleAnyOf: let titleAnyOf, inWorksheet: let inWorksheet):
			let first = titleAnyOf.first!
			let rest = titleAnyOf.dropFirst()
			let restString = rest.compactMap { "\"\($0)\"" }.joined(separator: ", ")
			return #"Can not find column in worksheet "\#(inWorksheet)" with header title "\#(first)""#
				+ (!titleAnyOf.isEmpty ? #" or with one of its synonyms (\#(restString))"# : "")
				+ #"."#
		case .columnsNotFound(titleContaining: let titleContaining, inWorksheet: let inWorksheet):
			return #"Can not find column or columns in worksheet "\#(inWorksheet)" with header title either being "\#(titleContaining)" or starting with "\#(titleContaining)::"."#

		}
	}

	private var _localizedDescription: String {
		self._description
	}

	public var localizedDescription: String {
		NSLocalizedString(self._localizedDescription, comment: "")
	}

	//--------------------------------------------------

	public var description: String {
		self.localizedDescription
	}

}
