//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

public enum SurveyQuestionType: String, Codable {

	case start = "start"
	case end = "end"

	//case beginGroup = "begin group"
	//case endGroup = "end group"

	//case beginRepeat = "begin repeat"
	//case endRepeat = "end repeat"

	case selectOne = "select_one"
	case selectMultiple = "select_multiple"

	case date = "date"
	case today = "today"

	case integer = "integer"
	case decimal = "decimal"
	case calc = "calculate" // calculation

	case note = "note"
	case text = "text"

	case deviceID = "deviceid"
	case simSerial = "simserial"
	case phoneNumber = "phonenumber"
	case startGeopoint = "start-geopoint"
	case geopoint = "geopoint"
	case barcode = "barcode"
	case range = "range"

	case audit = "audit"
	case rank = "rank"
	case trigger = "trigger"

	case unknown
}

//--------------------------------------------------
