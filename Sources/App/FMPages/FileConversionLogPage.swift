//
//  File.swift
//  
//
//  Created by R. Makhoul on 08/02/2021.
//

import Foundation
import HTML
import Swim
import Vapor

struct FileConversionLogPage {

	/// The log or part of log to be displayed in this page.
	let fileConversionLog: [FileConversionLog]


	/// The total number count of files converted, i.e. total number of entries in the log's database table.
	let totalCountOfFilesConverted: Int

	/// The number of entries requested in the query, this is different than was was actually retrieved,
	/// because it is possible that the number requested is larger than the total number of entries in the log's database table.
	let queryRequestLimit: Int


	/// The number of entires eventually retrieved in the query result,
	/// because it is possible that the number requested is larger than the total number of entries in the log's database table.
	var queryResultedCount: Int { self.fileConversionLog.count }


	/// FileConversionLogPage.init
	///
	/// - Parameters:
	///      - fileConversionLog: The log or part of log to be displayed in this page.
	///      - totalCountOfFilesConverted: The total number count of files converted, i.e. total number of entries in the log's database table.
	///      - queryRequestLimit: The number of entries requested in the query, this is different than was was actually retrieved,
	///      because it is possible that the number requested is larger than the total number of entries in the log's database table.
	///
	init(
		fileConversionLog: [FileConversionLog],

		totalCountOfFilesConverted: Int,
		queryRequestLimit: Int
	) {
		self.fileConversionLog = fileConversionLog

		self.totalCountOfFilesConverted = totalCountOfFilesConverted
		self.queryRequestLimit = queryRequestLimit
	}

	
	// MARK: Page HTML

	func pageHTML() -> Node {

		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "yyyy-MMM-dd HH:mm:ss zzzxxx"

		//--------------------------------------------------

		//
		var _pageCSS: [String] = []

		_pageCSS.append(
			"""
			body {
				font-family: "Times New Roman", Times, serif;
			}
			"""
		)

		_pageCSS.append(
			"""
			table {
				border-collapse: separate;
				border-spacing: 0;
			}
			table > * > tr > th,
			table > * > tr > td {
				border-right: 1px solid #D1D1D1;
				border-bottom: 1px solid #D1D1D1;
			}
			table > * > tr > th:first-of-type,
			table > * > tr > td:first-of-type {
				border-left: 1px solid #D1D1D1;
			}
			table > :first-child > tr:first-of-type > th,
			table > :first-child > tr:first-of-type > td {
				border-top: 1px solid #D1D1D1;
			}

			table > :first-child > tr:first-of-type > th:first-of-type,
			table > :first-child > tr:first-of-type > td:first-of-type {
				border-top-left-radius: 6px;
			}
			table > :first-child > tr:first-of-type > th:last-of-type,
			table > :first-child > tr:first-of-type > td:last-of-type {
				border-top-right-radius: 6px;
			}
			table > :last-child > tr:last-of-type > td:first-of-type {
				border-bottom-left-radius: 6px;
			}
			table > :last-child > tr:last-of-type > td:last-of-type {
				border-bottom-right-radius: 6px;
			}
			"""
		)

		_pageCSS.append(
			"""
			body {
				padding: 30pt 20pt;
			}

			.main-div {
				width: 600pt;
				margin: 0 auto;

				text-align: center;
			}

			table {
				margin: auto auto;
				max-width: 100%;
				table-layout: fixed;
			}
			table th, table td {
				padding: 3pt 5pt;
			}
			table th {
				background-color: #F1F1F1;
			}

			.can-break-word {
				word-break: break-word;
			}
			.no-history {
				text-align: center;
				font-style: italic;
			}
			.centered-text {
				text-align: center;
			}
			.msbb-text {
				font-family: monospace;
				background-color: #E9E9E9;
				display: inline-block;
				border: 1pt solid #D1D1D1;
				border-radius: 5pt;
				padding: 2pt 3pt;
			}

			.ul-title {
				--mptop: 2pt;

				margin-top: var(--mptop);
				padding-top: var(--mptop);

				text-decoration: underline;
			}
			.ul-title-notices {
				color: yellow;
			}
			.ul-title-errors {
				color: red;
			}
			ul {
				margin: 0 2pt 1pt 1pt;
			}
			li {
				font-family: monospace;
			}
			"""
		)

		// Final page CSS.
		let pageCSS = _pageCSS.joined(separator: "\n/* =============== =============== */\n")

		//--------------------------------------------------

		/// thead tr
		let tableHeaderRow: Node = nodeContainer {
			tr {
				th { "File name" %% br() %% "& file MD5 checksum" }
				th { "For" }
				th { "Status" }
				th { "Started at" }
			}
		}

		//
		let repeatTableHeaderRowEvery: Int = 10

		//
		var printedEntriesCount: Int = 0

		//--------------------------------------------------

		let pageHTML: Node = nodeContainer {
			html {
				head {
					meta(charset: "utf-8")
					meta(charset: "utf-8", content: "text/html", httpEquiv: "Content-Type")
					meta(content: "en-UK", httpEquiv: "content-language")

					title { FixedText.webAppNamePublic + " / Conversion History" }

					//--------------------------------------------------
					style {
						pageCSS
					}
					//--------------------------------------------------
				} // end head
				body {
					div(class: "main-div") {

						h2 {
							"Form Files Conversion History"
						}

						div(style: "margin-bottom: 20pt;") {
							div(style: "") {
								"Most recent " %% b { "\(self.queryResultedCount)" } %% ". Sorted by most recent on top."
							}
							div(style: "margin-top: 5pt;font-style: italic;") {
								"Total number of all files converted: " %% b { "\(self.totalCountOfFilesConverted)" } %% "."
							}
						}

						table {
							thead {
								tableHeaderRow
							}
							tbody {
								if !self.fileConversionLog.isEmpty {
									self.fileConversionLog.map { (entry: FileConversionLog) -> Node in
										printedEntriesCount += 1
										return nodeContainer {
											if printedEntriesCount % repeatTableHeaderRowEvery == 0 {
												tableHeaderRow
											}

											tr {
												td(class: "can-break-word") {
													entry.filename
													div(style: "margin: 3pt auto 1pt;text-align: center;") {
														span(class: "msbb-text") { entry.fileChecksum.md5 }
													}
												}
												td(class: "centered-text") {
													entry.conversionPrintVersion.toString
												}
												td(class: "can-break-word") {
													entry.conversionStatus.toStringWithEmoji
													if !entry.conversionSuccessNotices.isEmpty {
														div(class: "ul-title ul-title-notices") {
															"Notices:"
														}
														ul {
															entry.conversionSuccessNotices.map { (x: String) in
																li { x }
															}
														}
													}
													if !entry.conversionFailureErrors.isEmpty {
														div(class: "ul-title ul-title-errors") {
															"Errors:"
														}
														ul {
															entry.conversionFailureErrors.map { (x: String) in
																li { x }
															}
														}
													}
												}
												td(class: "centered-text") {
													dateFormatter.string(from: entry.conversionStartDatetime)
													div(style: "margin: calc(3pt + 1pt) auto 1pt;") {
														"Took " %% u { entry.conversionExecutionTimeInterval(fractionDigits: 2) } %% " seconds."
													}
												}
											}
										} // end nodeContainer
									} // end .map
								} else {
									tr {
										td(class: "no-history", colspan: "4") {
											"No files were converted yet."
										}
									}
								}
							}
						} // end table

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
