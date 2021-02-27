//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation
import CoreXLSX
import struct SurveyTypes.Survey

//--------------------------------------------------

public struct SettingsSheet {

	struct ColumnsPossibleTitles {
		//static var formTitle = ["form_title", "form title"]
		//static var formID = ["form_id", "form id"]
		//static var version = ["version"]
		//static var defaultLanguage = ["default_language", "default language"]
		//static var style = ["style"]
		//static var instanceName = ["instance_name", "instance name"]
		//static var publicKey = ["public_key", "public key"]
		//static var submissionURL = ["submission_url", ""submission url""]
	}

	public struct Row: Codable {
		var formTitle: String?
		var formID: String?
		var version: String?
		var defaultLanguage: String?
		var style: String?
		var instanceName: String?
		var publicKey: String?
		var submissionURL: String?

		enum CodingKeys: String, CodingKey {
			case formTitle = "form_title"
			case formID = "form_id"
			case version = "version"
			case defaultLanguage = "default_language"
			case style = "style"
			case instanceName = "instance_name"
			case publicKey = "public_key"
			case submissionURL = "submission_url"
		}

		internal init(
			formTitle: String? = nil,
			formID: String? = nil,
			version: String? = nil,
			defaultLanguage: String? = nil,
			style: String? = nil,
			instanceName: String? = nil,
			publicKey: String? = nil,
			submissionURL: String? = nil
		) {
			self.formTitle = formTitle
			self.formID = formID
			self.version = version
			self.defaultLanguage = defaultLanguage
			self.style = style
			self.instanceName = instanceName
			self.publicKey = publicKey
			self.submissionURL = submissionURL
		}

		internal var isVacant: Bool {
			return formTitle?.isEmpty ?? true
				&& formID?.isEmpty ?? true
				&& version?.isEmpty ?? true
				&& defaultLanguage?.isEmpty ?? true
				&& style?.isEmpty ?? true
				&& instanceName?.isEmpty ?? true
				&& publicKey?.isEmpty ?? true
				&& submissionURL?.isEmpty ?? true
		}

		internal var nilIfVacant: Self? {
			return self.isVacant ? nil : self
		}
	}

	public struct ColumnReferences {
		var formTitle: CoreXLSX.ColumnReference?
		var formID: CoreXLSX.ColumnReference?
		var version: CoreXLSX.ColumnReference?
		var defaultLanguage: CoreXLSX.ColumnReference?
		var style: CoreXLSX.ColumnReference?
		var instanceName: CoreXLSX.ColumnReference?
		var publicKey: CoreXLSX.ColumnReference?
		var submissionURL: CoreXLSX.ColumnReference?
	}

	/// Header row.
	private var headerRow: CoreXLSX.Row

	/// Content rows.
	/// All rows except the header row.
	private var contentRows: [CoreXLSX.Row]

	///
	public var columnReferences: ColumnReferences

	/// Sheet's rows.
	/// Note:
	/// (1) Rows' cells are **whitespacesAndNewlines-trimmed**.
	/// (2) **Only** **non-empty/non-vacant** rows.
	/// (3) **Header** row already dropped.
	///
	/// Rows' cells were **whitespacesAndNewlines-trimmed**, and
	/// then rows were filtered to only non-empty/non-vacant ones, and
	/// then the first row (i.e. header row, with column titles) was dropped.
	///
	public var processedContentRows: [Row]

	//
	init(worksheet: CoreXLSX.Worksheet, sharedStrings: CoreXLSX.SharedStrings?) throws {

		// Filter rows by keeping only rows that have at least one cell that is not empty.
		// Filter rows by excluding rows that all their cells are empty.
		let filteredRows: [CoreXLSX.Row] = worksheet.data?.rows.filter { (row: CoreXLSX.Row) in
			!row.isVacant(sharedStrings: sharedStrings)
		} ?? []

		// Make sure that there are rows present after filtering.
		if filteredRows.isEmpty {
			throw SheetsParser.ParsingError.settingsWorksheetIsEmpty
		}

		// Assign header row.
		// Note: the guard-let statment here is only for affirmation,
		// normally it should never produced (throw) an error,
		// because it was already checked that the array is not empty.
		guard let headerRow: CoreXLSX.Row = filteredRows.first else {
			throw SheetsParser.ParsingError.settingsWorksheetHeaderRowNotFound
		}

		// Assign contect row.
		// Here are all rows except the header row.
		let contentRows: [CoreXLSX.Row] = Array(filteredRows.dropFirst())

		// Make sure that there are rows present after dropping header row.
		if contentRows.isEmpty {
			throw SheetsParser.ParsingError.settingsWorksheetContentRowsNotFound
		}

		// Assign getter.
		let getter = Getter(sharedStrings: sharedStrings, headerRow: headerRow, inWorksheet: .settings)

		//
		let columnReferences = ColumnReferences(

			formTitle: try? getter.findColumnReference(Row.CodingKeys.formTitle.rawValue),

			formID: try? getter.findColumnReference(Row.CodingKeys.formID.rawValue),

			version: try? getter.findColumnReference(Row.CodingKeys.version.rawValue),

			defaultLanguage: try? getter.findColumnReference(Row.CodingKeys.defaultLanguage.rawValue),

			style: try? getter.findColumnReference(Row.CodingKeys.style.rawValue),

			instanceName: try? getter.findColumnReference(Row.CodingKeys.instanceName.rawValue),

			publicKey: try? getter.findColumnReference(Row.CodingKeys.publicKey.rawValue),

			submissionURL: try? getter.findColumnReference(Row.CodingKeys.submissionURL.rawValue)
		)

		//
		let processedContentRows: [Row] = contentRows.map {
			(row: CoreXLSX.Row) -> Row in
			Row(
				formTitle: getter.findTrimmedPlainString(in: row, by: columnReferences.formTitle),
				formID: getter.findTrimmedPlainString(in: row, by: columnReferences.formID),
				version: getter.findTrimmedPlainString(in: row, by: columnReferences.version),
				defaultLanguage: getter.findTrimmedPlainString(in: row, by: columnReferences.defaultLanguage),
				style: getter.findTrimmedPlainString(in: row, by: columnReferences.style),
				instanceName: getter.findTrimmedPlainString(in: row, by: columnReferences.instanceName),
				publicKey: getter.findTrimmedPlainString(in: row, by: columnReferences.publicKey),
				submissionURL: getter.findTrimmedPlainString(in: row, by: columnReferences.submissionURL)
			)
		}

		self.headerRow = headerRow
		self.contentRows = contentRows
		self.columnReferences = columnReferences

		self.processedContentRows = processedContentRows
	}

}

//--------------------------------------------------
