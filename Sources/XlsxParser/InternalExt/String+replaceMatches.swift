//
//  File.swift
//  
//
//  Created by R. Makhoul on 02/12/2020.
//

import Foundation
import RegEx

//--------------------------------------------------

extension String {

	///
	public func replaceMatches(
		regexPattern pattern: String,
		options: NSRegularExpression.Options = [],
		replacement: (RegEx.Match) -> String
	) throws -> String {
		let string = self
		let regex = try RegEx(pattern: pattern, options: options)
		let result = regex.replaceMatches(in: string, replacement: replacement)
		return result
	}

}

//--------------------------------------------------
