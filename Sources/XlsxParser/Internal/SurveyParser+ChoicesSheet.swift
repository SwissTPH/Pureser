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

public struct ChoicesSheet {

	struct ColumnsPossibleTitles {
		static var listName = ["list_name", "list name"]
		//static var name = ["name"]
		//static var labelCluster = ["label"]
	}

	public struct Row: Codable {
		var listName: String?
		var name: String?
		var labelCluster: Survey.LocalizedData?

		enum CodingKeys: String, CodingKey {
			case listName = "list_name"
			case name = "name"
			case labelCluster = "label"
		}

		internal init(
			listName: String? = nil,
			name: String? = nil,
			labelCluster: Survey.LocalizedData? = nil
		) {
			self.listName = listName
			self.name = name
			self.labelCluster = labelCluster
		}

		internal var isVacant: Bool {
			return listName?.isEmpty ?? true
				&& name?.isEmpty ?? true
				&& labelCluster?.isVacant ?? true
		}

		internal var nilIfVacant: Self? {
			return self.isVacant ? nil : self
		}
	}

	public struct ColumnReferences {
		var listName: CoreXLSX.ColumnReference
		var name: CoreXLSX.ColumnReference
		var labelCluster: ColumnClusterReference
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
			throw SheetsParser.ParsingError.choicesWorksheetIsEmpty
		}

		// Assign header row.
		// Note: the guard-let statment here is only for affirmation,
		// normally it should never produced (throw) an error,
		// because it was already checked that the array is not empty.
		guard let headerRow: CoreXLSX.Row = filteredRows.first else {
			throw SheetsParser.ParsingError.choicesWorksheetHeaderRowNotFound
		}

		// Assign contect row.
		// Here are all rows except the header row.
		let contentRows: [CoreXLSX.Row] = Array(filteredRows.dropFirst())

		// Make sure that there are rows present after dropping header row.
		if contentRows.isEmpty {
			throw SheetsParser.ParsingError.choicesWorksheetContentRowsNotFound
		}

		// Assign getter.
		let getter = Getter(sharedStrings: sharedStrings, headerRow: headerRow, inWorksheet: .choices)

		//
		let columnReferences = ColumnReferences(

			listName: try getter.findColumnReference(titleAnyOf: ColumnsPossibleTitles.listName),

			name: try getter.findColumnReference(Row.CodingKeys.name.rawValue),

			labelCluster: try getter.findColumnReferences(titleContaining: Row.CodingKeys.labelCluster.rawValue)
		)

		//
		let processedContentRows: [Row] = contentRows.map {
			(row: CoreXLSX.Row) -> Row in
			Row(
				listName: getter.findTrimmedPlainString(in: row, by: columnReferences.listName),
				name: getter.findTrimmedPlainString(in: row, by: columnReferences.name),
				labelCluster: getter.findTrimmedPlainString(in: row, by: columnReferences.labelCluster)
			)
		}

		self.headerRow = headerRow
		self.contentRows = contentRows
		self.columnReferences = columnReferences

		self.processedContentRows = processedContentRows
	}

}

//--------------------------------------------------
