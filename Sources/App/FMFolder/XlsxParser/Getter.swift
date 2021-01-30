//
//  File.swift
//  
//
//  Created by R. Makhoul on 26/01/2021.
//

import Foundation
import CoreXLSX

internal struct Getter {

	var sharedStrings: CoreXLSX.SharedStrings?
	var headerRow: CoreXLSX.Row

	// Used only in the message of thrown errors, if thrown.
	private var inWorksheet: String

	//
	internal init(
		sharedStrings: SharedStrings? = nil,
		headerRow: Row,
		inWorksheet: SheetsParser.SheetsEnum
	) {
		self.sharedStrings = sharedStrings
		self.headerRow = headerRow
		self.inWorksheet = inWorksheet.rawValue
	}


	// MARK: findColumnReference/s

	//
	internal func findColumnReference(titleAnyOf columnTitles: String...) throws -> CoreXLSX.ColumnReference {
		try findColumnReference(titleAnyOf: columnTitles)
	}

	//
	internal func findColumnReference(titleAnyOf columnTitles: [String]) throws -> CoreXLSX.ColumnReference {

		let columnTitles = columnTitles.map { title in
			title.trimmingCharacters(in: .whitespacesAndNewlines)
		}

		let columnReference = headerRow.cells.first { (cell: CoreXLSX.Cell) in
			cell.trimmedPlainString(sharedStrings: sharedStrings)
				.flatMap { columnTitles.contains($0) } ?? false
		}?.reference.column

		if let columnReference = columnReference {
			return columnReference
		} else {
			print("Error: 43/28-01.")
			throw SheetsParser.ParsingError.columnNotFound(titleAnyOf: columnTitles, inWorksheet: inWorksheet)
		}
	}

	//
	internal func findColumnReference(_ columnTitle: String) throws -> CoreXLSX.ColumnReference {

		let columnTitle = columnTitle
			.trimmingCharacters(in: .whitespacesAndNewlines)

		let columnReference = headerRow.cells.first { (cell: CoreXLSX.Cell) in
			cell.trimmedPlainString(sharedStrings: sharedStrings) == columnTitle
		}?.reference.column

		if let columnReference = columnReference {
			return columnReference
		} else {
			print("Error: 28/27-01.")
			throw SheetsParser.ParsingError.columnNotFound(title: columnTitle, inWorksheet: inWorksheet)
		}
	}

	//
	internal func findColumnReferences(titleContaining columnTitle: String) throws -> ColumnClusterReference {

		let columnTitle = columnTitle
			.replacingOccurrences(of: "::", with: "")
			.trimmingCharacters(in: .whitespacesAndNewlines)

		var clusterColumnsMetadata: [ClusterColumnMetadata] = headerRow.cells
			.compactMap { (cell: CoreXLSX.Cell) in
				// This acts a filter, as it increases performance
				// as opposed to using `.filter {...}` first and then this `.compactMap {...}`.
				guard cell.trimmedPlainString(sharedStrings: sharedStrings)?.contains(columnTitle) ?? false
				else { return nil }

				guard let columnTitleTail = cell
					.trimmedPlainString(sharedStrings: sharedStrings)?
					.replacingOccurrences(of: "\(columnTitle)::", with: "")
				else { return nil }

				let columnReference = cell.reference.column

				return ClusterColumnMetadata(titleTail: columnTitleTail, reference: columnReference)
			}

		if clusterColumnsMetadata.isEmpty {
			print("Error: 57/27-01.")
			throw SheetsParser.ParsingError.columnsNotFound(titleContaining: columnTitle, inWorksheet: inWorksheet)
		}

		//
		else if clusterColumnsMetadata.count == 1 &&
					clusterColumnsMetadata.first?.titleTailOnlyLetters.isEmpty ?? true {
			clusterColumnsMetadata[0].titleTail = "Only Language"
		}

		//
		else if clusterColumnsMetadata.count > 1 &&
					clusterColumnsMetadata.allSatisfy({ ccm in ccm.titleTailOnlyLetters.isEmpty }) {

			var count: Int = 0;
			clusterColumnsMetadata = clusterColumnsMetadata.map { ccm in
				var ccm = ccm
				count += 1
				// The `String(format: "%02d", Int)` pads the `Int` with leading zeros,
				// in this example it pads to 2 digits total, e.g. `5` becomes `05`.
				ccm.titleTail = "Language " + String(format: "%02d", count)
				return ccm
			}
		}

		//
		clusterColumnsMetadata = clusterColumnsMetadata.map { ccm in
			var ccm = ccm
			if !(ccm.titleTail.first?.isLetter ?? false) {
				ccm.titleTail = "L " + ccm.titleTail
			}
			return ccm
		}

		return ColumnClusterReference(clusterColumnsMetadata: clusterColumnsMetadata)
	}


	// MARK: findTrimmedPlainString

	//
	internal func findTrimmedPlainString(
		in row: CoreXLSX.Row,
		by columnReference: CoreXLSX.ColumnReference?
	) -> String? {
		row.cells.first { (cell: CoreXLSX.Cell) in
			cell.reference.column == columnReference
		}?.trimmedPlainString(sharedStrings: sharedStrings)
	}

	//
	internal func findTrimmedPlainString(
		in row: CoreXLSX.Row,
		by columnClusterReference: ColumnClusterReference?
	) -> [Survey.LocalizedDatum]? {
		columnClusterReference?.clusterColumnsMetadata.map { (clusterColumnMetadata: ClusterColumnMetadata) in
			Survey.LocalizedDatum(
				datumLanguage: .init(
					languageStringID: clusterColumnMetadata.titleTailOnlyLetters,
					languageLabel: clusterColumnMetadata.titleTail
				),
				translation:
					// The following will try to find the cell using the column reference,
					// in case no cell is found it will return nil.
					row.cells.first { (cell: CoreXLSX.Cell) in
						cell.reference.column == clusterColumnMetadata.reference
					}?
					// The following will either return a non-empty string (if available),
					// otherwise it will return nil.
					.trimmedPlainString(sharedStrings: sharedStrings)
			)
		}
	}

}
