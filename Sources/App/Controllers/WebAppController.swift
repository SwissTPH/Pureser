//
//  File.swift
//  
//
//  Created by R. Makhoul on 27/10/2020.
//

import Foundation
import Vapor
import struct SurveyTypes.Survey
import XlsxParser

struct WebAppController: RouteCollection {

	/// Maximum size of vapor's routing body streaming for this `RouteCollection`.
	///
	/// `maxSize` Limits the maximum amount of memory in bytes that will be used to
	/// collect a streaming body. Streaming requests exceeding that size will result in an error.
	/// Passing `nil` results in the application's default max body size being used. This
	/// parameter does not affect non-streaming requests.
	let maxSize: ByteCount? = Settings.maxSize

	//
	func boot(routes: RoutesBuilder) throws {
		let rb = routes.grouped("")

		// GET /
		rb.get(use: self.indexPageHandler)

		//--------------------------------------------------

		// GET /cdp/
		rb.get("cdp", use: self.redirectToIndex)

		// POST /cdp/
		// Collects streaming bodies (up to size specified in `maxSize` constant) before calling this route.
		// Streaming requests exceeding that size will result in an error.
		rb.on(.POST, "cdp", body: .collect(maxSize: maxSize), use: self.convertedDocumentPagePostHandler)

		//--------------------------------------------------

		// POST /cdp/download/
		rb.on(.POST, "cdp", "download", body: .collect, use: self.downloadConvertedDocumentPagePostHandler)

		//--------------------------------------------------

		if Settings.Feature.fileConversionLog {
			// GET /history/
			rb.get("history", use: self.fileConversionLogPageHandler)
		}

		//--------------------------------------------------

		rb.group("debug") { rb in
			// GET & POST /debug/crp/
			rb.get("crp", use: self.debugConvertedResultPageHandler)
			rb.on(.POST, "crp", body: .collect(maxSize: maxSize), use: self.debugConvertedResultPagePostHandler)

			// GET & POST /debug/survey/
			rb.get("survey", use: self.debugSurveyHandler)
			rb.on(.POST, "survey", body: .collect(maxSize: maxSize), use: self.debugSurveyPostHandler)

			// GET & POST /debug/cells/
			//rb.get("cells", use: self.debugCellsPageHandler)
			//rb.on(.POST, "cells", body: .collect(maxSize: maxSize), use: self.debugCellsPagePostHandler)

			// GET & POST /debug/corexlsx-file/
			rb.get("corexlsx-file", use: self.debugCoreXLSXFilePageHandler)
			rb.on(.POST, "corexlsx-file", body: .collect(maxSize: maxSize), use: self.debugCoreXLSXFilePagePostHandler)
		}

	}

	//--------------------------------------------------

	// MARK: index Page

	func indexPageHandler(req: Request) -> EventLoopFuture<Response> {
		return req.eventLoop.future(HomePage().htmlResponse())
	}

	//--------------------------------------------------

	// MARK: redirectToIndex

	func redirectToIndex(req: Request) -> Response {
		return req.redirect(to: "/")
	}

	//--------------------------------------------------

	// MARK: newFile Page

