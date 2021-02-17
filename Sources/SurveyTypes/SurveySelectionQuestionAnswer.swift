//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

public struct SurveySelectionQuestionAnswer: Codable {
	public var answerID: String
	public var answerLabel: Survey.LocalizedData


	public init(
		answerID: String,
		answerLabel: Survey.LocalizedData
	) {
		self.answerID = answerID
		self.answerLabel = answerLabel
	}
}

//--------------------------------------------------
