//
//  File.swift
//  
//
//  Created by R. Makhoul on 29/08/2021.
//

import Foundation


public enum QuestionAgeGroup: String, Codable, CaseIterable {

	case neonate = "N"
	case child = "C"
	case adult = "A"

	case neonateAndChild = "N_C"
	case childAndAdult = "C_A"

	case all = "ALL"

}

extension QuestionAgeGroup {

	public init?(_ value: String?) {
		guard let value = value?.uppercased() else {
			return nil
		}

		switch value {
		case "N":
			self = .neonate
		case "C":
			self = .child
		case "A":
			self = .adult

		case "N_C":
			self = .neonateAndChild
		case "C_A":
			self = .childAndAdult

		case "ALL":
			self = .all

		default:
			return nil
		}
	}

}

extension QuestionAgeGroup {

	public var key: String {
		self.rawValue
	}

}
