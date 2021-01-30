//
//  File.swift
//  
//
//  Created by R. Makhoul on 23/01/2021.
//

import Foundation
import CoreXLSX
import Vapor

// MARK: - CoreXLSX extensions

extension CoreXLSX.Row {

	/// isVacant is true when all cells in the row satisfy `isVacant == true`.
	///
	/// Note: a cell `isVacant` when the cell`trimmedPlainString` isEmpty or is `nil`.
	///
	func isVacant(sharedStrings: SharedStrings?) -> Bool {
		self.cells.allSatisfy({ (cell: CoreXLSX.Cell) in
			cell.isVacant(sharedStrings: sharedStrings)
		})
	}

}

extension CoreXLSX.Cell {

	/// Trimmed plain string.
	///
	/// If it is empty after trimming it will return `nil`.
	///
	func trimmedPlainString(sharedStrings: SharedStrings?) -> String? {

		//guard type == .sharedString else { return nil }
		guard let sharedStrings = sharedStrings else { return nil }

		let c = self

		let string = c.stringValue(sharedStrings)
		let date = c.dateValue
		let richString = c.richStringValue(sharedStrings)

		let trimmedPlainString: String?

		if !richString.isEmpty && !richString.allSatisfy({ $0.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true }) {
			trimmedPlainString = richString.compactMap { $0.text }.joined().trimmingCharacters(in: .whitespacesAndNewlines)
		}
		else if let string = string?.trimmingCharacters(in: .whitespacesAndNewlines), !string.isEmpty {
			trimmedPlainString = string
		}
		else if let date = date {
			trimmedPlainString = String(describing: date)
		}
		else {
			trimmedPlainString = nil
		}

		if let trimmedPlainString = trimmedPlainString, trimmedPlainString.isEmpty {
			return nil
		}

		return trimmedPlainString
	}

	/// isVacant is true when the `trimmedPlainString` isEmpty or is `nil`.
	///
	func isVacant(sharedStrings: SharedStrings?) -> Bool {
		self.trimmedPlainString(sharedStrings: sharedStrings)?.isEmpty ?? true
	}

}
