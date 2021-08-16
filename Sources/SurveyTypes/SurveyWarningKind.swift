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
public enum SurveyWarningKind: Codable, CustomStringConvertible {

	case aGroupStartedWithoutEnding

	case aGroupEndedWithoutStarting

	case referenceToChoicesSheetButChoicesWorksheetNotFound(inQuestion: String, questionType: String)

	case referenceToChoicesSheetListButListNotFound(inQuestion: String, questionType: String, listName: String)

	case invalidQuestionTypeOptions(in: String, type: String)

	//--------------------------------------------------

	private var _description: String {
		switch self {

		case .aGroupStartedWithoutEnding:
			return #"A question group in the worksheet "survey" was started, but was not ended."#

		case .aGroupEndedWithoutStarting:
			return #"A question group in the worksheet "survey" was ended, but was not started."#

		case .referenceToChoicesSheetButChoicesWorksheetNotFound(inQuestion: let inQuestion, questionType: let questionType):
			return #"A question (name: "\#(inQuestion)", type: "\#(questionType)") in the worksheet "survey" refers to a list from worksheet "choices" which is missing."#

		case .referenceToChoicesSheetListButListNotFound(inQuestion: let inQuestion, questionType: let questionType, listName: let listName):
			return #"A question (name: "\#(inQuestion)", type: "\#(questionType)") in the worksheet "survey" refers to a missing list (name: "\#(listName)") from the worksheet "choices"."#

		case .invalidQuestionTypeOptions(in: let `in`, type: let type):
			return #"Invalid or unsupported question type (name: "\#(`in`)", type: "\#(type)")."#

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

#if swift(<5.5)
// https://github.com/apple/swift-evolution/blob/main/proposals/0295-codable-synthesis-for-enums-with-associated-values.md
extension SurveyWarningKind {

	// contains keys for all cases of the enum
	private enum CodingKeys: CodingKey {
		case aGroupStartedWithoutEnding
		case aGroupEndedWithoutStarting
		case referenceToChoicesSheetButChoicesWorksheetNotFound
		case referenceToChoicesSheetListButListNotFound
		case invalidQuestionTypeOptions
	}

	// contains keys for all associated values of the respective `case`
	private enum CodingKeys_referenceToChoicesSheetButChoicesWorksheetNotFound: CodingKey {
		case inQuestion
		case questionType
	}

	// contains keys for all associated values of the respective `case`
	private enum CodingKeys_referenceToChoicesSheetListButListNotFound: CodingKey {
		case inQuestion
		case questionType
		case listName
	}

	// contains keys for all associated values of the respective `case`
	private enum CodingKeys_invalidQuestionTypeOptions: CodingKey {
		case `in`
		case type
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		switch self {

		case .aGroupStartedWithoutEnding:
			try container.encode(true, forKey: .aGroupEndedWithoutStarting)

		case .aGroupEndedWithoutStarting:
			try container.encode(true, forKey: .aGroupEndedWithoutStarting)

		case let .referenceToChoicesSheetButChoicesWorksheetNotFound(inQuestion: inQuestion, questionType: questionType):
			var nestedContainer = container.nestedContainer(
				keyedBy: CodingKeys_referenceToChoicesSheetButChoicesWorksheetNotFound.self,
				forKey: .referenceToChoicesSheetButChoicesWorksheetNotFound
			)
			try nestedContainer.encode(inQuestion, forKey: .inQuestion)
			try nestedContainer.encode(questionType, forKey: .questionType)

		case let .referenceToChoicesSheetListButListNotFound(inQuestion: inQuestion, questionType: questionType, listName: listName):
			var nestedContainer = container.nestedContainer(
				keyedBy: CodingKeys_referenceToChoicesSheetListButListNotFound.self,
				forKey: .referenceToChoicesSheetListButListNotFound
			)
			try nestedContainer.encode(inQuestion, forKey: .inQuestion)
			try nestedContainer.encode(questionType, forKey: .questionType)
			try nestedContainer.encode(listName, forKey: .listName)

		case let .invalidQuestionTypeOptions(in: `in`, type: type):
			var nestedContainer = container.nestedContainer(
				keyedBy: CodingKeys_invalidQuestionTypeOptions.self,
				forKey: .invalidQuestionTypeOptions
			)
			try nestedContainer.encode(`in`, forKey: .in)
			try nestedContainer.encode(type, forKey: .type)

		}
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		if container.allKeys.count != 1 {
			let context = DecodingError.Context(
				codingPath: container.codingPath,
				debugDescription: "Invalid number of keys found, expected one.")
			throw DecodingError.typeMismatch(Self.self, context)
		}

		switch container.allKeys.first.unsafelyUnwrapped {

		case .aGroupStartedWithoutEnding:
			self = .aGroupStartedWithoutEnding

		case .aGroupEndedWithoutStarting:
			self = .aGroupEndedWithoutStarting

		case .referenceToChoicesSheetButChoicesWorksheetNotFound:
			let nestedContainer = try container.nestedContainer(
				keyedBy: CodingKeys_referenceToChoicesSheetButChoicesWorksheetNotFound.self,
				forKey: .referenceToChoicesSheetButChoicesWorksheetNotFound
			)
			self = .referenceToChoicesSheetButChoicesWorksheetNotFound(
				inQuestion: try nestedContainer.decode(String.self, forKey: .inQuestion),
				questionType: try nestedContainer.decode(String.self, forKey: .questionType)
			)

		case .referenceToChoicesSheetListButListNotFound:
			let nestedContainer = try container.nestedContainer(
				keyedBy: CodingKeys_referenceToChoicesSheetListButListNotFound.self,
				forKey: .referenceToChoicesSheetListButListNotFound
			)
			self = .referenceToChoicesSheetListButListNotFound(
				inQuestion: try nestedContainer.decode(String.self, forKey: .inQuestion),
				questionType: try nestedContainer.decode(String.self, forKey: .questionType),
				listName: try nestedContainer.decode(String.self, forKey: .listName)
			)

		case .invalidQuestionTypeOptions:
			let nestedContainer = try container.nestedContainer(
				keyedBy: CodingKeys_invalidQuestionTypeOptions.self,
				forKey: .invalidQuestionTypeOptions
			)
			self = .invalidQuestionTypeOptions(
				in: try nestedContainer.decode(String.self, forKey: .in),
				type: try nestedContainer.decode(String.self, forKey: .type)
			)

		}
	}

}
#endif

//
extension SurveyWarningKind {

	public var warningDescription: SurveyWarningDescription {
		switch self {
		case .aGroupStartedWithoutEnding:
			return .init(
				inList: self.localizedDescription,
				onItem: #""#
			)
		case .aGroupEndedWithoutStarting:
			return .init(
				inList: self.localizedDescription,
				onItem: #""#
			)
		case .referenceToChoicesSheetButChoicesWorksheetNotFound:
			return .init(
				inList: self.localizedDescription,
				onItem: #"This question requires a list from the worksheet "choices", but the worksheet "choices" is missing."#
			)
		case .referenceToChoicesSheetListButListNotFound:
			return .init(
				inList: self.localizedDescription,
				onItem: #"This question requires a list from the worksheet "choices", but the list is missing."#
			)
		case .invalidQuestionTypeOptions:
			return .init(
				inList: self.localizedDescription,
				onItem: #"This question has an invalid or unsupported type."#
			)
		}
	}

}
