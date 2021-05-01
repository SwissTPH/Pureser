//
//  File.swift
//  
//
//  Created by R. Makhoul on 29/04/2021.
//

import Foundation
import HTML


//
private struct Logo {
	var name: String
	var imagePathname: String

	init(name: String, imagePathname: String) {
		self.name = name
		self.imagePathname = imagePathname
	}

	init(name: String, image: String) {
		self.name = name
		self.imagePathname = image
	}
}


//
private extension Logo {
	func imgHTMLTag(class: String? = nil, style: String? = nil) -> Node {
		img(
			alt: "\(self.name) logo",
			class: `class`,
			src: self.imagePathname,
			style: style,
			title: self.name
		)
	}
}


enum LogosBlock {

	//
	private static let logosDir: String = "/images/logo/"

	//
	private static let logos: [Logo] = [
		Logo(
			name: "Swiss TPH",
			image: logosDir + "Swiss_TPH_Logo_MSOffice-Web_RGB-color_1-line.png"
		),
		Logo(
			name: "Vital Strategies",
			image: logosDir + "Vital-Strategies-Logo.jpg"
		),
		Logo(
			name: "Bloomberg Philanlanthropies - Data For Health Initiative",
			image: logosDir + "BloombergPhilanlanthropies_DataForHealthInitiative_Logo_RGB.jpg"
		),
		Logo(
			name: "World Health Organization",
			image: logosDir + "World-Health-Organization-WHO-Logo.png"
		),
	]


	//
	static let html: Node = nodeContainer {

		style {
			"""
		.logos-4m28 {
			text-align: center;
		}
		.logos-4m28 .logos-4m28-row {
			display: flex;
			justify-content: center;
			align-items: center;
		}
		.logos-4m28 .logos-4m28-row > div {
			display: flex;
			justify-content: center;
			align-items: center;

			width: 140pt;
			height: 70pt;
		}
		.logos-4m28 .logos-4m28-row img {
			margin:auto 8pt;
		}
		"""
		}
		div(class: "logos-4m28") {
			div(class: "logos-4m28-row") {
				div {
					logos[0].imgHTMLTag(class: "", style: "width: 100pt;")
				}
				div {
					logos[1].imgHTMLTag(class: "", style: "width: 110pt;")
				}
				div {
					logos[2].imgHTMLTag(class: "", style: "width: 140pt;")
				}
			}
			div(class: "logos-4m28-row", style: "margin-top: -18pt;") {
				div {
					logos[3].imgHTMLTag(class: "", style: "width: 130pt;")
				}
			}
		}

	}

}
