//
//  assembler.swift
//  SwiftlyARM
//
//  Created by Will Stafford on 7/27/15.
//  Copyright © 2015 Wrsford. All rights reserved.
//

import Foundation

class asmLabel {
	var name: String
	
	// Line number : bytes up to that point
	var byteIndexes = [Int]()
	
	var address = 0
	
	init(name: String) {
		self.name = name
	}
}

class assembler {
	var rawCode: String
	
	init() {
		rawCode = ""
	}
	
	private func isPreprocessor(line: String) -> Bool {
		//let keywords = [ "define" : ]
		return line.remove6502CompilerExcess().startsWith("DEFINE")
	}
	
	private func preprocess(code: String) -> String {
		var defines = [String : Int]()
		
		var lines = code.componentsSeparatedByString("\n")
		
		for (var i = 0; i < lines.count; i++) {
			lines[i] = lines[i].remove6502CompilerExcess()
			var theLine = lines[i]
			if isPreprocessor(theLine) {
				theLine = theLine.substringFromIndex("DEFINE".length()).remove6502CompilerExcess()
				
				let rangeOfEq = theLine.rangeOfString("[[:space:]]", options: NSStringCompareOptions.RegularExpressionSearch, range: theLine.rangeOfString(theLine), locale: nil)
				if rangeOfEq != nil {
					let theDefinedString = theLine.substringToIndex(rangeOfEq!.startIndex).remove6502CompilerExcess()
					// ALRIGHTY FUCKHEAD. I GOT UR GODDAMNED STRING
					
					var theStringValue = theLine.substringFromIndex(rangeOfEq!.endIndex).remove6502CompilerExcess()
					
					var theValue: Int?
					
					if theStringValue.rangeOfString("$") != nil {
						theStringValue = theStringValue.replace("$", newText: "")
						theValue = Int(theStringValue, radix: 16)
					}
					
					else {
						theValue = Int(theStringValue)
					}
					
					if theValue != nil {
						defines[theDefinedString] = theValue!
					}
					
					else {
						print("FUCK U ASSHOLE UR DEFINE IS SHIT")
					}
					
				}
				
				lines.removeAtIndex(i)
				i--
			}
		}
		
		var preprocessedCode = "\n".join(lines)
		
		let sortedKeys = defines.keys.sort({ return $0.length() > $1.length() })
		
		print(sortedKeys)
		
		for i in sortedKeys {
			print(defines[i]!)
			preprocessedCode = preprocessedCode.replace(i, newText: String(defines[i]!))
		}
		return preprocessedCode
	}
	
