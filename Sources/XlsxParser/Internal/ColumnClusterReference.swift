//
//  File.swift
//  
//
//  Created by R. Makhoul on 27/01/2021.
//

import Foundation
import CoreXLSX
import struct SurveyTypes.Survey

//
struct ColumnClusterReference {
	var clusterColumnsMetadata: [ClusterColumnMetadata]
}

//
struct ClusterColumnMetadata {
	var titleTail: String
	var reference: CoreXLSX.ColumnReference

	@available(*, deprecated)
	var titleTailOnlyLetters: String {
		String(
			self.titleTail
				.unicodeScalars
				// Keep only letter characters in the string.
				// Remove all non-letters characters from the string.
				.filter(CharacterSet.letters.contains)
		).lowercased()
	}

	var titleTailOnlyAlphanumerics: String {
		String(
			self.titleTail
				.unicodeScalars
				// Keep only letter characters in the string.
				// Remove all non-alphanumeric characters from the string.
				.filter(CharacterSet.alphanumerics.contains)
		).lowercased()
	}

	var titleTailAsStringID: String {
		(
			(!(titleTailOnlyAlphanumerics.first?.isLetter ?? false) ? "l" : "")
				+ titleTailOnlyAlphanumerics
		).lowercased()
	}

}

// MARK: - Extensions

//
internal extension Array where Element == Optional<ColumnClusterReference> {

	//
	func toUniquelyMergedClusterColumnMetadatas() -> [ClusterColumnMetadata] {
		let columnClusterReferences: [ColumnClusterReference?] = self

		var uniquelyMergedArray: [ClusterColumnMetadata] = []

		for columnClusterReference in columnClusterReferences {
			uniquelyMergedArray +=
				columnClusterReference?.clusterColumnsMetadata.filter { (candidate: ClusterColumnMetadata) in
					uniquelyMergedArray.map { (alreadyAppended: ClusterColumnMetadata) in
						alreadyAppended.titleTail
					}.contains(candidate.titleTail) == false
				} ?? []
		}

		return uniquelyMergedArray
	}

}

//
internal extension Array where Element == ClusterColumnMetadata {

	//
	func toSurveyDatumLanguageArray() -> [Survey.DatumLanguage] {
		let uniquelyMergedArray: [ClusterColumnMetadata] = self

		return uniquelyMergedArray.map { clusterColumnMetadata in
			Survey.DatumLanguage(
				languageStringID: clusterColumnMetadata.titleTailOnlyAlphanumerics,
				languageLabel: clusterColumnMetadata.titleTail
			)
		}
	}

}

//
internal extension Array where Element == Survey.DatumLanguage {

	//
	func filterUniquelyCommon(with ccrs: [ColumnClusterReference?]) -> [Survey.DatumLanguage] {
		let allLanguages: [Survey.DatumLanguage] = self

		return allLanguages.filter { x in
			ccrs.allSatisfy { (ccr: ColumnClusterReference?) in
				ccr?.clusterColumnsMetadata.map { y in y.titleTail }.contains(x.languageLabel) ?? false
			}
		}
	}

}
