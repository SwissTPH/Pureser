//
//  File.swift
//  
//
//  Created by R. Makhoul on 07/02/2021.
//

//import Foundation
import Fluent


fileprivate typealias M = FileConversionLog
fileprivate typealias F = FileConversionLog.FieldKeys

extension FileConversionLog {
	struct Create: Migration {

		// Prepares the database for storing the models.
		func prepare(on database: Database) -> EventLoopFuture<Void> {
			return database.schema(M.schema)
				.id()

				.field(F.filename, .string, .required)
				.field(F.fileChecksum, .json, .required)
				.field(F.conversionPrintVersion, .string, .required)

				.field(F.conversionStatus, .string, .required)
				.field(F.conversionSuccessNotices, .array(of: .string))
				.field(F.conversionFailureErrors, .array(of: .string))

				.field(F.conversionStartDatetime, .datetime, .required)
				.field(F.conversionEndDatetime, .datetime, .required)

				.field(F.createdAt, .datetime)
				.field(F.deletedAt, .datetime)

				.create()
		}

		// Optionally reverts the changes made in the prepare method.
		func revert(on database: Database) -> EventLoopFuture<Void> {
			return database.schema(M.schema).delete()
		}
	}
}
