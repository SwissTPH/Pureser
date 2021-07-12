//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation


//@available(*, deprecated, renamed: "FormQuestionType")
public typealias SurveyQuestionType = FormQuestionType

/// Form Question Types.
/// Adapted to question types of the XLSForm standard.
///
/// These are put into the "type" column.
///
public enum FormQuestionType: RawRepresentable, Codable, CaseIterable {


	// MARK: - Unknown type

	case unknown


	// MARK: - XLSForm metadata types
	//
	// Meta questions.
	// These are hidden to the user, but otherwise work like regular questions.
	//
	// Meta questions types:

	/// Start date and time of the survey.
	///
	case start

	/// End date and time of the survey.
	///
	case end

	/// Day of the survey.
	///
	case today

	/// Unique client identifier. Can be user-reset.
	///
	/// - Syntax: `deviceid`.
	/// - Synonyms: `imei`.
	///
	case deviceid
	@available(*, deprecated, renamed: "deviceid")
	public static let deviceID: Self = .deviceid

	/// Phone number (if available).
	///
	/// - Syntax: `phonenumber`.
	/// - Synonyms: `phone_number`.
	///
	case phonenumber
	@available(*, deprecated, renamed: "phonenumber")
	public static let phoneNumber: Self = .phonenumber

	/// Username configured (if available).
	///
	case username

	/// Email address configured (if available).
	///
	case email

	/// Log enumerator behavior during data entry
	///
	case audit

	/// The geolocation when the survey was started.
	///
	/// Only available in ODK metadata types ?
	///
	/// The start-geopoint question type is used to capture a single
	/// geolocation in geopoint format when the survey is first started.
	/// Questions of type start-geopoint may be given any allowable name.
	/// Although it is possible to have more than one start-geopoint question
	/// in a form, all will have the same value.
	///
	case startGeopoint

	/// SIM serial
	///
	/// Only available in ODK metadata types ?
	///
	case simSerial

	/// Subscriber ID
	///
	case subscriberid
	@available(*, deprecated, renamed: "subscriberid")
	public static let subscriberID: Self = .subscriberID


	// MARK: - XLSForm question types
	//
	// Regular questions types:

	/// Integer (i.e., whole number) input.
	///
	case integer

	/// Decimal input.
	///
	case decimal

	/// Range input (including rating).
	///
	/// To restrict integer or decimal inputs to a specific range,
	/// you can use the range question. This question can be
	/// used with 3 optional space-separated
	/// parameters: start, end, and step in a parameters column.
	/// The default values are 0, 10, and 1 respectively.
	///
	case range

	/// Free text response.
	///
	case text

	/// Multiple choice question; only one answer can be selected.
	///
	/// - Syntax: `select_one [options]`
	///     - `select_one [choices] [or_other]`
	///     - `select_one [list_name] [or_other]`
	/// - Synonyms: `select one [options]`.
	///
	case select_one
	@available(*, deprecated, renamed: "select_one")
	public static let selectOne: Self = .select_one

	/// Multiple choice question; multiple answers can be selected.
	///
	/// - Syntax: `select_multiple [options]`
	///     - `select_multiple [choices] [or_other]`
	///     - `select_multiple [list_name] [or_other]`
	/// - Synonyms: `select multiple [options]`.
	///
	/// Examples:
	/// - `select_multiple pizza_toppings`
	/// - `select_multiple pizza_toppings or_other`
	///
	case select_multiple
	@available(*, deprecated, renamed: "select_multiple")
	public static let selectMultiple: Self = .select_multiple

	/// Multiple choice from file; only one answer can be selected.
	///
	/// `select_one_from_file [file]`
	///
	case select_one_from_file

	/// Multiple choice from file; multiple answers can be selected.
	///
	/// `select_multiple_from_file [file]`
	///
	case select_multiple_from_file

	/// Select one external.
	///
	/// `select_one_external [options]`
	///
	case select_one_external

	/// Rank question; order a list.
	///
	/// `rank [options]`
	///
	case rank

