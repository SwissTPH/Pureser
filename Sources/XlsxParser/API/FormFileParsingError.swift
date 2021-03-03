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
public enum FormFileParsingError: Error, CustomStringConvertible {

	//
	case other(Error)
	//
	case custom(String)


	//--------------------------------------------------

	private var _description: String {
		switch self {

		case .other(let e):
			return e.localizedDescription

		case .custom(let e):
			return e

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
