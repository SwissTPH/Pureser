//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

// MARK: - SurveyItemProtocol

public protocol SurveyItemProtocol: Codable {
	var relevance: Survey.LocalizedData? { get }
	var relevanceStepByStep: [Survey.LocalizedData] { get } // for debugging
	var relevanceUnprocessed: String? { get }
}

//--------------------------------------------------

// MARK: - SurveyItem

public enum SurveyItem {
	case group(SurveyGroup)
	case question(SurveyQuestion)
}


extension SurveyItem: Codable {
	enum CodingKeys: CodingKey {
		case group
		case question
	}
	enum CodingError: Error {
		case unknownValue
	}
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		/// Note: the `value` constant below refers to the `associated value` of the `case`
		if let value = try container.decodeIfPresent(SurveyGroup.self, forKey: .group) {
			self = .group(value)
		} else if let value = try container.decodeIfPresent(SurveyQuestion.self, forKey: .question) {
			self = .question(value)
		} else {
			throw CodingError.unknownValue
		}
	}
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		/// Note: the `value` constant below refers to the `associated value` of the `case`
		switch self {
		case .group(let value):
			try container.encode(value, forKey: .group)
		case .question(let value):
			try container.encode(value, forKey: .question)
		}
	}
}

//--------------------------------------------------

// MARK: - Extension [SurveyItem]

extension Collection where Element == SurveyItem {

	///
	private func allQuestionsFlatMapHelper(surveyItem: SurveyItem) -> [SurveyQuestion] {
		switch surveyItem {
		case .group(let surveyGroup):
			return self.allQuestionsFlatMapHelper(surveyGroup: surveyGroup)
		case .question(let surveyQuestion):
			return [surveyQuestion]
		}
	}

	///
	private func allQuestionsFlatMapHelper(surveyGroup: SurveyGroup) -> [SurveyQuestion] {
		surveyGroup.items.flatMap { surveyItem in
			self.allQuestionsFlatMapHelper(surveyItem: surveyItem)
		}
	}

	///
	public var allQuestionsFlatMap: [SurveyQuestion] {
		self.flatMap { (surveyItem: Element) in
			self.allQuestionsFlatMapHelper(surveyItem: surveyItem)
		}
	}

}

//--------------------------------------------------
