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
	
	fileprivate func isPreprocessor(_ line: String) -> Bool {
		//let keywords = [ "define" : ]
		return line.remove6502CompilerExcess().startsWith("DEFINE")
	}
	
	fileprivate func preprocess(_ code: String) -> String {
		var defines = [String : Int]()
		
		var lines = code.components(separatedBy: "\n")
		
        var i = 0
        while  i < lines.count {
            lines[i] = lines[i].remove6502CompilerExcess()
            var theLine = lines[i]
            if isPreprocessor(theLine) {
                theLine = theLine.substringFromIndex("DEFINE".length()).remove6502CompilerExcess()
                
                let rangeOfEq = theLine.range(of: "[[:space:]]", options: NSString.CompareOptions.regularExpression, range: theLine.range(of: theLine), locale: nil)
                if rangeOfEq != nil {
                    let theDefinedString = String(theLine[..<rangeOfEq!.lowerBound]).remove6502CompilerExcess()
                    
                    var theStringValue = String(theLine[rangeOfEq!.upperBound...]).remove6502CompilerExcess()
                    
                    var theValue: Int?
                    
                    if theStringValue.range(of: "$") != nil {
                        theStringValue = theStringValue.replace("$", newText: "")
                        theValue = Int(theStringValue, radix: 16)
                    } else {
                        theValue = Int(theStringValue)
                    }
                    
                    if theValue != nil {
                        defines[theDefinedString] = theValue!
                    } else {
                        print("Error: theValue is nil, no definition possible")
                    }
                }
                
                lines.remove(at: i)
                continue    // line removed, therefore not incrementing i
            }
            i += 1
        }
		
		var preprocessedCode = "\n".join(lines)
		
		let sortedKeys = defines.keys.sorted(by: { return $0.length() > $1.length() })
		
		print(sortedKeys)
		
		for i in sortedKeys {
			print(defines[i]!)
			preprocessedCode = preprocessedCode.replace(i, newText: String(defines[i]!))
		}
		return preprocessedCode
	}
	
	func assemble(_ code: String, offset startAddr: Int) -> [Int] {
		rawCode = self.preprocess(code.uppercased())
		var lines = rawCode.components(separatedBy: "\n")
		var binary = [Int]()
		
		var labels = [String : asmLabel]()
		
		// Find all the labels first
		for i in 0 ..< lines.count {
			let cleanLine = lines[i].remove6502CompilerExcess()
			
			if cleanLine.endsWith(":") {
				// This is a label
				let theLabl = (cleanLine as NSString).substring(to: cleanLine.length()-1)
				labels[theLabl] = asmLabel(name: theLabl)
				print("Label: " + theLabl)
			}
		}
		
		// Convert all non-hex to hex
        var i = 0
		while i < lines.count {
			let l = lines[i].remove6502CompilerExcess()
			if l == "RTS" {
				print("reached RTS")
			}
			if l.length() < 3 {
				lines.remove(at: i)
				continue    // line removed, therefore not incrementing i
			}
			
			if l.range(of: "$") == nil {
				// Replace the cmd code with blankness
				let matchRange = ("   " + l.substringFromIndex(3)).range(of: "[0-9]{1,}", options: NSString.CompareOptions.regularExpression, range: l.range(of: l), locale: nil)
				if matchRange != nil {
					let theNum = Int(l[matchRange!])
					
					if theNum != nil {
						lines.insert(l.replacingCharacters(in: matchRange!, with: "$" + theNum!.hex()), at: i)
						lines.remove(at: i+1)
					}
					
				}
			} else {
				let matchRange = ("   " + l.substringFromIndex(3)).range(of: "[0-9a-fA-F]{1,}", options: NSString.CompareOptions.regularExpression, range: l.range(of: l), locale: nil)
				if matchRange != nil {
					let theNum = Int(l[matchRange!], radix:16)
					
					if theNum != nil {
						lines.insert(l.replacingCharacters(in: matchRange!, with: theNum!.hex()), at: i)
						lines.remove(at: i+1)
					}
					
				}
			}
            i += 1
		}
		print("\n".join(lines))
		
		for lnum in 0 ..< lines.count {
			
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
					if pred.evaluate(with: lineToParse.uppercased()) {
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
						let range  = argDict[i]!.range(of: ser)
						
						if range != nil {
							var nextByte: Int
							nextByte = Int(lineToParse[range!], radix:16)!
							binary.insert(nextByte, at: insPnt-startAddr)
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
