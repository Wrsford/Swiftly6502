//
//  SAARM.swift
//  SwiftlyARM
//
//  Created by Will Stafford on 6/17/15.
//  Copyright © 2015 Wrsford. All rights reserved.
//

import Foundation

func hex(num: Int) -> String {
	return String(num, radix: 16)
}

extension Int {
	
	func hex(places: Int) -> String {
		return (NSString(format: "%0\(places)x", self) as String)
	}
	
	func hex() -> String { // Use for bytes
		let strVrs = (NSString(format: "%x", self) as String)
		return self.hex(strVrs.length()+(strVrs.length()%2))
	}
	
	subscript(index: Int) -> Int {
		get {
			return (self & (0x00000001 << index)) >> index
		}
		
		set(value) {
			if (value == 1) {
				self |= 1 << index
			} else {
				self &= ~(1 << index)
			}
			
		}
	}
}

extension String {
	func removeExcessWhiteSpace() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	}
	
	func removeComments(commentString: String) -> String {
		let range = self.rangeOfString(commentString)
		if range != nil {
			return self.substringToIndex(range!.startIndex)
		}
		return self
	}
	
	func remove6502CompilerExcess() -> String {
		return self.removeComments(";").removeExcessWhiteSpace().uppercaseString
	}
	
	func length() -> Int {
		return self.characters.count
	}
	
	func endsWith(suffix: String) -> Bool {
		let range = self.rangeOfString(suffix)
		
		if range != nil {
			if range!.endIndex == self.endIndex {
				return true
			}
		}
		
		return false
	}
	
	func replace(expr: String, newText: String) -> String {
		return self.stringByReplacingOccurrencesOfString(expr, withString: newText)
	}
	
	func startsWith(prefix: String) -> Bool {
		let range = self.rangeOfString(prefix)
		
		if range != nil {
			if range!.startIndex == self.startIndex {
				return true
			}
		}
		
		return false
	}
	
	func substringFromIndex(index: Int) -> String {
		return String((self as NSString).substringFromIndex(index))
	}
	
	func substringToIndex(index: Int) -> String {
		return String((self as NSString).substringToIndex(index))
	}
	
	func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
		if let from = String.Index(self.utf16.startIndex + nsRange.location, within: self),
			let to = String.Index(self.utf16.startIndex + nsRange.location + nsRange.length, within: self) {
				return from ..< to
		}
		return nil
	}
}

class StatusRegister {
	var N = 0
	var V = 0
	var B = 1
	var D = 0
	var I = 0
	var Z = 0
	var C = 0
	
	var value: Int {
		get {
			var theVal = 0
			theVal[7] = N
			theVal[6] = V
			theVal[5] = 1
			theVal[4] = B
			theVal[3] = D
			theVal[2] = I
			theVal[1] = Z
			theVal[0] = C
			return theVal & 0x00ff
		}
		
		set(val) {
			N = val[7]
			V = val[6]
			
			B = val[4]
			D = val[3]
			I = val[2]
			Z = val[1]
			C = val[0]
		}
	}
}

class scpu {
	var ah = 0
	var xh = 0
	var yh = 0
	var sph = 0xff
	var A: Int {
		get {
			return ah
		}
		
		set(val) {
			ah = val & 0xff
		}
	}
	var X: Int {
		get {
			return xh
		}
		
		set(val) {
			xh = val & 0xff
		}
	}
	var Y: Int {
		get {
			return yh
		}
		
		set(val) {
			yh = val & 0xff
		}
	}
	var SP: Int {
		get {
			return sph
		}
		
		set(val) {
			sph = val & 0xff
		}
	}
	var P = StatusRegister()
	var PC: Int // 16
	let ram = eram() // 64K
	let gpu = egpu()
	let binaryOffset = 0x600
	var codeRunning = false
	let hz = 1023000.0
	
	init() {
		//A=0 // Accumulator
		//X=0 // X Register
		//Y=0 // Y Register
		//sr=0 // Status Register
		//SP=0xff // Stack Pointer
		PC=binaryOffset // Program Counter
	}
	