	/// Display a note on the screen, takes no input. Shorthand for type=text with readonly=true.
	///
	case note

	/// Collect a single GPS coordinate.
	///
	/// - Syntax: `geopoint`
	/// - Synonyms: `location`.
	///
	case geopoint

	/// Record a line of two or more GPS coordinates.
	///
	case geotrace

	/// Record a polygon of multiple GPS coordinates; the last point is the same as the first point.
	///
	case geoshape

	/// Date input.
	///
	case date

	/// Time input.
	///
	case time

	/// Accepts a date and a time input.
	///
	case dateTime

	/// Take a picture or upload an image file.
	///
	/// - Syntax: `image`
	/// - Synonyms: `photo`.
	///
	case image

	/// Take an audio recording or upload an audio file.
	///
	case audio

	/// Audio is recorded in the background while filling the form.
	///
	case backgroundAudio

	/// Take a video recording or upload a video file.
	///
	case video

	/// Generic file input (txt, pdf, xls, xlsx, doc, docx, rtf, zip)
	///
	case file

	/// Scan a barcode, requires the barcode scanner app to be installed.
	///
	case barcode

	/// Perform a calculation; see the Calculation section below.
	///
	case calculate
	@available(*, deprecated, renamed: "calculate")
	public static let calc: Self = .calculate

	/// Acknowledge prompt that sets value to "OK" if selected.
	///
	/// - Syntax: `acknowledge`.
	/// - Synonyms: `trigger`.
	///
	case acknowledge
	@available(*, deprecated, renamed: "acknowledge")
	public static let trigger: Self = .acknowledge

	/// A field with no associated UI element which can be used to store a constant
	///
	case hidden

	/// Adds a reference to an external XML data file
	///
	case xmlExternal


	// MARK: - XLSForm groups
	//
	// Groups contain one or more questions, or other nested groups,
	// which may loop (repeat).
	//
	// Group types:

	/// Sets the beginning of a group.
	///
	/// - Syntax: `begin_group`.
	/// - Synonyms: `begin group`.
	///
	case begin_group
	@available(*, deprecated, renamed: "begin_group")
	public static let beginGroup: Self = .begin_group

	/// Ends the group.
	///
	/// - Syntax: `end_group`.
	/// - Synonyms: `end group`.
	///
	case end_group
	@available(*, deprecated, renamed: "end_group")
	public static let endGroup: Self = .end_group

	/// Sets the beginning of a repeat group.
	///
	/// - Syntax: `begin_repeat`.
	/// - Undocumented synonyms: `begin repeat`.
	///
	case begin_repeat
	@available(*, deprecated, renamed: "begin_repeat")
	public static let beginRepeat: Self = .begin_repeat

	/// Ends the repeat group.
	///
	/// - Syntax: `end_repeat`.
	/// - Undocumented synonyms: `end repeat`.
	///
	case end_repeat
	@available(*, deprecated, renamed: "end_repeat")
	public static let endRepeat: Self = .end_repeat


	// MARK: - Categorisation

	//
	public static var regularQuestionTypes: [Self] {
		[
			.integer,
			.decimal,
			.range,
			.text,
			.select_one,
			.select_multiple,
			.select_one_from_file,
			.select_multiple_from_file,
			.select_one_external,
			.rank,
			.note,
			.geopoint,
			.geotrace,
			.geoshape,
			.date,
			.time,
			.dateTime,
			.image,
			.audio,
			.backgroundAudio,
			.video,
			.file,
			.barcode,
			.calculate,
			.acknowledge,
			.hidden,
			.xmlExternal,
		]
	}

	//
	public static var metaQuestionTypes: [Self] {
		[
			.start,
			.end,
			.today,
			.deviceid,
			.phonenumber,
			.username,
			.email,
			.audit,
			.startGeopoint,
			.simSerial,
			.subscriberid,
		]
	}

	//
	public static var questionGrouping: [Self] {
		[
			.begin_group,
			.end_group,
			.begin_repeat,
			.end_repeat,
		]
	}

