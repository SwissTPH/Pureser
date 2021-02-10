//
//  File.swift
//  
//
//  Created by R. Makhoul on 07/02/2021.
//

//import Foundation
import Fluent
import Vapor
import Crypto


// MARK: - Model

final class FileConversionLog: Model {
	static let schema = "file_conversion_logs"

	struct FieldKeys {
		static var filename: FieldKey { "filename" }
		static var fileChecksum: FieldKey { "file_checksum" }
		static var conversionPrintVersion: FieldKey { "conversion_print_version" }

		static var conversionStatus: FieldKey { "conversion_status" }
		static var conversionSuccessNotices: FieldKey { "conversion_success_notices" }
		static var conversionFailureErrors: FieldKey { "conversion_failure_errors" }

		static var conversionStartDatetime: FieldKey { "conversion_start_datetime" }
		static var conversionEndDatetime: FieldKey { "conversion_end_datetime" }

		static var createdAt: FieldKey { "created_at" }
		static var deletedAt: FieldKey { "deleted_at" }
	}

	//--------------------------------------------------

	@ID(key: .id)
	var id: UUID?


	@Field(key: FieldKeys.filename)
	var filename: String

	@Field(key: FieldKeys.fileChecksum)
	var fileChecksum: SQLStructConversionFileChecksum

	@Field(key: FieldKeys.conversionPrintVersion)
	var conversionPrintVersion: SQLEnumConversionPrintVersion


	@Field(key: FieldKeys.conversionStatus)
	var conversionStatus: SQLEnumConversionStatus

	@Field(key: FieldKeys.conversionSuccessNotices)
	var conversionSuccessNotices: [String]

	@Field(key: FieldKeys.conversionFailureErrors)
	var conversionFailureErrors: [String]


	@Field(key: FieldKeys.conversionStartDatetime)
	var conversionStartDatetime: Date

	@Field(key: FieldKeys.conversionEndDatetime)
	var conversionEndDatetime: Date


	@Timestamp(key: FieldKeys.createdAt, on: .create)
	var createdAt: Date?

	@Timestamp(key: FieldKeys.deletedAt, on: .delete)
	var deletedAt: Date?

	//--------------------------------------------------

	init() { }

	init(
		id: UUID? = nil,

		filename: String,
		fileChecksum: SQLStructConversionFileChecksum,
		conversionPrintVersion: SQLEnumConversionPrintVersion,

		conversionStatus: SQLEnumConversionStatus = .ongoing,
		conversionSuccessNotices: [String] = [],
		conversionFailureErrors: [String] = [],

		conversionStartDatetime: Date = Date(),
		//conversionEndDatetime: Date? = nil,

		createdAt: Date? = nil,
		deletedAt: Date? = nil
	) {
		self.id = id

		self.filename = filename
		self.fileChecksum = fileChecksum
		self.conversionPrintVersion = conversionPrintVersion

		self.conversionStatus = conversionStatus
		self.conversionSuccessNotices = conversionSuccessNotices
		self.conversionFailureErrors = conversionFailureErrors

		self.conversionStartDatetime = conversionStartDatetime
		//self.conversionEndDatetime = conversionEndDatetime

		self.createdAt = createdAt
		self.deletedAt = deletedAt
	}
}

// MARK: Extensions

extension FileConversionLog: Content { }


extension FileConversionLog {

	// Note: `TimeInterval` is typealias to `Double`.
	var conversionExecutionTimeInterval: TimeInterval {
		self.conversionEndDatetime
			.timeIntervalSince(self.conversionStartDatetime)
	}

	func conversionExecutionTimeInterval(fractionDigits: Int) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimumFractionDigits = fractionDigits
		formatter.maximumFractionDigits = fractionDigits

		let x = self.conversionExecutionTimeInterval
		return formatter.string(from: NSNumber(value: x)) ?? "\(x)"
	}
}


// MARK: - SQL structs