	func description() -> String {
		var description = "scpu: {\n"
		description += "\tA: $\(A.hex(2))\n"
		description += "\tX: $\(X.hex(2))\n"
		description += "\tY: $\(Y.hex(2))\n"
		description += "\tSR: $\(P.value.hex(2))\n"
		description += "\tSP: $\(SP.hex(2))\n"
		description += "\tPC: $\(PC.hex(4))\n"
		description += "}"
		return description;
	}
	
	func inputKey(key: String) {
		let sysLastKey = 0xff
		
		ram[sysLastKey] = Int((key as NSString).characterAtIndex(0))
	}
	
	func run() {
		//test()
		//return
		
		let sysRandomAddr = 0xfe
		codeRunning = true
		
		while (codeRunning) {
			//print(PC.hex())
			//1.023mhz
			//let startTime = NSDate()
			
			ram[sysRandomAddr] = random() & 0x00FF
			let findOP = instruction.instrWithOPC(ram[PC])
			
			if findOP != nil {
				//print("Apple: \(ram[0x01].hex())\(ram[0x00].hex())")
				//print("Snake: \(ram[0x11].hex())\(ram[0x10].hex())")
				let op = findOP!
				
				// Find args
				var args = [Int](count: 2, repeatedValue: 0)
				for (var i = 1; i < op.bytes; i++) {
					args[i-1] = ram[PC+i]
				}
				
				op.arg = (args[1]<<8) | (args[0])
				
				
				PC += op.bytes
				
				executeOp(op)
				//let newTime = NSDate().timeIntervalSinceDate(startTime)
				usleep(useconds_t((Double(op.cycles) / hz) * 1000000))
			}
		}
		
		
	}
	
	func run(offset: Int) {
		PC = offset
		run()
	}
	
