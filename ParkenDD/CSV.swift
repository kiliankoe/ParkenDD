//
//  CSV.swift
//  SwiftCSV
//
//  Created by naoty on 2014/06/09.
//  Copyright (c) 2014年 Naoto Kaneko. All rights reserved.
//

import Foundation

public class CSV {
	public var headers: [String] = []
	public var rows: [Dictionary<String, String>] = []
	public var columns = Dictionary<String, [String]>()
	var delimiter = NSCharacterSet(charactersInString: ",")

	public init(fromString csvStringToParse: String, delimiter: NSCharacterSet) throws {
		self.delimiter = delimiter

		let newline = NSCharacterSet.newlineCharacterSet()
		var lines: [String] = []
		csvStringToParse.stringByTrimmingCharactersInSet(newline).enumerateLines { line, stop in lines.append(line) }

		self.headers = self.parseHeaders(fromLines: lines)
		self.rows = self.parseRows(fromLines: lines)
		self.columns = self.parseColumns(fromLines: lines)
	}

	public convenience init(fromString csvStringToParse: String) throws {
		let comma = NSCharacterSet(charactersInString: ",")
		try self.init(fromString: csvStringToParse, delimiter: comma)
	}

	public init(contentsOfURL url: NSURL, delimiter: NSCharacterSet) throws {
		let csvString: String?
		do {
			csvString = try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
		} catch _ {
			csvString = nil
		};
		if let csvStringToParse = csvString {
			self.delimiter = delimiter

			let newline = NSCharacterSet.newlineCharacterSet()
			var lines: [String] = []
			csvStringToParse.stringByTrimmingCharactersInSet(newline).enumerateLines { line, stop in lines.append(line) }

			self.headers = self.parseHeaders(fromLines: lines)
			self.rows = self.parseRows(fromLines: lines)
			self.columns = self.parseColumns(fromLines: lines)
		}
	}

	public convenience init(contentsOfURL url: NSURL) throws {
		let comma = NSCharacterSet(charactersInString: ",")
		try self.init(contentsOfURL: url, delimiter: comma)
	}

	func parseHeaders(fromLines lines: [String]) -> [String] {
		return lines[0].componentsSeparatedByCharactersInSet(self.delimiter)
	}

	func parseRows(fromLines lines: [String]) -> [Dictionary<String, String>] {
		var rows: [Dictionary<String, String>] = []

		for (lineNumber, line) in lines.enumerate() {
			if lineNumber == 0 {
				continue
			}

			var row = Dictionary<String, String>()
			let values = line.componentsSeparatedByCharactersInSet(self.delimiter)
			for (index, header) in self.headers.enumerate() {
				let value = values[index]
				row[header] = value
			}
			rows.append(row)
		}

		return rows
	}

	func parseColumns(fromLines lines: [String]) -> Dictionary<String, [String]> {
		var columns = Dictionary<String, [String]>()

		for header in self.headers {
			let column = self.rows.map { row in row[header]! }
			columns[header] = column
		}

		return columns
	}
}