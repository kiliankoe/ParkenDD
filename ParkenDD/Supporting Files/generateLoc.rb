#! /usr/bin/env ruby

puts File.open($FILENAME).read.lines.select{ |line| line.start_with? ?" }.map { |element| "\tcase " + element.split.first[1..-2] }
puts "\n\tfunc string() -> String {\n\t\treturn NSLocalizedString(self.rawValue, comment: \"\")\n\t}\n}\n"