	//
	public static var hiddenQuestionTypes: [Self] {
		metaQuestionTypes + [.calculate]
	}


	// MARK: - is...

	/// Whether it is a question type that needs options.
	///
	/// Matches these `enum` `case`s:
	/// - `.select_one`
	/// - `.select_multiple`
	/// - `.rank`
	/// - `.select_one_from_file`
	/// - `.select_multiple_from_file`
	///
	/// For example:
	/// - `select_one [options]`
	/// - `rank [options]`
	///
	public var isQuestionTypeWithOptions: Bool {
		switch self {
		case .select_one,
			 .select_multiple,
			 .rank,
			 .select_one_from_file,
			 .select_multiple_from_file:
			return true
		default:
			return false
		}
	}


	// MARK: - Info

	public var info: ItemInfo {
		switch self {
		case .unknown:
			return ItemInfo(
				item: .unknown,
				key: "unknown"
			)
		case .start:
			return ItemInfo(
				item: .start,
				key: "start"
			)
		case .end:
			return ItemInfo(
				item: .end,
				key: "end"
			)
		case .today:
			return ItemInfo(
				item: .today,
				key: "today"
			)
		case .deviceid:
			return ItemInfo(
				item: .deviceid,
				key: "deviceid",
				keySynonyms: ["imei"],
				undocumentedKeySynonyms: []
			)
		case .phonenumber:
			return ItemInfo(
				item: .phonenumber,
				key: "phonenumber",
				keySynonyms: ["phone_number"],
				undocumentedKeySynonyms: []
			)
		case .username:
			return ItemInfo(
				item: .username,
				key: "username"
			)
		case .email:
			return ItemInfo(
				item: .email,
				key: "email"
			)
		case .audit:
			return ItemInfo(
				item: .audit,
				key: "audit"
			)
		case .startGeopoint:
			return ItemInfo(
				item: .startGeopoint,
				key: "start-geopoint"
			)
		case .simSerial:
			return ItemInfo(
				item: .simSerial,
				key: "simserial"
			)
		case .subscriberid:
			return ItemInfo(
				item: .subscriberid,
				key: "subscriberid"
			)
		case .integer:
			return ItemInfo(
				item: .integer,
				key: "integer",
				keySynonyms: [],
				undocumentedKeySynonyms: ["int"]
			)
		case .decimal:
			return ItemInfo(
				item: .decimal,
				key: "decimal"
			)
		case .range:
			return ItemInfo(
				item: .range,
				key: "range"
			)
		case .text:
			return ItemInfo(
				item: .text,
				key: "text"
			)
		case .select_one:
			return ItemInfo(
				item: .select_one,
				key: "select_one",
				keySynonyms: ["select one"],
				undocumentedKeySynonyms: []
			)
		case .select_multiple:
			return ItemInfo(
				item: .select_multiple,
				key: "select_multiple",
				keySynonyms: ["select multiple"],
				undocumentedKeySynonyms: []
			)
		case .select_one_from_file:
			return ItemInfo(
				item: .select_one_from_file,
				key: "select_one_from_file"
			)
		case .select_multiple_from_file:
			return ItemInfo(
				item: .select_multiple_from_file,
				key: "select_multiple_from_file"
			)
		case .select_one_external:
			return ItemInfo(
				item: .select_one_external,
				key: "select_one_external"
			)
		case .rank:
			return ItemInfo(
				item: .rank,
				key: "rank"
			)
		case .note:
			return ItemInfo(
				item: .note,
				key: "note"
			)
		case .geopoint:
			return ItemInfo(
				item: .geopoint,
				key: "geopoint",
				keySynonyms: ["location"],
				undocumentedKeySynonyms: []
			)
		case .geotrace:
			return ItemInfo(
				item: .geotrace,
				key: "geotrace"
			)
		case .geoshape:
			return ItemInfo(
				item: .geoshape,
				key: "geoshape"
			)
		case .date:
			return ItemInfo(
				item: .date,
				key: "date"
			)
		case .time:
			return ItemInfo(
				item: .time,
				key: "time"
			)
		case .dateTime:
			return ItemInfo(
				item: .dateTime,
				key: "dateTime",
				keySynonyms: ["datetime"],
				undocumentedKeySynonyms: []
			)
		case .image:
			return ItemInfo(
				item: .image,
				key: "image",
				keySynonyms: ["photo"],
				undocumentedKeySynonyms: []
			)
		case .audio:
			return ItemInfo(
				item: .audio,
				key: "audio"
			)
		case .backgroundAudio:
			return ItemInfo(
				item: .backgroundAudio,
				key: "background-audio"
			)
		case .video:
			return ItemInfo(
				item: .video,
				key: "video"
			)
		case .file:
			return ItemInfo(
				item: .file,
				key: "file"
			)
		case .barcode:
			return ItemInfo(
				item: .barcode,
				key: "barcode"
			)
		case .calculate:
			return ItemInfo(
				item: .calculate,
				key: "calculate"
			)
		case .acknowledge:
			return ItemInfo(
				item: .acknowledge,
				key: "acknowledge",
				keySynonyms: ["trigger"],
				undocumentedKeySynonyms: []
			)
		case .hidden:
			return ItemInfo(
				item: .hidden,
				key: "hidden"
			)
		case .xmlExternal:
			return ItemInfo(
				item: .xmlExternal,
				key: "xml-external"
			)
		case .begin_group:
			return ItemInfo(
				item: .begin_group,
				key: "begin_group",
				keySynonyms: ["begin group"],
				undocumentedKeySynonyms: []
			)
		case .end_group:
			return ItemInfo(
				item: .end_group,
				key: "end_group",
				keySynonyms: ["end group"],
				undocumentedKeySynonyms: []
			)
		case .begin_repeat:
			return ItemInfo(
				item: .begin_repeat,
				key: "begin_repeat",
				keySynonyms: [],
				undocumentedKeySynonyms: ["begin repeat"]
			)
		case .end_repeat:
			return ItemInfo(
				item: .end_repeat,
				key: "end_repeat",
				keySynonyms: [],
				undocumentedKeySynonyms: ["end repeat"]
			)
		}
	}


