//
//  File.swift
//  
//
//  Created by R. Makhoul on 28/01/2021.
//

import Foundation
import CoreXLSX
import protocol Vapor.ResponseEncodable
import protocol Vapor.Content

// MARK: -

extension Survey: Content { }


// MARK: - CoreXLSX debugging

extension CoreXLSX.Workbook: Content { }
extension CoreXLSX.Worksheet: Content { }
extension CoreXLSX.SharedStrings: Content { }

extension DebugCoreXLSXFile: Content { }
extension TestCell: Content { }

struct DebugCoreXLSXFile: Codable {
	var workbooks: [CoreXLSX.Workbook]
	var worksheets: [CoreXLSX.Worksheet]
	var sharedStrings: CoreXLSX.SharedStrings?
	var cells: [CoreXLSX.Cell]

	var testCells: [TestCell]
}

struct TestCell: Codable {
	let worksheetName: String

	let reference: CoreXLSX.CellReference
	let type: CoreXLSX.CellType?
	let value: String?
	let inlineString: CoreXLSX.InlineString?

	let string: String?
	let date: Date?
	let richString: [CoreXLSX.RichText]
	let richStringText: [String?]
	let richStringTextJoined: String?

	let alwaysPlainString: String?
}

// MARK: func debugCoreXLSXFile

func debugCoreXLSXFile(fileData: Data) throws -> DebugCoreXLSXFile {
	let file = try CoreXLSX.XLSXFile(data: fileData)
	print("File was read successfully.")

	let workbooks = try file.parseWorkbooks()
	let sharedStrings = try file.parseSharedStrings()

	var worksheets: [CoreXLSX.Worksheet] = []
	var cells: [CoreXLSX.Cell] = []
	var testCells: [TestCell] = []

	for wbk in try file.parseWorkbooks() {
		for (name, path) in try file.parseWorksheetPathsAndNames(workbook: wbk) {
			if let worksheetName = name {
				print("This worksheet has a name: \(worksheetName)")
			}

			let worksheet = try file.parseWorksheet(at: path)
			worksheets.append(worksheet)

			for row in worksheet.data?.rows ?? [] {
				for c in row.cells {
					//print(c)
					cells.append(c)

					guard let sharedStrings = sharedStrings else {
						testCells.append(
							TestCell(
								worksheetName: name ?? "(Unkown worksheet name)",

								reference: c.reference,
								type: c.type,
								value: c.value,
								inlineString: c.inlineString,

								string: nil,
								date: nil,
								richString: [],
								richStringText: [],
								richStringTextJoined: nil,

								alwaysPlainString: nil
							)
						)

						continue
					}

					let string = c.stringValue(sharedStrings)
					let date = c.dateValue
					let richString = c.richStringValue(sharedStrings)
					let richStringText = richString.map { $0.text }
					let richStringTextJoined = richStringText.compactMap { $0 }.joined()

					let alwaysPlainString: String?
					if let string = string, !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
						alwaysPlainString = string
					} else if let date = date {
						alwaysPlainString = String(describing: date)
					} else if !richString.isEmpty && !richString.allSatisfy({ $0.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true }) {
						alwaysPlainString = richString.compactMap { $0.text }.joined().trimmingCharacters(in: .whitespacesAndNewlines)
					} else {
						alwaysPlainString = nil
					}

					testCells.append(
						TestCell(
							worksheetName: name ?? "(Unkown worksheet name)",

							reference: c.reference,
							type: c.type,
							value: c.value,
							inlineString: c.inlineString,

							string: string,
							date: date,
							richString: richString,
							richStringText: richStringText,
							richStringTextJoined: richStringTextJoined,

							alwaysPlainString: alwaysPlainString
						)
					)
				}
			}
		}
	}

	return DebugCoreXLSXFile(
		workbooks: workbooks,
		worksheets: worksheets,
		sharedStrings: sharedStrings,
		cells: cells,

		testCells: testCells
	)
}
