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
	public func replacingMatches(
		regexPattern pattern: String,
		withTemplate templ: String,
		options: NSRegularExpression.Options = [],
		matchingOptions: NSRegularExpression.MatchingOptions = []
	) throws -> String {

		//
		var string = self
		let template = templ

		//
		let regex = try NSRegularExpression(pattern: pattern, options: options)

		//
		let range = NSRange(string.startIndex..., in: string)

		//
		string = regex.stringByReplacingMatches(
			in: string,
			options: matchingOptions,
			range: range,
			withTemplate: template
		)

		return string
	}

}

//--------------------------------------------------
