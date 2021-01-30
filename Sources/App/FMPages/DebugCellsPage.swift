//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation
import HTML
//import CoreXLSX
import Vapor

/*

struct DebugCellsPage {

	private var cellsAndValues: [CellAndValue]

	init(cellsAndValues: [CellAndValue]) {
		self.cellsAndValues = cellsAndValues
	}

	func pageHTML() -> Node {

		let pageHTML: Node = nodeContainer {
			html {
				head {
					meta(charset: "utf-8")
					meta(charset: "utf-8", content: "text/html", httpEquiv: "Content-Type")
					meta(content: "en-UK", httpEquiv: "content-language")

					title { FixedText.webAppNamePublic + " / Debug Cells" }
				} // end head
				body {

					style {
						"""
						table {
							border-collapse: collapse;
						}
						table, th, td {
							border: 1px solid black;
						}
						"""
					}

					table {
						tr {
							th { "Info" }
							th { "Value" }
						}
						self.cellsAndValues.map { each -> Node in
							tr {
								td { each.cell }
								td { each.value }
							}
						}
					}

				} // end body
			} // end html
		}

		return pageHTML
	}

	func htmlResponse() -> Response {

		let httpBody: String = self.pageHTML().renderAsString()
		let httpContentType: String = "text/html"

		return .init(
			status: .ok,
			headers: .init([("Content-Type", httpContentType)]),
			body: Response.Body(string: httpBody)
		)
	}

}

*/
