//
//  File.swift
//  
//
//  Created by R. Makhoul on 02/03/2021.
//

import Foundation

@_exported import enum CoreXLSX.CoreXLSXError


extension CoreXLSXError {

	private var _description: String {
		var x: String {
			switch self {
			case .dataIsNotAnArchive:
				return "Data is not an archive."
			case .archiveEntryNotFound:
				return "Archive entry not found."
			case .invalidCellReference:
				return "Invalid cell reference."
			case .unsupportedWorksheetPath:
				return "Unsupported worksheet path."
			}
		}
		return "Invalid or unsupported XLSX file. (\(x))"
	}

	private var _localizedDescription: String {
		self._description
	}

	public var localizedDescription: String {
		NSLocalizedString(self._localizedDescription, comment: "")
	}
}


extension CoreXLSXError: CustomStringConvertible {
	public var description: String {
		self.localizedDescription
	}
}