struct SQLStructConversionFileChecksum: Codable {
	// MD5 Digest (formatted as `String`).
	var md5: String

	// SHA1 Digest (formatted as `String`).
	var sha1: String

	// SHA256 Digest (formatted as `String`).
	var sha256: String
}

extension SQLStructConversionFileChecksum: Equatable { }

extension SQLStructConversionFileChecksum {
	init(fileData: Data) {
		let inputData = fileData

		self.md5 = { () -> String in
			let hashed = Crypto.Insecure.MD5.hash(data: inputData)
			let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
			return hashString
		}()

		self.sha1 = { () -> String in
			let hashed = Crypto.Insecure.SHA1.hash(data: inputData)
			let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
			return hashString
		}()

		self.sha256 = { () -> String in
			let hashed = Crypto.SHA256.hash(data: inputData)
			let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
			return hashString
		}()
	}
}


// MARK: - SQL enums

//
enum SQLEnumConversionStatus: String, Codable {
	case ongoing = "Ongoing"
	case success = "Success"
	case failure = "Failure"
}

extension SQLEnumConversionStatus: Content {
	static let name = "SQLEnum_ConversionStatus"
}

extension SQLEnumConversionStatus {
	var toString: String {
		switch self {
		case .ongoing:
			return "Ongoing"
		case .success:
			return "Success"
		case .failure:
			return "Failure"
		}
	}
	var toStringWithEmoji: String {
		let emoji: String
		switch self {
		case .ongoing:
			emoji = "🟠"
		case .success:
			emoji = "🟢"
		case .failure:
			emoji = "🔴"
		}
		return emoji + " " + toString
	}
}


//
enum SQLEnumConversionPrintVersion: String, Codable {
	///
	case developer = "v0_Developer"

	/// "Data Manager" version case
	case dataManager = "v1_DataManager"

	/// "Interviewer" version case
	case interviewer = "v2_Interviewer"
}

extension SQLEnumConversionPrintVersion {
	init(_ printVersion: PrintVersion) {
		switch printVersion {
		case .developer:
			self = .developer
		case .dataManager:
			self = .dataManager
		case .interviewer:
			self = .interviewer
		}
	}
}

extension SQLEnumConversionPrintVersion: Content {
	static let name = "SQLEnum_ConversionPrintVersion"
}

extension SQLEnumConversionPrintVersion {
	var toString: String {
		switch self {
		case .developer:
			return "Developer"
		case .dataManager:
			return "Data Manager"
		case .interviewer:
			return "Interviewer"
		}
	}
}

// MARK: - Repository

extension FileConversionLog {
	struct DatabaseRepository {
		let database: Database

		//--------------------------------------------------

		func count() -> EventLoopFuture<Int> {
			var queryBuilder: QueryBuilder<FileConversionLog> = FileConversionLog.query(on: database)

			if !Settings.debug {
				queryBuilder = queryBuilder.filter(\.$conversionPrintVersion, .notEqual, SQLEnumConversionPrintVersion.developer)
			}

			return queryBuilder.count()
		}

		func mostRecent(_ count: Int) -> EventLoopFuture<[FileConversionLog]> {

			var queryBuilder: QueryBuilder<FileConversionLog> = FileConversionLog.query(on: database)

			if !Settings.debug {
				queryBuilder = queryBuilder.filter(\.$conversionPrintVersion, .notEqual, SQLEnumConversionPrintVersion.developer)
			}

			queryBuilder = queryBuilder
				.sort(\.$conversionStartDatetime, .descending)
				.sort(\.$conversionEndDatetime, .descending)
				.sort(\.$createdAt, .descending)
				.sort(\.$filename, .descending)
				.limit(count)

			var fileConversionLog = queryBuilder.all()

			if false {
				fileConversionLog = fileConversionLog
					.map { (fileConversionLog: [FileConversionLog]) -> [FileConversionLog] in
						fileConversionLog.reversed()
					}
			}

			return fileConversionLog
		}

		//--------------------------------------------------
	}
}