	func convertedDocumentPagePostHandler(_ req: Request) throws -> Response {

		//
		let uploadPageFormData: UploadPageFormData
		do {
			uploadPageFormData = try req.content.decode(UploadPageFormData.self)
		} catch {
			throw Abort(.badRequest, reason: "Error: 110/21-12.")
		}

		//
		let file: Vapor.File = uploadPageFormData.xlsxFile

		//
		guard file.data.readableBytes > 0 else {
			print("Error: 112/26-01. Empty upload.")
			throw Abort(.badRequest, reason: "No file attached.")
		}

		//
		let fileData: Data = Data(file.data.readableBytesView)

		//
		let filename = file.filename
		print(#"File attached filename: "\#(filename)"."#)

		//--------------------------------------------------

		let survey: Survey
		let _survey: () throws -> Survey = {
			try FormFile(fileData: fileData, filename: filename).parseSurvey()
		}

		if Settings.Feature.fileConversionLog {
			let fileConversionLogEntry: FileConversionLog = FileConversionLog(
				filename: filename,
				fileChecksum: .init(fileData: fileData),
				conversionPrintVersion: .init(uploadPageFormData.printVersion)
			)

			defer {
				fileConversionLogEntry.conversionEndDatetime = Date()

				// This is in case the code execution stops unexpectedly.
				if ![.success, .failure].contains(fileConversionLogEntry.conversionStatus) {
					fileConversionLogEntry.conversionStatus = .failure
				}

				// Save either as success or as failure.
				_ = fileConversionLogEntry.save(on: req.db)
			}

			do {
				survey = try _survey()
			} catch {
				//
				fileConversionLogEntry.conversionStatus = .failure
				fileConversionLogEntry.conversionFailureErrors.append(String(describing: error))

				throw error
			}

			//
			fileConversionLogEntry.conversionStatus = .success
			fileConversionLogEntry.conversionSuccessNotices.append(contentsOf: [])
		} else {
			do {
				survey = try _survey()
			} catch {
				throw error
			}
		}

		//--------------------------------------------------

		//
		return ConvertedDocumentPage(survey: survey, uploadPageFormData: uploadPageFormData).htmlResponse()
	}

	// MARK: downloadFile Page

	func downloadConvertedDocumentPagePostHandler(_ req: Request) throws -> Response {
		return req.redirect(to: "/")
	}

	//--------------------------------------------------

	// MARK: fileConversionLog Page

	func fileConversionLogPageHandler(_ req: Request) throws -> EventLoopFuture<Response> {

		let queryRequestLimit: Int = Settings.debug ? 100 : 20

		let dbr = FileConversionLog.DatabaseRepository(database: req.db)
		let fileConversionLogCount = dbr.count()
		return fileConversionLogCount.flatMap {
			(fileConversionLogCount: Int) -> EventLoopFuture<Response> in

			let fileConversionLog = dbr.mostRecent(queryRequestLimit)
			return fileConversionLog.map {
				(fileConversionLog: [FileConversionLog]) -> Response in

				return FileConversionLogPage(
					fileConversionLog: fileConversionLog,
					totalCountOfFilesConverted: fileConversionLogCount,
					queryRequestLimit: queryRequestLimit
				).htmlResponse()
			}
		}
	}

	//--------------------------------------------------

	// MARK: debugConvertedResult Page

	func debugConvertedResultPageHandler(_ req: Request) throws -> Response {
		return UploadPage(debug: .crp).htmlResponse()
	}

	func debugConvertedResultPagePostHandler(_ req: Request) throws -> Response {
		let uploadPageFormData = try req.content.decode(UploadPageFormData.self)

		guard uploadPageFormData.xlsxFile.data.readableBytes > 0 else {
			print("Error: 169/27-01. Empty upload.")
			throw Abort(.badRequest, reason: "No file attached.")
		}

		let fileData: Data = uploadPageFormData.xlsxFileData
		let filename = uploadPageFormData.xlsxFile.filename

		let sheets = try SheetsParser(fileData: fileData, filename: filename)
		let survey: Survey = try SurveyParser.parseIntoSurvey(using: sheets)

		return ConvertedDocumentPage(survey: survey).htmlResponse()
	}

	//--------------------------------------------------

	// MARK: debugSurvey

	func debugSurveyHandler(_ req: Request) throws -> Response {
		return UploadPage(debug: .survey).htmlResponse()
	}

	func debugSurveyPostHandler(_ req: Request) throws -> Survey {
		let uploadPageFormData = try req.content.decode(UploadPageFormData.self)

		guard uploadPageFormData.xlsxFile.data.readableBytes > 0 else {
			print("Error: 209/27-01. Empty upload.")
			throw Abort(.badRequest, reason: "No file attached.")
		}

		let fileData: Data = uploadPageFormData.xlsxFileData
		let filename = uploadPageFormData.xlsxFile.filename

		let sheets = try SheetsParser(fileData: fileData, filename: filename)
		let survey: Survey = try SurveyParser.parseIntoSurvey(using: sheets)

		return survey
	}

	//--------------------------------------------------

	// MARK: debugCells Page

	/*
	func debugCellsPageHandler(_ req: Request) throws -> Response {
		return UploadPage(debug: .cells).htmlResponse()
	}

	func debugCellsPagePostHandler(_ req: Request) throws -> Response {
		let uploadPageFormData = try req.content.decode(UploadPageFormData.self)

		let fileData: Data = uploadPageFormData.xlsxFileData
		let cellsAndValues = try Workbook(fileData: fileData).listOfCellsAndValues()

		return DebugCellsPage(cellsAndValues: cellsAndValues).htmlResponse()
	}
	*/

	//--------------------------------------------------

	// MARK: debug CoreXLSX.Workbook

	func debugCoreXLSXFilePageHandler(_ req: Request) throws -> Response {
		return UploadPage(debug: .coreXLSXFile).htmlResponse()
	}

	func debugCoreXLSXFilePagePostHandler(_ req: Request) throws -> DebugCoreXLSXFile {
		let uploadPageFormData = try req.content.decode(UploadPageFormData.self)

		let fileData: Data = uploadPageFormData.xlsxFileData

		//--------------------------------------------------

		return try debugCoreXLSXFile(fileData: fileData)
	}

	//--------------------------------------------------
}