	func test() {
		print(self.description())
		
		
		var alreadyNamed = [String]()
		print("let iGroups = [")
		for i in instructionSet {
			if alreadyNamed.contains(i.assembler) {
				continue
			}
			alreadyNamed.append(i.assembler)
			print("\"\(i.assembler)\" : InstructionGroups.\(i.assembler),")
			
			//print("case \(i.assembler)")
			//print("case \"\(i.assembler)\: // \(i.assembler)\nprint(\"\(i.assembler)\")\n")
		}
		print("]")
		return
		//let data = [0xa5, 0xc0, 0xaa, 0xe8, 0x69, 0xc4, 0x00]
		//disassemble(data)
		
		var filestuff: String
		do {
			try filestuff = String(contentsOfFile: "/Users/wrsford/Dropbox/Development/Swiftly6502/Swiftly6502/test.6502")
			
		} catch {
			filestuff = ""
			print("File not found")
		}
		
		let asmbr = assembler()
		let binary = asmbr.assemble(filestuff, offset: binaryOffset)
		for i in binary {
			print(i.hex(2) + " ", appendNewline: false)
		}
		
		ram.loadData(binary, startAddress: binaryOffset)
		
		run()
		
		print(description())
		
		return
		
		print("\n\nDisassembly:")
		print(disassemble(binary))
		print("\n\n\n\n")
		
		print(disassemble([0x20, 0x06, 0x06, 0x20, 0x38, 0x06, 0x20, 0x0d, 0x06, 0x20, 0x2a, 0x06, 0x60, 0xa9, 0x02, 0x85,
			0x02, 0xa9, 0x04, 0x85, 0x03, 0xa9, 0x11, 0x85, 0x10, 0xa9, 0x10, 0x85, 0x12, 0xa9, 0x0f, 0x85,
			0x14, 0xa9, 0x04, 0x85, 0x11, 0x85, 0x13, 0x85, 0x15, 0x60, 0xa5, 0xfe, 0x85, 0x00, 0xa5, 0xfe,
			0x29, 0x03, 0x18, 0x69, 0x02, 0x85, 0x01, 0x60, 0x20, 0x4d, 0x06, 0x20, 0x8d, 0x06, 0x20, 0xc3,
			0x06, 0x20, 0x19, 0x07, 0x20, 0x20, 0x07, 0x20, 0x2d, 0x07, 0x4c, 0x38, 0x06, 0xa5, 0xff, 0xc9,
			0x77, 0xf0, 0x0d, 0xc9, 0x64, 0xf0, 0x14, 0xc9, 0x73, 0xf0, 0x1b, 0xc9, 0x61, 0xf0, 0x22, 0x60,
			0xa9, 0x04, 0x24, 0x02, 0xd0, 0x26, 0xa9, 0x01, 0x85, 0x02, 0x60, 0xa9, 0x08, 0x24, 0x02, 0xd0,
			0x1b, 0xa9, 0x02, 0x85, 0x02, 0x60, 0xa9, 0x01, 0x24, 0x02, 0xd0, 0x10, 0xa9, 0x04, 0x85, 0x02,
			0x60, 0xa9, 0x02, 0x24, 0x02, 0xd0, 0x05, 0xa9, 0x08, 0x85, 0x02, 0x60, 0x60, 0x20, 0x94, 0x06,
			0x20, 0xa8, 0x06, 0x60, 0xa5, 0x00, 0xc5, 0x10, 0xd0, 0x0d, 0xa5, 0x01, 0xc5, 0x11, 0xd0, 0x07,
			0xe6, 0x03, 0xe6, 0x03, 0x20, 0x2a, 0x06, 0x60, 0xa2, 0x02, 0xb5, 0x10, 0xc5, 0x10, 0xd0, 0x06,
			0xb5, 0x11, 0xc5, 0x11, 0xf0, 0x09, 0xe8, 0xe8, 0xe4, 0x03, 0xf0, 0x06, 0x4c, 0xaa, 0x06, 0x4c,
			0x35, 0x07, 0x60, 0xa6, 0x03, 0xca, 0x8a, 0xb5, 0x10, 0x95, 0x12, 0xca, 0x10, 0xf9, 0xa5, 0x02,
			0x4a, 0xb0, 0x09, 0x4a, 0xb0, 0x19, 0x4a, 0xb0, 0x1f, 0x4a, 0xb0, 0x2f, 0xa5, 0x10, 0x38, 0xe9,
			0x20, 0x85, 0x10, 0x90, 0x01, 0x60, 0xc6, 0x11, 0xa9, 0x01, 0xc5, 0x11, 0xf0, 0x28, 0x60, 0xe6,
			0x10, 0xa9, 0x1f, 0x24, 0x10, 0xf0, 0x1f, 0x60, 0xa5, 0x10, 0x18, 0x69, 0x20, 0x85, 0x10, 0xb0,
			0x01, 0x60, 0xe6, 0x11, 0xa9, 0x06, 0xc5, 0x11, 0xf0, 0x0c, 0x60, 0xc6, 0x10, 0xa5, 0x10, 0x29,
			0x1f, 0xc9, 0x1f, 0xf0, 0x01, 0x60, 0x4c, 0x35, 0x07, 0xa0, 0x00, 0xa5, 0xfe, 0x91, 0x00, 0x60,
			0xa2, 0x00, 0xa9, 0x01, 0x81, 0x10, 0xa6, 0x03, 0xa9, 0x00, 0x81, 0x10, 0x60, 0xa2, 0x00, 0xea,
			0xea, 0xca, 0xd0, 0xfb, 0x60 ]))
	}
	
	func push(stackPointer: Int, val: Int) {
		ram.stack[stackPointer] = val
	}
	
	func pull(stackPointer: Int) -> Int {
		return ram.stack[stackPointer]
	}
	
	func bcd(num: Int) -> Int {
		let hi = (((num & 0x00FF00) >> 8) % 9) * 10
		let lo = ((num & 0x0000FF) % 9)
		return hi + lo
	}
	
	class operand {
		var isAddress = false
		var value = 0
	}
	
