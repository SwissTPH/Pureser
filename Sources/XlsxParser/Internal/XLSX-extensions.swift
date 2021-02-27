//
//  File.swift
//  
//
//  Created by R. Makhoul on 23/01/2021.
//

import Foundation
import CoreXLSX

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

		var trimmedPlainString: String? = nil

		//
		if let sharedStrings = sharedStrings {
			let richString: [RichText] = self.richStringValue(sharedStrings)
			let string: String? = self.stringValue(sharedStrings)

			//
			if !richString.isEmpty && !richString.isVacant {
				trimmedPlainString = richString.compactMap { $0.text }.joined()
			}
			//
			else if let string = string, !string.isEmpty {
				trimmedPlainString = string
			}
		}
		//
		else if let inlineString = self.inlineString, !inlineString.isVacant {
			trimmedPlainString = inlineString.text
		}
		//
		else if let value = self.value, !value.isEmpty {
			//
			if let type = self.type, type == .date, let dateValue: Date = self.dateValue {
				// RFC 3339 DateFormatter
				let dateFormatter = DateFormatter()
				dateFormatter.locale = Locale(identifier: "en_US_POSIX")
				dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
				dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss zzzxxx" // ZZZZ" // ZZZZZ"

				trimmedPlainString = dateFormatter.string(from: dateValue)
			}
			//
			else {
				trimmedPlainString = value
			}
		}

		//
		trimmedPlainString = trimmedPlainString?.trimmingCharacters(in: .whitespacesAndNewlines)

		//
		if let trimmedPlainString = trimmedPlainString, !trimmedPlainString.isEmpty {
			return trimmedPlainString
		}
		return nil
	}

	/// isVacant is true when the `trimmedPlainString` isEmpty or is `nil`.
	///
	func isVacant(sharedStrings: SharedStrings?) -> Bool {
		self.trimmedPlainString(sharedStrings: sharedStrings)?.isEmpty ?? true
	}

}


// MARK: -

fileprivate extension Array where Element == CoreXLSX.RichText {

	var isVacant: Bool {
		self.allSatisfy({ (richText: RichText) in
			richText.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
		})
	}

}

fileprivate extension CoreXLSX.InlineString {

	var isVacant: Bool {
		self.text?.isEmpty ?? true
	}

}
