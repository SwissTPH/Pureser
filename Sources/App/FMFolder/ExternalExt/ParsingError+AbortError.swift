//
//  File.swift
//  
//
//  Created by R. Makhoul on 02/03/2021.
//

import Foundation

import protocol Vapor.AbortError
import enum Vapor.HTTPStatus


import enum XlsxParser.CoreXLSXError
import enum XlsxParser.SheetsParsingError
import enum XlsxParser.SurveyParsingError
import enum XlsxParser.FormFileParsingError


// MARK: - CoreXLSXError

extension CoreXLSXError: AbortError {
	public var reason: String {
		switch self {
		default:
			return self.localizedDescription
		}
	}

	public var status: HTTPStatus {
		switch self {
		default:
			return .badRequest
		}
	}
}


// MARK: - SheetsParsingError

extension SheetsParsingError: AbortError {
	public var reason: String {
		switch self {
		default:
			return self.localizedDescription
		}
	}

	public var status: HTTPStatus {
		switch self {
		default:
			return .badRequest
		}
	}
}


// MARK: - SurveyParsingError

extension SurveyParsingError: AbortError {
	public var reason: String {
		switch self {
		default:
			return self.localizedDescription
		}
	}

	public var status: HTTPStatus {
		switch self {
		default:
			return .internalServerError
		}
	}
}


// MARK: - FormFileParsingError

extension FormFileParsingError: AbortError {
	public var reason: String {
		switch self {
		default:
			return self.localizedDescription
		}
	}

	public var status: HTTPStatus {
		switch self {
		default:
			return .internalServerError
		}
	}
}