	func executeOp(op: instruction) {
		var rawArg = operand()
		var accum = false
		
		var M: Int {
			get {
				if accum {
					return A
				} else if rawArg.isAddress {
					return ram[rawArg.value]
				} else {
					return rawArg.value
				}
			}
			
			set(val) {
				if accum {
					A = val
				} else if rawArg.isAddress {
					ram[rawArg.value] = val & 0x00ffff
				} else {
					rawArg.value = val & 0x00ffff
				}
			}
		}
		
		switch op.qAddressing {
		case AddressingModes.Accumulator:
			M = A
			accum = true
			
		case AddressingModes.Absolute:
			M = op.arg
			rawArg.isAddress = true
			
		case AddressingModes.AbsoluteX:
			M = op.arg + X
			rawArg.isAddress = true
		
		case AddressingModes.AbsoluteY:
			M = op.arg + Y
			rawArg.isAddress = true
		
		case AddressingModes.Immediate:
			M = op.arg
			
		case AddressingModes.Implied:
			M = 0 // No arg
		
		case AddressingModes.Indirect:
			M = ((ram[op.arg+1] << 8) & 0x00ff00) | ram[op.arg]
			rawArg.isAddress = true
			
		case AddressingModes.IndirectX:
			M = ((ram[op.arg+1+X] << 8) & 0x00ff00) | ram[op.arg+X]
			rawArg.isAddress = true
		
		case AddressingModes.IndirectY:
			M = (((ram[op.arg+1] << 8) & 0x00ff00) | ram[op.arg]) + Y
			rawArg.isAddress = true
		
		case AddressingModes.Relative:
			if (op.arg[7] == 1) {
				// Negative
				M = PC - (~op.arg & 0x00ff) - 1
			} else {
				M = PC + op.arg
			}
		
		case AddressingModes.Zeropage:
			M = op.arg
			rawArg.isAddress = true
		
		case AddressingModes.ZeropageX:
			M = (op.arg + X) & 0x00ff
			rawArg.isAddress = true
		
		case AddressingModes.ZeropageY:
			M = (op.arg + Y) & 0x00ff
			rawArg.isAddress = true
			
		default:
			M = 0
		}
		
		var t: Int
		
		switch op.groupIndex {
			
		case InstructionGroups.ADC: // ADC
			//print("ADC")
			t = A + M + P.C
			
			P.V = A[7] != t[7] ? 1:0
			P.N = A[7]
			P.Z = t==0 ? 1:0
			
			if (P.D == 1) {
				t = bcd(A) + bcd(M) + P.C
				P.C = (t>99) ? 1:0
			} else {
				P.C = (t>255) ? 1:0
			}
			A = t & 0xFF
			
		case InstructionGroups.AND: // AND
			//print("AND")
			A = A & M
			P.N = A[7]
			P.Z = (A==0) ? 1:0
			
		case InstructionGroups.ASL: // ASL
			//print("ASL")
			P.C = M[7]
			M = (M << 1) & 0x00FE
			P.N = M[7]
			P.Z = (M == 0) ? 1:0
			
		case InstructionGroups.BCC: // BCC
			//print("BCC")
			if (P.C == 0) {
				PC = M
			}
			
		case InstructionGroups.BCS: // BCS
			//print("BCS")
			if (P.C == 1) {
				PC = M
			}
			
		case InstructionGroups.BEQ: // BEQ
			//print("BEQ")
			if (P.Z == 1) {
				PC = M
			}
			
		case InstructionGroups.BIT: // BIT
			//print("BIT")
			t = A & M
			P.N = t[7]
			P.V = t[6]
			P.Z = (t == 0) ? 1:0
			
		case InstructionGroups.BMI: // BMI
			//print("BMI")
			if (P.N == 1) {
				PC = M
			}
			
		case InstructionGroups.BNE: // BNE
			//print("BNE")
			if (P.Z == 0) {
				PC = M
			}
			
		case InstructionGroups.BPL: // BPL
			//print("BPL")
			if (P.N == 0) {
				PC = M
			}
			
		case InstructionGroups.BRK: // BRK
			//print("BRK") // Unclear. Do this later
			/*PC = PC + 1
			push(SP, val: (PC & 0x00FF00) >> 8)
			SP = SP - 1
			push(SP, val: PC & 0x00FF)
			SP = SP - 1
			push(SP, val: (P.value | 0x10))
			SP = SP - 1
			let l = pull(0xFFFE)
			let h = pull(0xFFFF)<<8
			PC = h|l*/
			codeRunning = false
			
		case InstructionGroups.BVC: // BVC
			//print("BVC")
			if (P.V == 0) {
				PC = M
			}
			
		case InstructionGroups.BVS: // BVC
			//print("BVS")
			if (P.V == 1) {
				PC = M
			}
			
		case InstructionGroups.CLC: // CLC
			//print("CLC")
			P.C = 0
			
		case InstructionGroups.CLD: // CLD
			//print("CLD")
			P.D = 0
			
		case InstructionGroups.CLI: // CLI
			//print("CLI")
			P.I = 0
			
		case InstructionGroups.CLV: // CLV
			//print("CLV")
			P.V = 0
			
		case InstructionGroups.CMP: // CMP
			//print("CMP")
			t = A - M
			P.N = t[7]
			P.C = (A>=M) ? 1:0
			P.Z = (t==0) ? 1:0
			
		case InstructionGroups.CPX: // CPX
			//print("CPX")
			t = X - M
			P.N = t[7]
			P.C = (X>=M) ? 1:0
			P.Z = (t==0) ? 1:0
			
		case InstructionGroups.CPY: // CPY
			//print("CPY")
			t = Y - M
			P.N = t[7]
			P.C = (Y>=M) ? 1:0
			P.Z = (t==0) ? 1:0
			
		case InstructionGroups.DEC: // DEC
			//print("DEC")
			M = (M - 1) & 0x00FF
			P.N = M[7]
			P.Z = (M==0) ? 1:0
			
		case InstructionGroups.DEX: // DEX
			//print("DEX")
			X = X - 1
			P.Z = (X==0) ? 1:0
			P.N = X[7]
			
		case InstructionGroups.DEY: // DEX
			//print("DEY")
			Y = Y - 1
			P.Z = (Y==0) ? 1:0
			P.N = Y[7]
			
		case InstructionGroups.EOR: // EOR
			//print("EOR")
			A = A ^ M
			P.N = A[7]
			P.Z = (A==0) ? 1:0
			
		case InstructionGroups.INC: // INC
			//print("INC")
			M = (M + 1) & 0x00FF
			P.N = M[7]
			P.Z = (M==0) ? 1:0
			
		case InstructionGroups.INX: // INX
			//print("INX")
			X = X + 1
			P.Z = (X==0) ? 1:0
			P.N = X[7]
			
		case InstructionGroups.INY: // INY
			//print("INY")
			Y = Y + 1
			P.Z = (Y==0) ? 1:0
			P.N = Y[7]
			
		case InstructionGroups.JMP: // JMP
			//print("JMP")
			PC = rawArg.value
			
		case InstructionGroups.JSR: // JSR
			//print("JSR") // More stack shit
			t = PC - 1
			push(SP, val: (t & 0x00FF00) >> 8)
			SP = SP - 1
			push(SP, val: t & 0x00FF)
			SP = SP - 1
			PC = rawArg.value
			
		case InstructionGroups.LDA: // LDA
			//print("LDA")
			A = M
			P.N = A[7]
			P.Z = (A==0) ? 1:0
			
		case InstructionGroups.LDX: // LDX
			//print("LDX")
			X = M
			P.N = X[7]
			P.Z = (X==0) ? 1:0
			
		case InstructionGroups.LDY: // LDY
			//print("LDY")
			Y = M
			P.N = Y[7]
			P.Z = (Y==0) ? 1:0
			
		case InstructionGroups.LSR: // LSR
			//print("LSR")
			P.N = 0
			P.C = M[0]
			M = (M >> 1) & 0x007F
			P.Z = (M==0) ? 1:0
			
		case InstructionGroups.NOP: // NOP
			true
			
		case InstructionGroups.ORA: // ORA
			//print("ORA")
			A = A | M
			P.N = A[7]
			P.Z = (A==0) ? 1:0
			
		case InstructionGroups.PHA: // PHA
			//print("PHA")
			push(SP, val: A)
			SP = SP - 1
			
		case InstructionGroups.PHP: // PHP
			//print("PHP")
			push(SP, val: P.value)
			SP = SP - 1
			
		case InstructionGroups.PLA: // PLA
			//print("PLA")
			SP = SP + 1
			A = pull(SP)
			P.N = A[7]
			P.Z = (A==0) ? 1:0
			
		case InstructionGroups.PLP: // PLA
			//print("PLP")
			SP = SP + 1
			P.value = pull(SP)
			
		case InstructionGroups.ROL: // ROL
			//print("ROL")
			t = M[7]
			M = (M << 1) & 0x00FE
			M = M | P.C
			P.C = t
			P.Z = (M==0) ? 1:0
			P.N = M[7]
			
		case InstructionGroups.ROR: // ROR
			//print("ROR")
			t = M[0]
			M = (M >> 1) & 0x007F
			M = M | ((P.C == 1) ? 0x0080:0x0000)
			P.C = t
			P.Z = (M==0) ? 1:0
			P.N = M[7]
			
		case InstructionGroups.RTI: // RTI
			//print("RTI")
			SP = SP - 1
			P.value = pull(SP)
			SP = SP - 1
			let l = pull(SP)
			SP = SP - 1
			let h = pull(SP)<<8
			PC = h|l
			
		case InstructionGroups.RTS: // RTS
			//print("RTS")
			SP = SP + 1
			let l = pull(SP)
			SP = SP + 1
			let h = pull(SP)<<8
			PC = (h|l) + 1
			
		case InstructionGroups.SBC: // SBC
			//print("SBC")
			if (P.D == 1) {
				t = bcd(A) - bcd(M) - (P.C == 1 ? 0 : 1)
				P.V = (t>99 || t<0) ? 1:0
			}
			else {
				t = A - M - (P.C == 1 ? 0 : 1)
				P.V = (t>127 || t < -128) ? 1:0
			}
			
			P.C = (t>=0) ? 1:0
			P.N = t[7]
			P.Z = (t==0) ? 1:0
			A = t & 0xFF
			
		case InstructionGroups.SEC: // SEC
			//print("SEC")
			P.C = 1
			
		case InstructionGroups.SED: // SED
			//print("SED")
			P.D = 1
			
		case InstructionGroups.SEI: // SEI
			//print("SEI")
			P.I = 1
			
		case InstructionGroups.STA: // STA
			//print("STA") // Lets rethink memory
			M = A
			
		case InstructionGroups.STX: // STX
			//print("STX")
			M = X
			
		case InstructionGroups.STY: // STY
			//print("STY")
			M = Y
			
		case InstructionGroups.TAX: // TAX
			//print("TAX")
			X = A
			P.N = X[7]
			P.Z = (X==0) ? 1:0
			
		case InstructionGroups.TAY: // TAY
			//print("TAY")
			Y = A
			P.N = Y[7]
			P.Z = (Y==0) ? 1:0
			
		case InstructionGroups.TSX: // TSX
			//print("TSX")
			X = SP
			P.N = X[7]
			P.Z = (X==0) ? 1:0
			
		case InstructionGroups.TXA: // TXA
			//print("TXA")
			A = X
			P.N = A[7]
			P.Z = (A==0) ? 1:0
			
		case InstructionGroups.TXS: // TXS
			//print("TXS")
			SP = X
			
		case InstructionGroups.TYA: // TYA
			//print("TYA")
			A = Y
			P.N = A[7]
			P.Z = (A==0) ? 1:0
			
		case InstructionGroups.SLP: // SLP
			usleep(useconds_t(M * 100000))
			
		default:
			print("def")
		}
	}
	
	
}






