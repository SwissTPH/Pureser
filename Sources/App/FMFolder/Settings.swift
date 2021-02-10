//
//  File.swift
//  
//
//  Created by R. Makhoul on 03/12/2020.
//

import Foundation
import Vapor

struct Settings {

	/// Detect and return web app environment.
	static let environment: Environment = (try? Environment.detect()) ?? .production

	/// Whether to display debug details.
	static var debug: Bool = Self.environment == .development

	//--------------------------------------------------

	///	Streaming bodies max size.
	/// Maximum size of vapor's routing body streaming for the vapor routes
	/// that collect an ".xlsx" file.
	///
	/// `maxSize` Limits the maximum amount of memory in bytes that will be used to
	/// collect a streaming body. Streaming requests exceeding that size will result in an error.
	/// Passing `nil` results in the application's default max body size being used. This
	/// parameter does not affect non-streaming requests.
	static let maxSize: ByteCount? = "20mb"

	//--------------------------------------------------

	/// Groups controls of `Survey` localized data.
	struct SurveyLocalizedData {

		///
		static var onlyCommonLanguagesForLabelCluster: Bool = true

	}

	/// Web app feature controls.
	struct Feature {

		/// Whether to display `SurveyItem` relevance.
		static var itemRelevance: Bool = true


		/// Whether to enable form files conversion logging.
		static var fileConversionLog: Bool = true
	}



	/// Web app debugging controls.
	struct Debug {

		/// Whether to display `SurveyItem` relevance debug details.
		static var surveyItemRelevance: Bool = Settings.debug && false

		/// Groups debugging controls of `Survey` localized data.
		struct SurveyLocalizedData {

			/// Whether to display `SurveyItem` label debug details.
			static private var surveyItemLabel: Bool = Settings.debug && false

			/// Whether to display `SurveyGroup` label debug details.
			static var surveyGroupLabel: Bool = Self.surveyItemLabel && false

			/// Whether to display `SurveyQuestion` label debug details.
			static var surveyQuestionLabel: Bool = Self.surveyItemLabel && false

			/// Whether to display `SurveyQuestionSelectionAnswer` label debug details.
			static var surveyQuestionSelectionAnswerLabel: Bool = Self.surveyQuestionLabel && false

		}

	}

}
