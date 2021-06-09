//
//  File.swift
//  
//
//  Created by R. Makhoul on 29/01/2021.
//

import Foundation
//import PrintMore
import HTML
import SurveyTypes


// MARK: - RelevanceParser

struct RelevanceParser {

	/// A helper handler for processing relevance for multiple languages.
	///
	///
	static func relevanceHelper(
		unprocessedRelevance: String,
		referenceSurveyItems: [SurveyItem],
		datumLanguages: [Survey.DatumLanguage]
	)
	throws -> (final: Survey.LocalizedData, stepByStep: [Survey.LocalizedData]) {

		var stepByStep: [Survey.LocalizedData] = []
		var final: Survey.LocalizedData = []

		for datumLanguage: Survey.DatumLanguage in datumLanguages {

			let t = try RelevanceParser.relevanceHelper(
				unprocessedRelevance: unprocessedRelevance,
				referenceSurveyItems: referenceSurveyItems,
				datumLanguage: datumLanguage
			)

			stepByStep.append(
				t.stepByStep.map { step in
					Survey.LocalizedDatum(datumLanguage: datumLanguage, translation: step)
				}
			)

			final.append(
				Survey.LocalizedDatum(datumLanguage: datumLanguage, translation: t.final)
			)
		}

		return (final: final, stepByStep: stepByStep)
	}

