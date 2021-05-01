//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/10/2020.
//

import Foundation
import HTML
import Vapor

/// form data inputs
///
///
struct UploadPageFormData: Decodable {

	let xlsxFile: File

	let printVersion: PrintVersion

	/// If you change the `CodingKeys` string value, make sure to change them in related HTML and Javascript.
	enum CodingKeys: String, CodingKey {
		case xlsxFile = "input_xlsxFile"
		case printVersion = "input_printVersion"
	}

	struct FormInputName {
		static let xlsxFile = UploadPageFormData.CodingKeys.xlsxFile.rawValue
		static let printVersion = UploadPageFormData.CodingKeys.printVersion.rawValue
	}

	var xlsxFileData: Data {
		Data(self.xlsxFile.data.readableBytesView)
	}
}

///
///
///
enum DebugOptions {
	case crp
	case cells
	case survey

	case coreXLSXFile
}

///
///
///
struct UploadPage {

	private var debug: DebugOptions? = nil

	init(debug: DebugOptions? = nil) {
		self.debug = debug
	}

	func pageHTML() -> Node {

		let formAction: String
		if let debug = debug {
			switch debug {
			case .crp:
				formAction = "/debug/crp/"
			case .cells:
				formAction = "/debug/cells/"
			case .survey:
				formAction = "/debug/survey/"
			case .coreXLSXFile:
				formAction = "/debug/corexlsx-file/"
			}
		} else {
			formAction = "/cdp/"
		}

		let pageHTML: Node = nodeContainer {
			Node.documentType("html")
			html(lang: "en-UK") {
				head {
					meta(charset: "utf-8")
					meta(charset: "utf-8", content: "text/html", httpEquiv: "Content-Type")
					meta(content: "en-UK", httpEquiv: "content-language")

					title { FixedText.webAppNamePublic + " / Upload & Convert File" }

					//--------------------------------------------------
					style {
						"""
						.main-div {
							margin: 35px auto;

							width: 100%;
							max-width: 800px;

							text-align: center;
						}

						input.input-f {
							width: 50%;
						}
						input.s-input {
							width: 50%;
						}

						.pv-div {
							width: 80%;
							max-width: 200px;
							text-align: center;
							margin: auto auto;
						}

						#choose-file-f-m {
							font-style: italic;
							font-size: 11pt;
							color: #555;
						}
						"""
					}
					//--------------------------------------------------

					//--------------------------------------------------
					script {
						"""
						window.onload = function () {

							const fileInput = document.querySelector('form#cf-form input[type=file]');
							const submitButton = document.querySelector('form#cf-form input[type=submit]');
							const chooseFileFM = document.querySelector('#choose-file-f-m');

							fileInput.addEventListener("change", function(event) {
								if (fileInput.files.length > 0) {
									// const fileName = fileInput.files[0].name;
									chooseFileFM.style.display = 'none';
								} else {
									chooseFileFM.style.display = 'block';
								}
							});

							submitButton.addEventListener("click", function(event) {
								if (fileInput.files.length == 0) {
									if (chooseFileFM.style.display == 'none') {
										chooseFileFM.style.display = 'block';
										event.preventDefault();
									} else if (chooseFileFM.style.display == 'block') {
										alert(chooseFileFM.innerText);
										event.preventDefault();
									}
								}
							});

						}
						"""
					}
					//--------------------------------------------------

				} // end head
				body {

					//--------------------------------------------------
					div(class: "main-div") {
						h1 { "Upload & Convert File" }
						h3 { "ODK Excel (.xlsx) ➡️ Printable PDF (.pdf)" }

						br()

						form(action: formAction, enctype: "multipart/form-data", id: "cf-form", method: "POST") {

							div {
								input(accept: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", class: "input-f", name: UploadPageFormData.FormInputName.xlsxFile, type: "file")
							}
							br()

							h4(style: "margin: 15px auto 10px;") { "🎛 Version" }
							div(class: "pv-div") {
								if Settings.debug {
									div {
										input(
											checked: true,
											class: "input-pv",
											id: "id_" + PrintVersion.FormInputValue.developer,
											name: UploadPageFormData.FormInputName.printVersion,
											type: "radio",
											value: PrintVersion.FormInputValue.developer
										)
										label(for: "id_" + PrintVersion.FormInputValue.developer) { "Developer" }
									}
								}
								div {
									input(
										checked: Settings.debug ? false : true,
										class: "input-pv",
										id: "id_" + PrintVersion.FormInputValue.dataManager,
										name: UploadPageFormData.FormInputName.printVersion,
										type: "radio",
										value: PrintVersion.FormInputValue.dataManager
									)
									label(for: "id_" + PrintVersion.FormInputValue.dataManager) { "Data Manager" }
								}
								div {
									input(
										checked: false,
										class: "input-pv",
										id: "id_" + PrintVersion.FormInputValue.interviewer,
										name: UploadPageFormData.FormInputName.printVersion,
										type: "radio",
										value: PrintVersion.FormInputValue.interviewer
									)
									label(for: "id_" + PrintVersion.FormInputValue.interviewer) { "Interviewer" }
								}
							}
							br()
							br()

							div {
								input(class: "s-input", id: "", type: "submit", value: "Convert!")

								div(id: "choose-file-f-m", style: "display: none;") {
									"Must choose a file in order to convert."
								}
							}
						}

						if Settings.Feature.fileConversionLog {
							div(style: "margin-top: 45pt;") {
								a(href: "/history/", target: "_blank", title: "Form Files Conversion History") {
									"Form Files Conversion History"
								}
							}
						}

						// Logos
						if true {
							div(style: "margin-top: 50pt;") {
								LogosBlock.html
							}
						}
					}
					//--------------------------------------------------

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
