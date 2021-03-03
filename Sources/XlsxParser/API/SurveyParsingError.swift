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
public enum SurveyParsingError: Error, CustomStringConvertible {

	case aGroupEndedWithoutStarting

	case referenceToChoicesSheetButChoicesWorksheetNotFound(inQuestion: String, questionType: String)

	case invalidQuestionTypeOptions(in: String)


	//--------------------------------------------------

	private var _description: String {
		switch self {

		case .aGroupEndedWithoutStarting:
			return #"A question group in the "survey" worksheet was ended without it actually starting."#

		case .referenceToChoicesSheetButChoicesWorksheetNotFound(inQuestion: let inQuestion, questionType: let questionType):
			return #"A question (name: "\#(inQuestion)", type "\#(questionType)") in the "survey" worksheet refers to a list from "choices" worksheet which is missing."#

		case .invalidQuestionTypeOptions(in: let `in`):
			return #"Invalid or unsupported question type "\#(`in`)"."#

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
