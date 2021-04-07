//
//  File.swift
//  
//
//  Created by R. Makhoul on 19/03/2021.
//

import Foundation


//
public struct FormQuestionTypeAndOptions: Codable {
	public var type: FormQuestionType
	public var options: FormQuestionTypeOptions?

	public init(
		type: FormQuestionType,
		options: FormQuestionTypeOptions? = nil
	) {
		self.type = type
		self.options = options
	}
}

extension FormQuestionTypeAndOptions: Equatable { }

extension FormQuestionTypeAndOptions: CustomStringConvertible {
	public var description: String {
		var o: String = self.type.rawValue

		if type.isQuestionTypeWithOptions {
			if [.select_one, .select_multiple, .rank].contains(self.type), let listName = self.options?.listName {
				o += " " + listName
			} else if [.select_one_from_file, .select_multiple_from_file].contains(self.type), let file = self.options?.file {
				o += " " + file
			}

			if [.select_one, .select_multiple].contains(self.type), let orOther = self.options?.orOther, orOther {
				o += " or_other"
			}
		}

		return o
	}
}


//
public struct FormQuestionTypeOptions: Codable {

	/// The list name of the choices.
	///
	/// Applicable to question types (i.e. `case`s of `FormQuestionType` `enum`):
	/// - `.select_one`
	/// - `.select_multiple`
	/// - `.rank`
	///
	/// Syntax:
	/// - `select_one [list_name]`
	/// - `select_multiple [list_name]`
	/// - `rank [list_name]`
	///
	/// Examples (unprocessed question's type => the value):
	/// - `select_one yes_no` ➡️ `listName = "yes_no"`
	/// - `select_multiple a_b_c_d` ➡️ `listName = "a_b_c_d"`
	/// - `rank list_name` ➡️ `listName = "list_name"`
	/// - `text` ➡️ `listName = nil`
	///
	public var listName: String?

	/// The option of displaying "or other" to "select ..." type questions.
	/// The value is `true` if "or_other" is present and `false` otherwise.
	///
	/// Applicable to question types (i.e. `case`s of `FormQuestionType` `enum`):
	/// - `.select_one`
	/// - `.select_multiple`
	///
	/// Syntax:
	/// - `select_one list_name [or_other]`
	/// - `select_multiple list_name [or_other]`
	///
	/// Examples (unprocessed question's type => the value):
	/// - `select_one yes_no` ➡️ `orOther = false`
	/// - `select_one yes_no or_other` ➡️ `orOther = true`
	/// - `select_multiple a_b_c_d` ➡️ `orOther = false`
	/// - `select_multiple a_b_c_d or_other` ➡️ `orOther = true`
	/// - `text` ➡️ `orOther = nil`
	///
	public var orOther: Bool?

	/// The file used for "select ... from file" type questions.
	///
	/// Applicable to question types (i.e. `case`s of `FormQuestionType` `enum`):
	/// - `.select_one_from_file`
	/// - `.select_multiple_from_file`
	///
	/// Syntax:
	/// - `select_one_from_file [file]`
	/// - `select_multiple_from_file [file]`
	///
	/// Examples (unprocessed question's type => the value):
	/// - `select_one_from_file listfile.xml` ➡️ `file = "listfile.xml"`
	/// - `select_one_from_file listfile.csv` ➡️ `file = "listfile.csv"`
	/// - `select_multiple_from_file listfile.xml` ➡️ `file = "listfile.xml"`
	/// - `select_multiple_from_file listfile.csv` ➡️ `file = "listfile.csv"`
	/// - `text` ➡️ `file = nil`
	///
	public var file: String?

	public init(
		listName: String? = nil,
		orOther: Bool? = nil,
		file: String? = nil
	) {
		self.listName = listName
		self.orOther = orOther
		self.file = file
	}
}

extension FormQuestionTypeOptions: Equatable { }
