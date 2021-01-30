//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

public struct SurveyGroup: Codable, SurveyItemProtocol {
	var groupType: SurveyGroupType = .basic

	var name: String
	var label: Survey.LocalizedData

	var relevance: String? = nil
	var relevanceStepByStep: [String] = [] // for debugging
	var relevanceUnprocessed: String? = nil

	var items: [SurveyItem]
}

//--------------------------------------------------

public enum SurveyGroupType: String, Codable {
	case basic
	case repeatTable
}

//--------------------------------------------------