	/// A helper handler for processing relevance for one language.
	///
	///
	private static func relevanceHelper(
		unprocessedRelevance: String,
		referenceSurveyItems: [SurveyItem],
		datumLanguage: Survey.DatumLanguage
	)
	throws -> (final: String, stepByStep: [String]) {

		var _r = unprocessedRelevance

		var stepByStep: [String] = []
		stepByStep.append(_r)

		//--------------------------------------------------

		if _r.isEmpty {
			_r = "Always relevant."
			return (final: _r, stepByStep: stepByStep)
		}

		if _r == "true()" {
			_r = "Always relevant."
			return (final: _r, stepByStep: stepByStep)
		}

		//--------------------------------------------------

		/// Question of type `.calc` and with `id` (a.k.a `name` in the xlsx files) starting with `"is"`
		/// to be treated as boolean questions in the relevance of other questions.
		let questionOfTypeCalcWithPatternIsAsTypeBoolean: Bool = true


		/// Whether the language is English or not.
		let isEnglish: Bool = ["english", "(en)"].contains { datumLanguage.languageLabel.lowercased().contains($0) }
		/// Use symbols (where possible) instead of linguistic representation.
		let useSymbols: Bool = false || !isEnglish

		//--------------------------------------------------

		let rcgQuestion = capturingGroup(named: "question") { #"\$\{(?:.*?)\}"# }
		let rcgQuestion2 = capturingGroup() { #"\$\{(?:.*?)\}"# }
		let rcgQuestionID = #"\$\{([^{]+?)\}"#

		let rcgSelectionAnswer = capturingGroup(named: "answer") { #"'(?:.*?)'"# }

		/// Regex spaces (lazy, as little as possible)
		let _s = #"\s*?"#

		//--------------------------------------------------

		// MARK: preliminaryPairsBatch

		// Change different styles into one and make them generally easier to deal with.
		let preliminaryPairsBatch: [_TRP] = [

			/// E.g. match `selected(${Id12345}, 'yes')` and change it into `${Id12345} = 'yes'`.
			_TRP(
				target: #"selected\(\#(_s)\#(rcgQuestion)\#(_s),\#(_s)\#(rcgSelectionAnswer)\#(_s)\)"#,
				replacement: #"$1 = $2"#
			),

			/// E.g. match `not(${Id12345} = 'yes')` and change it into `${Id12345} != 'yes'`.
			_TRP(
				target: #"not\(\#(_s)\#(rcgQuestion) = \#(rcgSelectionAnswer)\#(_s)\)"#,
				replacement: #"$1 != $2"#
			),

			/// E.g. match `count-selected(${Id12345})>1` and change it into `${Id12345} selected> 1`.
			_TRP(
				target: #"count-selected\(\#(_s)\#(rcgQuestion)\#(_s)\)\#(_s)>\#(_s)(\d+)"#,
				replacement: #"$1 selected> $2"#
			),

			/// E.g. match `string-length(${Id12345}) = 0)` and change it into `${Id12345} length= 0`.
			_TRP(
				target: #"string-length\(\#(_s)\#(rcgQuestion)\#(_s)\)\#(_s)=\#(_s)(\d+)"#,
				replacement: #"$1 length= $2"#
			),
		]

		for pair in preliminaryPairsBatch {
			_r = try _r.replacingMatches(
				regexPattern: pair.target,
				withTemplate: pair.replacement,
				options: .caseInsensitive
			)

			stepByStep.append(_r)
		}

		//--------------------------------------------------

		// MARK: logicalOperatorsPairsBatch

		let logicalOperatorsPairsBatch: [_TRP] = [
			_TRP(
				target: "and",
				replacement: (useSymbols) ? "&&".htmlEscape() : "AND"
			),
			_TRP(
				target: "or",
				replacement: (useSymbols) ? "||".htmlEscape() : "OR"
			),
		]
		for pair in logicalOperatorsPairsBatch {
			_r = _r.replacingOccurrences(
				of: #"\s+"# + pair.target + #"\s+"#,
				with: "{{ " + pair.replacement + " }}",
				options: [.regularExpression, .caseInsensitive, .diacriticInsensitive]
			)
		}
		stepByStep.append(_r)

		//--------------------------------------------------

		// MARK: combinationPairsBatch

		///
		/// Change this:
		/// `${Id12345} = 'NaN' or string-length(${Id12345}) = 0`
		/// Or this:
		/// `${Id12345} = 'NaN'{{ OR }}${Id12345} length= 0`
		/// Into this:
		/// `${Id12345} =∅`
		///
		_r = try _r.replacingMatches(
			regexPattern: #"\#(rcgQuestion2)\#(_s)=\#(_s)'NaN'\{\{ OR \}\}\1 length= 0"#,
			withTemplate: #"$1 =∅"#,
			options: .caseInsensitive
		)
		stepByStep.append(_r)

		//--------------------------------------------------

		// MARK: compositeComparisonOperatorsPairsBatch

		// The `compositeComparisonOperatorsPairsBatch` must be before
		// the `basicComparisonOperatorsPairsBatch`, because the former is more exclusive,
		// and the latter is less exclusive.
		// E.g. If `=` is matched and replaced before `length=` it is a problem
		// because then `length=` will not be matched and replaced correctly.
		// So, the most exclusive target-pattern should be matched and replace first.
		//
		let compositeComparisonOperatorsPairsBatch: [_TRP] = [
			_TRP(
				target: #" selected> ([2-9]|[1-9]\d{1,})"#,
				replacement: #" was answered with more than $1 options"#
			),
			_TRP(
				target: #" selected> ([1]{1,1})"#,
				replacement: #" was answered with more than 1 option"#
			),
			_TRP(
				target: #" length= ([0]|[2-9]|[1-9]\d{1,})"#,
				replacement: #" was answered with $1 charecters"#
			),
			_TRP(
				target: #" length= ([1]{1,1})"#,
				replacement: #" was answered with 1 charecter"#
			),
			_TRP(
				target: #" =∅"#,
				replacement: " was NOT answered"
			),
		]
		for pair in compositeComparisonOperatorsPairsBatch {
			_r = try _r.replacingMatches(
				regexPattern: pair.target,
				withTemplate: pair.replacement,
				options: .caseInsensitive
			)

			stepByStep.append(_r)
		}

		//--------------------------------------------------

		// MARK: basicComparisonOperatorsPairsBatch

		// Replace/substitue the custom operators with linguistic representation.
		//
		// The order of the array matters, it is ordered from most to least exclusive.
		// E.g. If `=` is matched and replaced before `!=` or `>=` or `<=` it is a problem
		// because then `!=` or `>=` or `<=` will not be matched and replaced correctly.
		// So, the most exclusive target-pattern should be matched and replace first.
		//
		let basicComparisonOperatorsPairsBatch: [_TRP] = [
			_TRP(
				target: ">=",
				replacement: (useSymbols) ? "≥".htmlEscape() : "is greater than or equal with"
			),
			_TRP(
				target: ">",
				replacement: (useSymbols) ? ">".htmlEscape() : "is greater than"
			),
			_TRP(
				target: "<=",
				replacement: (useSymbols) ? "≤".htmlEscape() : "is less than or equal with"
			),
			_TRP(
				target: "<",
				replacement: (useSymbols) ? "<".htmlEscape() : "is less than"
			),
			_TRP(
				target: "!=",
				replacement: (useSymbols) ? "≠".htmlEscape() : "was NOT answered with"
			),
			_TRP(
				target: "=",
				replacement: (useSymbols) ? "=".htmlEscape() : "was answered with"
			),
		]
		for pair in basicComparisonOperatorsPairsBatch {
			_r = _r.replacingOccurrences(
				of: #"\s*"# + pair.target + #"\s*"#,
				with: " " + pair.replacement + " ",
				options: [.regularExpression, .caseInsensitive, .diacriticInsensitive]
			)

			stepByStep.append(_r)
		}

		//--------------------------------------------------

		// MARK: parentheses replacing

		_r = try _r.replaceMatches(regexPattern: #"\s*(\(|\))\s*"#, replacement: { match in

			let capturedGroup = String(match.values[1] ?? "")

			return nodeContainer {
				%span(class: "relevance-precondition") {
					if capturedGroup == ")" { "&nbsp;" }
					%span(class: "relevance-segment rsg-lp") {
						capturedGroup.spacesToNBSP
					}%
					if capturedGroup == "(" { "&nbsp;" }
				}%
			}.renderAsString()
		})
		stepByStep.append(_r)

		//--------------------------------------------------

		// MARK: Substitue actual question

		// Replace/substitue questions string name ID with actual question
		// and its answer name ID with actual answer.
		_r = try _r.replaceMatches(regexPattern: #"\$\{([^{]+?)\} ([^{']+?) '([^']+?)'"#, replacement: { match in

			let capturedQuestionNameID = String(match.values[1] ?? "")
			let capturedOperator = String(match.values[2] ?? "")
			let capturedQuestionAnswerNameID = String(match.values[3] ?? "")

			//--------------------------------------------------

			//
			let _question: SurveyQuestion? = referenceSurveyItems.lazy.allQuestionsFlatMap.lazy.first {
				(question: SurveyQuestion) in

				return question.name == capturedQuestionNameID
			}
			//
			guard let question = _question else {

				return nodeContainer {
					%span(class: "relevance-precondition") {
						%span(class: "relevance-segment rsg-nf") {
							#"Question "\#(capturedQuestionNameID)" not found;"#.spacesToNBSP
						}%
						%span(class: "relevance-segment rsg-co") {
							capturedOperator.spacesToNBSP
						}%
						%span(class: "relevance-segment rsg-nf") {
							#"Answer "\#(capturedQuestionAnswerNameID)" not found;"#.spacesToNBSP
						}%
					}%
				}.renderAsString()
			}

			//
			if [SurveyQuestionType.select_one, .select_multiple, .rank].contains(question.type) {

				//
				let _answer: SurveySelectionQuestionAnswer? = question.answers.lazy.first {
					(selectionAnswer: SurveySelectionQuestionAnswer) in

					selectionAnswer.answerID == capturedQuestionAnswerNameID
				}

				//
				return nodeContainer {
					%span(class: "relevance-precondition") {
						%span(class: "relevance-segment rsg-qs") {
							(question.label.firstWhere(datumLanguage)?.translation
								?? #"Question "\#(capturedQuestionNameID)" translation not found;"#).spacesToNBSP
						}%
						%span(class: "relevance-segment rsg-co") {
							capturedOperator.spacesToNBSP
						}%
						if let answer = _answer {
							%span(class: "relevance-segment rsg-as") {
								(answer.answerLabel.firstWhere(datumLanguage)?.translation
									?? #"Answer "\#(capturedQuestionAnswerNameID)" translation not found;"#).spacesToNBSP
							}%
						} else {
							%span(class: "relevance-segment rsg-nf") {
								#"Answer "\#(capturedQuestionAnswerNameID)" not found;"#.spacesToNBSP
							}%
						}
					}%
				}.renderAsString()

			}
			//
            else if questionOfTypeCalcWithPatternIsAsTypeBoolean && question.type == .calculate && question.name.lowercased().hasPrefix("is") && ["0", "1"].contains(capturedQuestionAnswerNameID) {

				//
				return nodeContainer {
					%span(class: "relevance-precondition") {
						%span(class: "relevance-segment rsg-qs") {
							(question.label.firstWhere(datumLanguage)?.translation ?? #"Question "\#(capturedQuestionNameID)" translation not found;"#).spacesToNBSP
						}%
						%span(class: "relevance-segment rsg-co") {
							"is".spacesToNBSP
						}%
						%span(class: "relevance-segment rsg-as") {
							(capturedQuestionAnswerNameID == "1" ? "True" : "False").spacesToNBSP
						}%
					}%
				}.renderAsString()

			}
			//
			else {

				//
				return nodeContainer {
					%span(class: "relevance-precondition") {
						%span(class: "relevance-segment rsg-qs") {
							(question.label.firstWhere(datumLanguage)?.translation ?? #"Question "\#(capturedQuestionNameID)" translation not found;"#).spacesToNBSP
						}%
						%span(class: "relevance-segment rsg-co") {
							capturedOperator.spacesToNBSP
						}%
						%span(class: "relevance-segment rsg-as") {
							#"\#(capturedQuestionAnswerNameID)"#.spacesToNBSP
						}%
					}%
				}.renderAsString()

			}
		})
		stepByStep.append(_r)

		// Replace/substitue questions string name ID with actual question
		_r = try _r.replaceMatches(regexPattern: #"\$\{([^{]+?)\}(?:\s([^<>{}'()]*))?"#, replacement: { match in

			let capturedQuestionNameID = String(match.values[1] ?? "")
			let capturedTailpiece = String(match.values[2] ?? "")

			//--------------------------------------------------

			//
			let _question: SurveyQuestion? = referenceSurveyItems.lazy.allQuestionsFlatMap.lazy.first {
				(question: SurveyQuestion) in

				return question.name == capturedQuestionNameID
			}
			//
			guard let question = _question else {

				return nodeContainer {
					%span(class: "relevance-precondition") {
						%span(class: "relevance-segment rsg-nf") {
							#"Question "\#(capturedQuestionNameID)" not found;"#.spacesToNBSP
						}%
						if !capturedTailpiece.isEmpty {
							%span(class: "relevance-segment rsg-tp") {
								capturedTailpiece.spacesToNBSP
							}%
						}
					}%
				}.renderAsString()
			}

			//--------------------------------------------------

			//
			return nodeContainer {
				%span(class: "relevance-precondition") {
					%span(class: "relevance-segment rsg-qs") {
						(question.label.firstWhere(datumLanguage)?.translation
							?? #"Question "\#(capturedQuestionNameID)" translation not found;"#).spacesToNBSP
					}%
					if !capturedTailpiece.isEmpty {
						%span(class: "relevance-segment rsg-tp") {
							capturedTailpiece.spacesToNBSP
						}%
					}
				}%
			}.renderAsString()
		})
		stepByStep.append(_r)

		//--------------------------------------------------

		// MARK: logicalOperatorsPairsBatch again

		for pair in logicalOperatorsPairsBatch {
			if useSymbols {
				_r = _r.replacingOccurrences(
					of: #"{{ "# + pair.replacement + #" }}"#,
					with: { () -> String in

						let capturedOperator = pair.replacement

						return nodeContainer {
							%span(class: "relevance-precondition") {
								" "
								%span(class: "relevance-segment rsg-lo") {
									("&nbsp;" + capturedOperator + "&nbsp;").spacesToNBSP
								}%
								" "
							}%
						}.renderAsString()
					}(),
					options: [.caseInsensitive, .diacriticInsensitive]
				)
			} else {
				_r = try _r.replaceMatches(regexPattern: #"\{\{\s("# + pair.replacement + #")\s\}\}"#, replacement: { match in

					let capturedOperator = String(match.values[1] ?? "")

					return nodeContainer {
						%span(class: "relevance-precondition") {
							" "
							%span(class: "relevance-segment rsg-lo") {
								("&nbsp;" + capturedOperator + "&nbsp;").spacesToNBSP
							}%
							" "
						}%
					}.renderAsString()
				})
			}
		}
		stepByStep.append(_r)

		//--------------------------------------------------

		// MARK: Add dot

		// Insert a dot in the end, if not present already.
		if _r.last != "." {
			_r = _r + "."
		}

		//--------------------------------------------------

		return (final: _r, stepByStep: stepByStep)
	}

	///
	///
	///
}


//--------------------------------------------------


// MARK: - some helpers

fileprivate struct _TRP {
	var target: String
	var replacement: String
}

//--------------------------------------------------

fileprivate func uncapturingGroup(pattern: () -> String) -> String {
	return "(?:" + pattern() + ")"
}

fileprivate func capturingGroup(named capturingGroupName: String? = nil, pattern: () -> String) -> String {
	if let capturingGroupName = capturingGroupName {
		return "(" + ( "?<"  + capturingGroupName + ">" ) + pattern() + ")"
	} else {
		return "(" + pattern() + ")"
	}
}

//--------------------------------------------------

fileprivate extension String {

	var spacesToNBSP: String {
		false ? self.replacingOccurrences(of: " ", with: "&nbsp;") : self
	}

	func htmlEscape() -> String {
		self
			.replacingOccurrences(of: "&", with: "&amp;") // This must be first.
			.replacingOccurrences(of: "<", with: "&lt;")
			.replacingOccurrences(of: ">", with: "&gt;")
			.replacingOccurrences(of: "\"", with: "&quot;")
			.replacingOccurrences(of: "'", with: "&apos;")
	}
}


//--------------------------------------------------


extension Array where Element == Survey.LocalizedDatum {

	/// Filters and returns only the common one.
	fileprivate func firstWhere(_ datumLanguage: Survey.DatumLanguage) -> Survey.LocalizedDatum? {
		self.first { (localizedDatum: Survey.LocalizedDatum) in
			localizedDatum.datumLanguage == datumLanguage
		}
	}

}

//--------------------------------------------------
