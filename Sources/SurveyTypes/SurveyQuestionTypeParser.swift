//
//  File.swift
//  
//
//  Created by R. Makhoul on 20/03/2021.
//

import Foundation
//import SurveyTypes


// MARK: interface

//
extension FormQuestionTypeAndOptions {

	/// Initialize using the input (which is an XLSForm question type as in the excel file).
	///
	/// The input will be parsed and then the construct will be initialized.
	///
	/// If there is no value of the type that corresponds with the specified
	/// input-`String`, this initializer returns nil.
	///
	/// - Parameters:
	///     - input: The XLSForm question type as in the excel file.
	///
	public init?(fromString input: String) {
		guard let x = try? parseFormQuestionTypeAndOptions(from: input) else {
			return nil
		}
		self = x
	}
}

//
//@available(*, unavailable)
extension FormQuestionTypeAndOptions: ExpressibleByStringLiteral {

	@available(*, deprecated)
	public init(stringLiteral value: String) {
		if let x = try? parseFormQuestionTypeAndOptions(from: value) {
			self = x
		} else {
			self.init(type: .unknown, options: .init(unknownType: value))
		}
	}
}


//
private enum FormQuestionTypeParsingError: Error {
	case empty
	case invalid
}


// MARK: implementation

/// Parse the input (which is an XLSForm question type as in the excel file).
///
/// - Parameters:
///     - input: The XLSForm question type as in the excel file.
///
private func parseFormQuestionTypeAndOptions(from input: String) throws -> FormQuestionTypeAndOptions {

	var input = input.trimmingCharacters(in: .whitespacesAndNewlines)

	guard !input.isEmpty else {
		throw FormQuestionTypeParsingError.empty
	}

	// Replace tabs with spaces.
	input = input.replacingOccurrences(of: "\t", with: " ")

	// Remove double spaces.
	// rawValue = try rawValue.replacingMatches(regexPattern: #"\s+"#, withTemplate: " ")
	while input.contains("  ") {
		input = input.replacingOccurrences(of: "  ", with: " ")
	}

	//--------------------------------------------------

	//
	let type: FormQuestionType
	var options: FormQuestionTypeOptions? = nil

	//--------------------------------------------------

	// Find the question's type.
	guard let h = findQuestionTypeAndRawValue(from: input) else {
		throw FormQuestionTypeParsingError.invalid
	}
	type = h.type

	// The rest of the input is now assigned as `rawOptions`.
	//
	// Trimming the whitespaces is crucial.
	// Becuase if `input` = "select_one yes_no",
	// and `rawOptions` = String(input[h.rawValue.endIndex...])
	// then `rawOptions` is now " yes_no" (notice the leading space).
	let rawOptions: String = String(input[h.rawValue.endIndex...]).trimmingCharacters(in: .whitespacesAndNewlines)

	//--------------------------------------------------

	// Find the question's type's options.
	if type.isQuestionTypeWithOptions {
		guard !rawOptions.isEmpty else {
			throw FormQuestionTypeParsingError.invalid
		}

		var optionsArray = ArraySlice(rawOptions.split(separator: " "))

		if [.select_one, .select_multiple].contains(type) {
			// Requird typeOption.
			guard let listName = optionsArray.popFirst().flatMap(String.init) else {
				throw FormQuestionTypeParsingError.invalid
			}
			// Optional typeOption.
			let orOther = !optionsArray.isEmpty && optionsArray.popLast() == "or_other" ? true : false

			// Initialize typeOptions.
			options = .init(
				listName: listName,
				orOther: orOther
			)
		} else if [.rank].contains(type) {
			// Requird typeOption.
			guard let listName = optionsArray.popFirst().flatMap(String.init) else {
				throw FormQuestionTypeParsingError.invalid
			}

			// Initialize typeOptions.
			options = .init(
				listName: listName
			)
		} else if [.select_one_from_file, .select_multiple_from_file].contains(type) {
			// Requird typeOption.
			guard let file = optionsArray.popFirst().flatMap(String.init) else {
				throw FormQuestionTypeParsingError.invalid
			}

			// Initialize typeOptions.
			options = .init(
				file: file
			)
		}
	}

	//--------------------------------------------------

	//
	return .init(type: type, options: options)
}

/// This struct holds the question's type `enum` `case` and rawValue (which is the question's type's key or synonym used).
private struct QuestionTypeAndRawValue {
	/// The question's type's key or synonym.
	var rawValue: FormQuestionType.RawValue
	/// The question's type `enum` `case` that represent the key or the synonym.
	var type: FormQuestionType
}

/// Finds the question's type `enum` `case` and the specific rawValue (question's type's key or synonym) that
/// was used to find the question's type enum case.
/// Returns `nil` if no matches were found.
///
/// - Parameters:
///     - input: The XLSForm question type as in the excel file.
///
private func findQuestionTypeAndRawValue(from input: String) -> QuestionTypeAndRawValue? {
	FormQuestionType.allCases
		.flatMap { (typeCase: FormQuestionType) in
			typeCase.info.allPossibleKeys.map { (possibleRawValue: String) in
				QuestionTypeAndRawValue(rawValue: possibleRawValue, type: typeCase)
			}
		}
		.sorted { (a: QuestionTypeAndRawValue, b: QuestionTypeAndRawValue) in
			// Crucial! Greater count comes first.
			// It must be like this for the `.first {...}` after this `.sorted {...}` to work properly.
			//
			// This way, the rawValue "end group" will be tested in before "end",
			// otherwise, if "end" would test first - it would
			// match "end", "end_group", "end group", "end_xyz", etc.
			a.rawValue.count > b.rawValue.count
		}
		.first { (x: QuestionTypeAndRawValue) in
			x.rawValue == input ||
				x.rawValue.count <= input.count
				&& x.rawValue == input[..<x.rawValue.endIndex]
				// This is to prevent matching e.g.
				// "select_oneYES_NO" (notice the missing whitespace),
				// which could have been matched by the previous condition.
				//
				// Both these condtions (above & below comment), could have been
				// done in one condition:
				// x.rawValue + " " == input[...x.rawValue.endIndex]
				// But having them separated is clearer.
				&& input[x.rawValue.endIndex] == " "
		}
}
