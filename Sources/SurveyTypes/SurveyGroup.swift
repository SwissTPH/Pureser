//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

public struct SurveyGroup: Codable, SurveyItemProtocol {
	public var groupType: SurveyGroupType

	public var name: String?
	public var label: Survey.LocalizedData

	public var relevance: String?
	public var relevanceStepByStep: [String] // for debugging
	public var relevanceUnprocessed: String?

	public var items: [SurveyItem]


	public init(
		groupType: SurveyGroupType = .basic,

		name: String?,
		label: Survey.LocalizedData,

		relevance: String? = nil,
		relevanceStepByStep: [String] = [],
		relevanceUnprocessed: String? = nil,

		items: [SurveyItem]
	) {
		self.groupType = groupType

		self.name = name
		self.label = label

		self.relevance = relevance
		self.relevanceStepByStep = relevanceStepByStep
		self.relevanceUnprocessed = relevanceUnprocessed

		self.items = items
	}
}

//--------------------------------------------------

public enum SurveyGroupType: String, Codable {
	case basic
	case repeatTable
}

//--------------------------------------------------
