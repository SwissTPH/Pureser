//
//  File.swift
//  
//
//  Created by R. Makhoul on 02/03/2021.
//

import Foundation
import enum CoreXLSX.CoreXLSXError
import struct SurveyTypes.Survey


// MARK: - FormFile construct

public struct FormFile {

	// MARK: - Properties

	/// The file's data.
	//private var data: ByteBuffer

	private let fileData: Data

	/// Name of the file, including extension.
	private let filename: String

	/// The file extension, if it has one.
	private var `extension`: String? {
		let parts = self.filename.split(separator: ".")
		if parts.count > 1 {
			return parts.last.map(String.init)
		} else {
			return nil
		}
	}

	/// Name of the file, excluding extension.
	private var filenameExcludingExtension: String {
		let parts = filename.split(separator: ".")
		if parts.count > 1 {
			return parts.dropLast().joined(separator: ".")
		} else {
			return filename
		}
	}


	// MARK: - Initialization

	//
	public init(fileData: Data, filename: String) throws {

		self.fileData = fileData
		self.filename = filename
	}


	// MARK: - Methods

	/// Parse into `SheetsParser` construct.
	///
	public func parseSheets() throws -> SheetsParser {

		//
		let sheets: SheetsParser

		do {
			sheets = try SheetsParser(fileData: fileData, filename: filename)
		} catch let e as CoreXLSXError {
			// print(e)
			throw e
		} catch let e as SheetsParsingError {
			// print(e)
			throw e
		} catch {
			print(error)
			//throw error
			throw FormFileParsingError.custom(
				"Error: 120/21-12. XLSX file cannot be parsed. (" + String(describing: error) + ")")
		}

		//
		return sheets
	}

	/// Parse into `Survey` construct.
	///
	public func parseSurvey() throws -> Survey {

		//
		let sheets: SheetsParser = try self.parseSheets()

		//
		let survey: Survey
		do {
			survey = try SurveyParser.parseIntoSurvey(using: sheets)
		} catch let e as SurveyParsingError {
			// print(e)
			throw e
		} catch {
			// print(error)
			// throw error
			throw FormFileParsingError.custom(
				"Error: 210/02-03. (" + String(describing: error) + ")")
		}

		//
		return survey

	}

}