	// MARK: - key & keySynonyms

	/// The prominent key.
	public var key: String {
		self.info.key
	}

	/// All key synonyms (excluding the prominent key itself).
	public var keySynonyms: [String] {
		self.info.allKeySynonyms
	}

	/// All possible keys (includes the prominent key and all key synonyms).
	public var allPossibleKeys: [String] {
		self.info.allPossibleKeys
	}


	// MARK: - struct ItemInfo

	public struct ItemInfo {
		public var key: String
		public var keySynonyms: [String]
		public var undocumentedKeySynonyms: [String]

		fileprivate init(
			item: SurveyQuestionType,
			key: String,
			keySynonyms: [String] = [],
			undocumentedKeySynonyms: [String] = []
		) {
			self.key = key
			self.keySynonyms = keySynonyms
			self.undocumentedKeySynonyms = undocumentedKeySynonyms
		}

		public var allKeySynonyms: [String] {
			keySynonyms + undocumentedKeySynonyms
		}

		public var allPossibleKeys: [String] {
			[key] + keySynonyms + undocumentedKeySynonyms
		}
	}


	// MARK: - init

	public var rawValue: String {
		self.key
	}

	/// Initialize from any possible key or synonym.
	/// Note: *type-options* (e.g. `list_name`) should not be included in the input `String`.
	///
	/// This overrides the default `init?(rawValue: String)`.
	///
	/// If there is no value of the type that corresponds with the specified raw value, this initializer returns nil.
	///
	/// - Parameters:
	///     - rawValue: The raw value to use for the new instance.
	///
	public init?(/*fromAnyPossibleKey */rawValue: String) {
		guard let value = FormQuestionType.allCases
				.first(where: { typeCase in typeCase.info.allPossibleKeys.contains(rawValue) })
		else {
			return nil
		}
		self = value
	}


	// MARK: -
}
