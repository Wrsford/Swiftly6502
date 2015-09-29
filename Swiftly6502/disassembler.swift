//
//  disassembler.swift
//  SwiftlyARM
//
//  Created by Will Stafford on 7/26/15.
//  Copyright © 2015 Wrsford. All rights reserved.
//

import Foundation

func disassemble(data: [Int]) -> String {
	var currentAddr = 0
	var toReturn = ""
	while currentAddr < data.count {
		
		let theInstr = instruction.instrWithOPC(data[currentAddr])
		
		
		if (theInstr != nil) {
			var theLine = argDict[theInstr!.addressing]!
			
			theLine = theLine.replace("OPC", newText: theInstr!.assembler)
			
			if (theInstr!.bytes == 1) {
				
			}
			
			else if (theInstr!.bytes == 2) {
				theLine = theLine.replace("BB", newText: data[currentAddr+1].hex())
				theLine = theLine.replace("HH", newText: data[currentAddr+1].hex())
				theLine = theLine.replace("LL", newText: data[currentAddr+1].hex())
			}
			
			else if (theInstr!.bytes == 3) {
				theLine = theLine.replace("HH", newText: data[currentAddr+2].hex())
				theLine = theLine.replace("LL", newText: data[currentAddr+1].hex())
			}
			
			toReturn += theLine + "\n"
			currentAddr += theInstr!.bytes
		} else {
			toReturn += ".byte $" + data[currentAddr].hex() + "\n"
			//print("ERROR DECOMPILING")
			currentAddr++
		}
		
		
	}
	
	return toReturn
}