	func assemble(code: String, offset startAddr: Int) -> [Int] {
		rawCode = self.preprocess(code.uppercaseString)
		var lines = rawCode.componentsSeparatedByString("\n")
		var binary = [Int]()
		
		var labels = [String : asmLabel]()
		
		// Find all the labels first
		for (var i = 0; i < lines.count; i++) {
			let cleanLine = lines[i].remove6502CompilerExcess()
			
			if cleanLine.endsWith(":") {
				// This is a label
				let theLabl = (cleanLine as NSString).substringToIndex(cleanLine.length()-1)
				labels[theLabl] = asmLabel(name: theLabl)
				print("Label: " + theLabl)
			}
		}
		
		// Convert all non-hex to hex
		for (var i = 0; i < lines.count; i++) {
			let l = lines[i].remove6502CompilerExcess()
			if l == "RTS" {
				print("there he is")
			}
			if l.length() < 3{
				lines.removeAtIndex(i)
				i--
				continue
			}
			
			if l.rangeOfString("$") == nil {
				// Replace the cmd code with blankness
				let matchRange = ("   " + l.substringFromIndex(3)).rangeOfString("[0-9]{1,}", options: NSStringCompareOptions.RegularExpressionSearch, range: l.rangeOfString(l), locale: nil)
				if matchRange != nil {
					let theNum = Int(l.substringWithRange(matchRange!))
					
					if theNum != nil {
						lines.insert(l.stringByReplacingCharactersInRange(matchRange!, withString: "$" + theNum!.hex()), atIndex: i)
						lines.removeAtIndex(i+1)
					}
					
				}
			}
			
			else {
				let matchRange = ("   " + l.substringFromIndex(3)).rangeOfString("[0-9a-fA-F]{1,}", options: NSStringCompareOptions.RegularExpressionSearch, range: l.rangeOfString(l), locale: nil)
				if matchRange != nil {
					let theNum = Int(l.substringWithRange(matchRange!), radix:16)
					
					if theNum != nil {
						lines.insert(l.stringByReplacingCharactersInRange(matchRange!, withString: theNum!.hex()), atIndex: i)
						lines.removeAtIndex(i+1)
					}
					
				}
			}
		}
		print("\n".join(lines))
		
		for (var lnum = 0; lnum < lines.count; lnum++) {
			
			// Clear out comments and whitespace
			let cleanLine = lines[lnum].remove6502CompilerExcess()
			print("Parsing line: " + cleanLine)
			let curLine = cleanLine
			
			// Ignore blank lines
			if cleanLine == "" {
				continue
			}
			
			
			
			if cleanLine.endsWith(":") {
				// This is a label
				let theLabl = curLine.substringToIndex(cleanLine.length()-1)
				
				// This will exist because we already parsed through the lines
				labels[theLabl]!.address = binary.count + startAddr
				continue
			}
			
			let cmdCode = curLine.substringToIndex(3)
			
			/*let argDict = [
				"accumulator" : "OPC A",
				"absolute" : "OPC HHLL",
				"absolute,X" : "OPC HHLL,X",
				"absolute,Y" : "OPC HHLL,Y",
				"immediate" : "OPC #BB",
				"implied" : "OPC",
				"indirect" : "OPC (HHLL)",
				"(indirect,X)" : "OPC (BB,X)",
				"(indirect),Y" : "OPC (LL),Y",
				"relative" : "OPC BB",
				"zeropage" : "OPC LL",
				"zeropage,X" : "OPC LL,X",
				"zeropage,Y" : "OPC LL,Y"
			]*/
			
			
			let hxN = "[0-9a-fA-F]"
			let regexDict = [
				"accumulator" : "\(cmdCode) A",
				"absolute" : "\(cmdCode) \\$\(hxN){4}",
				"absolute,X" : "\(cmdCode) \\$\(hxN){4}\\,X",
				"absolute,Y" : "\(cmdCode) \\$\(hxN){4}\\,Y",
				"immediate" : "\(cmdCode) \\#\\$\(hxN){2}",
				"implied" : "\(cmdCode)",
				"indirect" : "\(cmdCode) \\(\\$\(hxN){4}\\)",
				"(indirect,X)" : "\(cmdCode) \\(\\$\(hxN){2}\\,X\\)",
				"(indirect),Y" : "\(cmdCode) \\(\\$\(hxN){2}\\)\\,Y",
				"relative" : "\(cmdCode) \\$\(hxN){2}", // Could be
				"zeropage" : "\(cmdCode) \\$\(hxN){2}", // either
				"zeropage,X" : "\(cmdCode) \\$\(hxN){2}\\,X",
				"zeropage,Y" : "\(cmdCode) \\$\(hxN){2}\\,Y"
			]
			
			var possibles = [String]()
			var lineToParse = curLine
			
			while possibles.count == 0 {
				for (key, value) in regexDict {
					let pred = NSPredicate(format: "SELF MATCHES %@", value)
					if pred.evaluateWithObject(lineToParse.uppercaseString) {
						// Predicate matches
						possibles.append(key)
					}
				}
				
				
				if possibles.count == 0 {
					// Check if it's a label
					
					if cleanLine.length() > 4 {
						let argStr = curLine.substringFromIndex(4)
						
						// Label stuff
						if labels[argStr] != nil {
							
							// Figure out if we should us abs or rel
							if instruction.instrWith(cmdCode, addressing: "absolute") != nil {
								lineToParse = cleanLine.replace(argStr, newText: "$0000")
							}
							
							else if instruction.instrWith(cmdCode, addressing: "relative") != nil {
								lineToParse = cleanLine.replace(argStr, newText: "$00")
							}
							
							
							
							
							// Have the label write to the byte following the command
							labels[argStr]!.byteIndexes.append(binary.count+1)
						}
					}
					
					else {
						break
					}
				}
				
			}
		
			var badCommand = true
			
			for i in possibles {
				
				let result = instruction.instrWith(cmdCode, addressing: i)
				
				if (result != nil) {
					badCommand = false
					binary.append(result!.opc)
					
					let insPnt = binary.count + startAddr
					
					let orderedSearcher = ["HH", "LL", "BB"]
					
					for ser in orderedSearcher {
						let range  = argDict[i]!.rangeOfString(ser)
						
						if range != nil {
							var nextByte: Int
							nextByte = Int(lineToParse.substringWithRange(range!), radix:16)!							
							binary.insert(nextByte, atIndex: insPnt-startAddr)
						}
					}
					
				}
				
			}
			
			if badCommand {
				print("COMPILER_ERROR: Bad command at line \(lnum) (non-fatal). Skipping this line.")
			}
			
		}
		
		for (_, label) in labels {
			for i in label.byteIndexes {
				let theCmd = instruction.instrWithOPC(binary[i-1])
				
				if theCmd != nil {
					if theCmd!.addressing == "absolute" { // Will need to adjust this for base address
						let hbyte = (label.address & 0xFF00) >> 8
						let lbyte = label.address & 0x00FF
						
						binary[i] = lbyte
						binary[i+1] = hbyte
					}
					
					else if theCmd!.addressing == "relative" {
						let off = label.address-i
						binary[i] = (off + ( (off / -off) - 1 ) / 2) & 0xff
					}
				}
				
			}
		}
		
		return binary
	}
}