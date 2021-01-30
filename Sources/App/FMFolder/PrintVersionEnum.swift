//
//  File.swift
//  
//
//  Created by R. Makhoul on 12/11/2020.
//

import Foundation

//--------------------------------------------------

//
//
//
enum PrintVersion: String, Decodable {

	/// A version for development.
	case developer = "v0"

	/// "Data Manager" version case
	case dataManager = "v1"

	/// "Interviewer" version case
	case interviewer = "v2"


	/// If you change the `CodingKeys` string value, make sure to change them also in related HTML and Javascript.
	struct FormInputValue {
		static let developer = PrintVersion.developer.rawValue
		static let dataManager = PrintVersion.dataManager.rawValue
		static let interviewer = PrintVersion.interviewer.rawValue
	}
}

//--------------------------------------------------
