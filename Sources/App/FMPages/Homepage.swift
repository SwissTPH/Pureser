//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation
import HTML
import Vapor

struct HomePage {

	func pageHTML() -> Node {

		return UploadPage().pageHTML()

		//--------------------------------------------------

		let pageHTML: Node = nodeContainer {
			html {
				head {
					meta(charset: "utf-8")
					meta(charset: "utf-8", content: "text/html", httpEquiv: "Content-Type")
					meta(content: "en-UK", httpEquiv: "content-language")

					title { FixedText.webAppNamePublic + " / Homepage" }
				} // end head
				body {
					"Hello, world!"
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
