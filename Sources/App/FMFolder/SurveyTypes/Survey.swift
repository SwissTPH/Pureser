//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

public struct Survey: Codable {

	public var formTitle: String
	public var version: String
	public var formID: String
	public var style: String
	public var defaultLanguage: Survey.DatumLanguage
	public var instanceName: String

	public var languagesAvailable: Survey.LanguagesAvailable

	public var items: [SurveyItem]

	//--------------------------------------------------

	@available(*, deprecated, renamed: "formTitle")
	public var title: String {
		formTitle
	}

	@available(*, deprecated, renamed: "languagesAvailable.all")
	public var languages: [Survey.DatumLanguage] {
		languagesAvailable.all
	}
	@available(*, deprecated, renamed: "languagesAvailable.forLabelCluster.inCommon")
	public var languagesInCommonForLabelCluster: [Survey.DatumLanguage] {
		languagesAvailable.forLabelCluster.inCommon
	}
	@available(*, deprecated, renamed: "languagesAvailable.forLabelCluster.inGroupsAndQuestions")
	public var languagesInGroupsAndQuestionsForLabelCluster: [Survey.DatumLanguage] {
		languagesAvailable.forLabelCluster.inGroupsAndQuestions
	}
	@available(*, deprecated, renamed: "languagesAvailable.forLabelCluster.inSelectionAnswers")
	public var languagesInSelectionAnswersForLabelCluster: [Survey.DatumLanguage] {
		languagesAvailable.forLabelCluster.inSelectionAnswers
	}

}

//--------------------------------------------------
