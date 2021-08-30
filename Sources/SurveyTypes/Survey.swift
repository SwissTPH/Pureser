//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation

//--------------------------------------------------

public struct Survey: Codable {

	/// The title of the form that is shown to users.
	///
	/// `form_title`.
	///
	/// Title displayed at beginning of form, in form list.
	///
	/// The form title is pulled from `form_id` if `form_title` is blank or missing.
	///
	public var formTitle: String?

	/// The name used to uniquely identify the form on the server.
	///
	/// `form_id`.
	///
	/// ID used in the XML and often needs to be unique.
	///
	/// The form id is pulled from the XLS file name if `form_id` is blank or missing.
	///
	public var formID: String?

	/// The version or revision of the form.
	///
	/// `version`.
	///
	/// String of up to 10 numbers that describes this revision.
	/// Revised form definitions must have numerically greater versions
	/// than previous ones. A common convention is to use strings of
	/// the form '`yyyymmddrr`'.
	///
	/// For example, `2017021501` is the 1st revision from Feb 15th, 2017.
	///
	public var version: String?

	/// The default language of the form
	///
	/// `default_language`.
	///
	/// If form uses multiple languages, this one sets which to use by default.
	///
	/// In localized forms, this sets which language should be used as
	/// the default. The same format as described for adding translations
	/// should be used, including the language code.
	///
	public var defaultLanguage: Survey.DatumLanguage?

	/// The style or theme of the form's question groups.
	///
	/// `style`.
	///
	/// Separate questions groups into pages (on Enketo). Switch to a different theme.
	///
	/// Allowed values: `pages`, `theme-grid`, `theme-formhub`.
	///
	public var style: Survey.Style?

	/// Specify form submission name
	///
	/// `instance_name`.
	///
	/// Allows user to create a dynamic naming convention for each submitted instance.
	///
	/// For example, `concat(${lname}, ‘-‘, ${fname}, ‘-‘, uuid())`.
	///
	/// In the settings worksheet, you can specify a unique name for
	/// each form submission using fields filled in by the user during
	/// the survey. On the settings worksheet, add a column
	/// called instance_name. Write in the expression that defines the
	/// unique form instance name using fields from the survey worksheet.
	///
	public var instanceName: String?

	/// Key required for encrypted forms.
	///
	/// `public_key`.
	///
	/// For encryption-enabled forms, this is where the public key
	/// is copied and pasted.
	///
	public var publicKey: String?

	/// Specific URL for uploading data, overrides default.
	///
	/// `submission_url`.
	///
	/// This url can be used to override the default server where
	/// finalized records are submitted to.
	///
	public var submissionURL: String?


	//
	public var languagesAvailable: Survey.LanguagesAvailable

	//
	public var items: [SurveyItem]

	//
	public var warnings: Survey.Warnings? {
		didSet {
			self.warnings = self.warnings?.nilIfVacant
		}
	}


	public init(
		formTitle: String?,
		formID: String?,
		version: String?,
		defaultLanguage: Survey.DatumLanguage?,
		style: Survey.Style?,
		instanceName: String?,
		publicKey: String?,
		submissionURL: String?,

		languagesAvailable: Survey.LanguagesAvailable,

		items: [SurveyItem],

		warnings: Survey.Warnings? = nil
	) {
		self.formTitle = formTitle
		self.formID = formID
		self.version = version
		self.defaultLanguage = defaultLanguage
		self.style = style
		self.instanceName = instanceName
		self.publicKey = publicKey
		self.submissionURL = submissionURL

		self.languagesAvailable = languagesAvailable

		self.items = items

		self.warnings = warnings?.nilIfVacant
	}

	//--------------------------------------------------

	/// Automatically detect `defaultLanguage`. It is `defaultLanguage` if
	/// present, otherwise, if `languagesAvailable.all` is not empty it is the
	/// first one, otherwise, it is `nil`.
	///
	public var autoDefaultLanguage: Survey.DatumLanguage? {
		defaultLanguage.flatMap { defaultLanguage in
			languagesAvailable.all.first { language in
				language.languageLabel == defaultLanguage.languageLabel
			}
		} ?? languagesAvailable.all.first
	}

	//--------------------------------------------------

	@available(*, deprecated, renamed: "formTitle")
	public var title: String? {
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


// MARK: - Extensions

extension Survey {

	public enum Style: String, Codable {
		case pages = "pages"
		case themeGrid = "theme-grid"
		case themeFormhub = "theme-formhub"
	}

	public struct Warnings: Codable {

		/// Warnings that are general and apply to the form as a whole.
		public var generalWarnings: [SurveyWarning]?

		/// Warnings that correspond to items (i.e. questions and groups).
		public var specificWarnings: [SurveyWarning]?


		public init(
			generalWarnings: [SurveyWarning]? = nil,
			specificWarnings: [SurveyWarning]? = nil
		) {
			self.generalWarnings = generalWarnings
			self.specificWarnings = specificWarnings
		}


		//
		public var isVacant: Bool {
			self.generalWarnings?.isEmpty ?? true
				&& self.specificWarnings?.isEmpty ?? true
		}

		//
		fileprivate var nilIfVacant: Self? {
			var s = self
			if s.generalWarnings?.isEmpty ?? true {
				s.generalWarnings = nil
			}
			if s.specificWarnings?.isEmpty ?? true {
				s.specificWarnings = nil
			}

			if s.isVacant {
				return nil
			} else {
				return s
			}
		}
	}

}

extension Survey {

    /// Whether any of this survey's groups and questions have "agegroup" data.
    public var hasAgeGroups: Bool {
        self.items.allItemsFlatMap
            .contains { item in
                item.ageGroup != nil
            }
    }

}

//--------------------------------------------------
