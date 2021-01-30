//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation
import CoreXLSX

//--------------------------------------------------

public struct SurveySheet {

	struct ColumnsPossibleTitles {
		//static var type = "type"
		//static var name = "name"
		//static var labelCluster = "label"
		//static var hintCluster = "hint"
		//static var relevant = "relevant"
		//static var required = "required"
		//static var notes = "notes"
		//static var appearance = "appearance"
		//static var calculation = "calculation"
		//static var `default` = "default"
		//static var constraint = "constraint"
		//static var constraintMessageCluster = "constraint_message"
		//static var readOnly = "read_only"
	}

	public struct Row: Codable {
		var type: String?
		var name: String?
		var labelCluster: Survey.LocalizedData?
		var hintCluster: Survey.LocalizedData?
		var relevant: String?
		var required: String?
		var notes: String?
		var appearance: String?
		var calculation: String?
		var `default`: String?
		var constraint: String?
		var constraintMessageCluster: Survey.LocalizedData?
		var readOnly: String?

		enum CodingKeys: String, CodingKey {
			case type = "type"
			case name = "name"
			case labelCluster = "label"
			case hintCluster = "hint"
			case relevant = "relevant"
			case required = "required"
			case notes = "notes"
			case appearance = "appearance"
			case calculation = "calculation"
			case `default` = "default"
			case constraint = "constraint"
			case constraintMessageCluster = "constraint_message"
			case readOnly = "read_only"
		}

		internal init(
			type: String? = nil,
			name: String? = nil,
			labelCluster: Survey.LocalizedData? = nil,
			hintCluster: Survey.LocalizedData? = nil,
			relevant: String? = nil,
			required: String? = nil,
			notes: String? = nil,
			appearance: String? = nil,
			calculation: String? = nil,
			default: String? = nil,
			constraint: String? = nil,
			constraintMessageCluster: Survey.LocalizedData? = nil,
			readOnly: String? = nil
		) {
			self.type = type
			self.name = name
			self.labelCluster = labelCluster
			self.hintCluster = hintCluster
			self.relevant = relevant
			self.required = required
			self.notes = notes
			self.appearance = appearance
			self.calculation = calculation
			self.default = `default`
			self.constraint = constraint
			self.constraintMessageCluster = constraintMessageCluster
			self.readOnly = readOnly
		}

		internal var isVacant: Bool {
			return type?.isEmpty ?? true
				&& name?.isEmpty ?? true
				&& labelCluster?.isVacant ?? true
				&& hintCluster?.isVacant ?? true
				&& relevant?.isEmpty ?? true
				&& required?.isEmpty ?? true
				&& notes?.isEmpty ?? true
				&& appearance?.isEmpty ?? true
				&& calculation?.isEmpty ?? true
				&& `default`?.isEmpty ?? true
				&& constraint?.isEmpty ?? true
				&& constraintMessageCluster?.isVacant ?? true
				&& readOnly?.isEmpty ?? true
		}

		internal var nilIfVacant: Self? {
			return self.isVacant ? nil : self
		}
	}

	public struct ColumnReferences {
		var type: CoreXLSX.ColumnReference?
		var name: CoreXLSX.ColumnReference?
		var labelCluster: ColumnClusterReference?
		var hintCluster: ColumnClusterReference?
		var relevant: CoreXLSX.ColumnReference?
		var required: CoreXLSX.ColumnReference?
		var notes: CoreXLSX.ColumnReference?
		var appearance: CoreXLSX.ColumnReference?
		var calculation: CoreXLSX.ColumnReference?
		var `default`: CoreXLSX.ColumnReference?
		var constraint: CoreXLSX.ColumnReference?
		var constraintMessageCluster: ColumnClusterReference?
		var readOnly: CoreXLSX.ColumnReference?
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
			throw SheetsParser.ParsingError.surveyWorksheetIsEmpty
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
			throw SheetsParser.ParsingError.surveyWorksheetContentRowsNotFound
		}

		// Assign getter.
		let getter = Getter(sharedStrings: sharedStrings, headerRow: headerRow, inWorksheet: .survey)

		//
		let columnReferences = ColumnReferences(

			type: try getter.findColumnReference(Row.CodingKeys.type.rawValue),

			name: try getter.findColumnReference(Row.CodingKeys.name.rawValue),

			labelCluster: try getter.findColumnReferences(titleContaining: Row.CodingKeys.labelCluster.rawValue),

			hintCluster: try getter.findColumnReferences(titleContaining: Row.CodingKeys.hintCluster.rawValue),

			relevant: try getter.findColumnReference(Row.CodingKeys.relevant.rawValue),

			required: try getter.findColumnReference(Row.CodingKeys.required.rawValue),

			notes: try? getter.findColumnReference(Row.CodingKeys.notes.rawValue),

			appearance: try getter.findColumnReference(Row.CodingKeys.appearance.rawValue),

			calculation: try? getter.findColumnReference(Row.CodingKeys.calculation.rawValue),

			default: try? getter.findColumnReference(Row.CodingKeys.default.rawValue),

			constraint: try getter.findColumnReference(Row.CodingKeys.constraint.rawValue),

			constraintMessageCluster: try? getter.findColumnReferences(titleContaining: Row.CodingKeys.constraintMessageCluster.rawValue),

			readOnly: try? getter.findColumnReference(Row.CodingKeys.readOnly.rawValue)
		)

		//
		let processedContentRows: [Row] = contentRows.map {
			(row: CoreXLSX.Row) -> Row in
			Row(
				type: getter.findTrimmedPlainString(in: row, by: columnReferences.type),
				name: getter.findTrimmedPlainString(in: row, by: columnReferences.name),
				labelCluster: getter.findTrimmedPlainString(in: row, by: columnReferences.labelCluster),
				hintCluster: getter.findTrimmedPlainString(in: row, by: columnReferences.hintCluster),
				relevant: getter.findTrimmedPlainString(in: row, by: columnReferences.relevant),
				required: getter.findTrimmedPlainString(in: row, by: columnReferences.required),
				notes: getter.findTrimmedPlainString(in: row, by: columnReferences.notes),
				appearance: getter.findTrimmedPlainString(in: row, by: columnReferences.appearance),
				calculation: getter.findTrimmedPlainString(in: row, by: columnReferences.calculation),
				default: getter.findTrimmedPlainString(in: row, by: columnReferences.default),
				constraint: getter.findTrimmedPlainString(in: row, by: columnReferences.constraint),
				constraintMessageCluster: getter.findTrimmedPlainString(in: row, by: columnReferences.constraintMessageCluster),
				readOnly: getter.findTrimmedPlainString(in: row, by: columnReferences.readOnly)
			)
		}

		self.headerRow = headerRow
		self.contentRows = contentRows
		self.columnReferences = columnReferences

		self.processedContentRows = processedContentRows
	}

}

//--------------------------------------------------
