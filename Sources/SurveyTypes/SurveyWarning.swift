//
//  File.swift
//  
//
//  Created by R. Makhoul on 12/07/2021.
//

import Foundation


//
public struct SurveyWarning: Codable {

	public var level: String?

	public var warningKind: SurveyWarningKind

	public var warningDescription: SurveyWarningDescription {
		self.warningKind.warningDescription
	}

	public var row: String?
	public var column: String?
	public var cell: String?

	public var formItemID: String?
	public var formItemType: String?


	public init(
		warningKind: SurveyWarningKind,

		row: UInt? = nil,
		column: String? = nil,
		cell: String? = nil,

		formItemID: String? = nil,
		formItemType: String? = nil
	) {
		self.level = nil

		self.warningKind = warningKind

		self.row = row.flatMap(String.init)
		self.column = column
		self.cell = cell

		self.formItemID = formItemID
		self.formItemType = formItemType
	}


}


//
public struct SurveyWarningDescription: Codable {
	public var inList: String
	public var onItem: String

	public init(
		inList: String,
		onItem: String
	) {
		self.inList = inList
		self.onItem = onItem
	}
}
