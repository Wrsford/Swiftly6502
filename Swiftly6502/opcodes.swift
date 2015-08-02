//
//  opcodes.swift
//  SwiftlyARM
//
//  Created by Will Stafford on 7/26/15.
//  Copyright © 2015 Wrsford. All rights reserved.
//

import Foundation

var rawCodes = [["00",
	"BRK impl",
	"ORA X,ind",
	"??? ---",
	"??? ---",
	"??? ---",
	"ORA zpg",
	"ASL zpg",
	"??? ---",
	"PHP impl",
	"ORA #",
	"ASL A",
	"??? ---",
	"??? ---",
	"ORA abs",
	"ASL abs",
	"??? ---"],
	
	["10",
		"BPL rel",
		"ORA ind,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"ORA zpg,X",
		"ASL zpg,X",
		"??? ---",
		"CLC impl",
		"ORA abs,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"ORA abs,X",
		"ASL abs,X",
		"??? ---"],
	
	["20",
		"JSR abs",
		"AND X,ind",
		"??? ---",
		"??? ---",
		"BIT zpg",
		"AND zpg",
		"ROL zpg",
		"??? ---",
		"PLP impl",
		"AND #",
		"ROL A",
		"??? ---",
		"BIT abs",
		"AND abs",
		"ROL abs",
		"??? ---"],
	
	["30",
		"BMI rel",
		"AND ind,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"AND zpg,X",
		"ROL zpg,X",
		"??? ---",
		"SEC impl",
		"AND abs,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"AND abs,X",
		"ROL abs,X",
		"??? ---"],
	
	["40",
		"RTI impl",
		"EOR X,ind",
		"??? ---",
		"??? ---",
		"??? ---",
		"EOR zpg",
		"LSR zpg",
		"??? ---",
		"PHA impl",
		"EOR #",
		"LSR A",
		"??? ---",
		"JMP abs",
		"EOR abs",
		"LSR abs",
		"??? ---"],
	
	["50",
		"BVC rel",
		"EOR ind,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"EOR zpg,X",
		"LSR zpg,X",
		"??? ---",
		"CLI impl",
		"EOR abs,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"EOR abs,X",
		"LSR abs,X",
		"??? ---"],
	
	["60",
		"RTS impl",
		"ADC X,ind",
		"??? ---",
		"??? ---",
		"??? ---",
		"ADC zpg",
		"ROR zpg",
		"??? ---",
		"PLA impl",
		"ADC #",
		"ROR A",
		"??? ---",
		"JMP ind",
		"ADC abs",
		"ROR abs",
		"??? ---"],
	
	["70",
		"BVS rel",
		"ADC ind,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"ADC zpg,X",
		"ROR zpg,X",
		"??? ---",
		"SEI impl",
		"ADC abs,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"ADC abs,X",
		"ROR abs,X",
		"??? ---"],
	
	["80",
		"??? ---",
		"STA X,ind",
		"??? ---",
		"??? ---",
		"STY zpg",
		"STA zpg",
		"STX zpg",
		"??? ---",
		"DEY impl",
		"??? ---",
		"TXA impl",
		"??? ---",
		"STY abs",
		"STA abs",
		"STX abs",
		"??? ---"],
	
	["90",
		"BCC rel",
		"STA ind,Y",
		"??? ---",
		"??? ---",
		"STY zpg,X",
		"STA zpg,X",
		"STX zpg,Y",
		"??? ---",
		"TYA impl",
		"STA abs,Y",
		"TXS impl",
		"??? ---",
		"??? ---",
		"STA abs,X",
		"??? ---",
		"??? ---"],
	
	["A0",
		"LDY #",
		"LDA X,ind",
		"LDX #",
		"??? ---",
		"LDY zpg",
		"LDA zpg",
		"LDX zpg",
		"??? ---",
		"TAY impl",
		"LDA #",
		"TAX impl",
		"??? ---",
		"LDY abs",
		"LDA abs",
		"LDX abs",
		"??? ---"],
	
	["B0",
		"BCS rel",
		"LDA ind,Y",
		"??? ---",
		"??? ---",
		"LDY zpg,X",
		"LDA zpg,X",
		"LDX zpg,Y",
		"??? ---",
		"CLV impl",
		"LDA abs,Y",
		"TSX impl",
		"??? ---",
		"LDY abs,X",
		"LDA abs,X",
		"LDX abs,Y",
		"??? ---"],
	
	["C0",
		"CPY #",
		"CMP X,ind",
		"??? ---",
		"??? ---",
		"CPY zpg",
		"CMP zpg",
		"DEC zpg",
		"??? ---",
		"INY impl",
		"CMP #",
		"DEX impl",
		"??? ---",
		"CPY abs",
		"CMP abs",
		"DEC abs",
		"??? ---"],
	
	["D0",
		"BNE rel",
		"CMP ind,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"CMP zpg,X",
		"DEC zpg,X",
		"??? ---",
		"CLD impl",
		"CMP abs,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"CMP abs,X",
		"DEC abs,X",
		"??? ---"],
	
	["E0",
		"CPX #",
		"SBC X,ind",
		"??? ---",
		"??? ---",
		"CPX zpg",
		"SBC zpg",
		"INC zpg",
		"??? ---",
		"INX impl",
		"SBC #",
		"NOP impl",
		"??? ---",
		"CPX abs",
		"SBC abs",
		"INC abs",
		"??? ---"],
	
	["F0",
		"BEQ rel",
		"SBC ind,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"SBC zpg,X",
		"INC zpg,X",
		"??? ---",
		"SED impl",
		"SBC abs,Y",
		"??? ---",
		"??? ---",
		"??? ---",
		"SBC abs,X",
		"INC abs,X",
		"??? ---"]]


class opcode {
	var HI, LO: UInt8
	var name, argType: String
	var argCount: Int
	
	init(HI theHI: Int, LO theLO: Int, name theName: String) {
		self.HI = UInt8(theHI)
		self.LO = UInt8(theLO)
		self.name = theName.componentsSeparatedByString(" ")[0]
		self.argType = theName.componentsSeparatedByString(" ")[1]
		self.argCount = (argType != "impl") ? 1 : 0
	}
	
	var HILO : UInt8 {
		get {
			return HI | LO
		}
		
		set(num) {
			self.HI = num & 0xf0
			self.LO = num & 0x0f
		}
	}
	
	func description() -> String {
		return "OPCODE: \(name) {\n\tHILO: 0x" + String(self.HILO, radix: 16) + "\n}"
	}
	
	func isValid() -> Bool {
		return name != "??? ---"
	}
	
	
	
}

func buildOps() -> [opcode] {
	var theCodes = [opcode]()
	
	for (var i = 0; i < rawCodes.count; i++) {
		let codeGroup = rawCodes[i]
		let hiNibble : Int? = Int(codeGroup[0], radix: 16)
		for (var j = 1; j < codeGroup.count; j++) {
			theCodes.append(opcode(HI: hiNibble!, LO: j-1, name: codeGroup[j]))
		}
	}
	
	return theCodes
}

let opcodes = buildOps()

func opForCode(HILO: UInt8) -> opcode? {
	for (var i = 0; i < opcodes.count; i++) {
		if (opcodes[i].HILO == HILO) {
			return opcodes[i]
		}
	}
	
	return nil
}


// Real Talk Starts Here
var groups = [String : Int]()

class instruction {
	var addressing, assembler, description: String
	var opc, bytes: Int
	var cycles: Int
	var arg = 0
	var groupIndex = -1
	init(addressing: String,
		assembler: String,
		description: String,
		opc: Int,
		bytes: Int,
		cycles: Int) {
			
			self.addressing = addressing
			self.assembler = assembler
			self.description = description
			self.opc = opc
			self.bytes = bytes
			self.cycles = cycles
	}
	
	func printOverview() {
		print("Addr: " + self.addressing)
		print("Desc: " + self.description)
		print("OPC: " + String(self.opc, radix: 16))
		print("Bytes: " + String(self.bytes))
		print("Cycles: " + String(self.cycles))
		print("")
	}
	
	static func instrWithOPC(opc: Int) -> instruction? {
		for i in instructionSet {
			if i.opc == opc {
				return i
			}
		}
		return Optional.None
	}
	
	static func instrWith(name: String, addressing: String) -> instruction? {
		let gIdx = groups[name]
		
		if gIdx == nil {
			return nil
		}
		
		for i in instructionSet {
			if i.gIdx == gIdx && i.addressing == addressing {
				return i
			}
		}
		return Optional.None
	}
	
	static func assignGroupIndexes() {
		var count = 0
		for i in instructionSet {
			if groups[i.assembler] != nil {
				i.groupIndex = groups[i.assembler]!
			} else {
				groups[i.assembler] = count
				count++
				i.groupIndex = groups[i.assembler]!
			}
		}
		
	}
	
}

func instrForString(parsable: String) -> instruction {
	// 0
	// 14
	// 14
	// 6
	// 6
	var fuckSwift: NSString = parsable as NSString
	
	let addressing = fuckSwift.substringToIndex(14).stringByReplacingOccurrencesOfString(" ", withString: "")
	fuckSwift = fuckSwift.substringFromIndex(14)
	
	let description = fuckSwift.substringToIndex(14)
	let assembler = fuckSwift.substringToIndex(3)
	
	fuckSwift = fuckSwift.substringFromIndex(14)
	
	let opc = Int(fuckSwift.substringToIndex(6).stringByReplacingOccurrencesOfString(" ", withString: "") as String, radix: 16)
	fuckSwift = fuckSwift.substringFromIndex(6)
	
	let bytes = Int(fuckSwift.substringToIndex(6).stringByReplacingOccurrencesOfString(" ", withString: ""))
	fuckSwift = fuckSwift.substringFromIndex(6)
	
	let cycles = fuckSwift as String
	
	return instruction(addressing: addressing, assembler: assembler, description: description, opc: opc!, bytes: bytes!, cycles: Int(cycles.replace("*", newText: ""))!)
}

let qAddressingTable = [
	"accumulator" : 0x01,
	"absolute" : 0x02,
	"absolute,X" : 0x03,
	"absolute,Y" : 0x04,
	"immediate" : 0x05,
	"implied" : 0x05,
	"indirect" : 0x05,
	"(indirect,X)" : 0x05,
	"(indirect),Y" : 0x05,
	"relative" : 0x05,
	"zeropage" : 0x05,
	"zeropage,X" : 0x05,
	"zeropage,Y" : 0x05

]

let argDict = [
	"accumulator" : "OPC A",
	"absolute" : "OPC $HHLL",
	"absolute,X" : "OPC $HHLL,X",
	"absolute,Y" : "OPC $HHLL,Y",
	"immediate" : "OPC #$BB",
	"implied" : "OPC",
	"indirect" : "OPC ($HHLL)",
	"(indirect,X)" : "OPC ($BB,X)",
	"(indirect),Y" : "OPC ($LL),Y",
	"relative" : "OPC $BB",
	"zeropage" : "OPC $LL",
	"zeropage,X" : "OPC $LL,X",
	"zeropage,Y" : "OPC $LL,Y"
]


let instructionSet = [
	instrForString("immediate     ADC #oper     69    2     2"),
	instrForString("zeropage      ADC oper      65    2     3"),
	instrForString("zeropage,X    ADC oper,X    75    2     4"),
	instrForString("absolute      ADC oper      6D    3     4"),
	instrForString("absolute,X    ADC oper,X    7D    3     4*"),
	instrForString("absolute,Y    ADC oper,Y    79    3     4*"),
	instrForString("(indirect,X)  ADC (oper,X)  61    2     6"),
	instrForString("(indirect),Y  ADC (oper),Y  71    2     5*"),
	instrForString("immediate     AND #oper     29    2     2"),
	instrForString("zeropage      AND oper      25    2     3"),
	instrForString("zeropage,X    AND oper,X    35    2     4"),
	instrForString("absolute      AND oper      2D    3     4"),
	instrForString("absolute,X    AND oper,X    3D    3     4*"),
	instrForString("absolute,Y    AND oper,Y    39    3     4*"),
	instrForString("(indirect,X)  AND (oper,X)  21    2     6"),
	instrForString("(indirect),Y  AND (oper),Y  31    2     5*"),
	instrForString("accumulator   ASL A         0A    1     2"),
	instrForString("zeropage      ASL oper      06    2     5"),
	instrForString("zeropage,X    ASL oper,X    16    2     6"),
	instrForString("absolute      ASL oper      0E    3     6"),
	instrForString("absolute,X    ASL oper,X    1E    3     7"),
	instrForString("relative      BCC oper      90    2     2**"),
	instrForString("relative      BCS oper      B0    2     2**"),
	instrForString("relative      BEQ oper      F0    2     2**"),
	instrForString("zeropage      BIT oper      24    2     3"),
	instrForString("absolute      BIT oper      2C    3     4"),
	instrForString("relative      BMI oper      30    2     2**"),
	instrForString("relative      BNE oper      D0    2     2**"),
	instrForString("relative      BPL oper      10    2     2**"),
	instrForString("implied       BRK           00    1     7"),
	instrForString("relative      BVC oper      50    2     2**"),
	instrForString("relative      BVS oper      70    2     2**"),
	instrForString("implied       CLC           18    1     2"),
	instrForString("implied       CLD           D8    1     2"),
	instrForString("implied       CLI           58    1     2"),
	instrForString("implied       CLV           B8    1     2"),
	instrForString("immediate     CMP #oper     C9    2     2"),
	instrForString("zeropage      CMP oper      C5    2     3"),
	instrForString("zeropage,X    CMP oper,X    D5    2     4"),
	instrForString("absolute      CMP oper      CD    3     4"),
	instrForString("absolute,X    CMP oper,X    DD    3     4*"),
	instrForString("absolute,Y    CMP oper,Y    D9    3     4*"),
	instrForString("(indirect,X)  CMP (oper,X)  C1    2     6"),
	instrForString("(indirect),Y  CMP (oper),Y  D1    2     5*"),
	instrForString("immediate     CPX #oper     E0    2     2"),
	instrForString("zeropage      CPX oper      E4    2     3"),
	instrForString("absolute      CPX oper      EC    3     4"),
	instrForString("immediate     CPY #oper     C0    2     2"),
	instrForString("zeropage      CPY oper      C4    2     3"),
	instrForString("absolute      CPY oper      CC    3     4"),
	instrForString("zeropage      DEC oper      C6    2     5"),
	instrForString("zeropage,X    DEC oper,X    D6    2     6"),
	instrForString("absolute      DEC oper      CE    3     3"),
	instrForString("absolute,X    DEC oper,X    DE    3     7"),
	instrForString("implied       DEX           CA    1     2"),
	instrForString("implied       DEY           88    1     2"),
	instrForString("immediate     EOR #oper     49    2     2"),
	instrForString("zeropage      EOR oper      45    2     3"),
	instrForString("zeropage,X    EOR oper,X    55    2     4"),
	instrForString("absolute      EOR oper      4D    3     4"),
	instrForString("absolute,X    EOR oper,X    5D    3     4*"),
	instrForString("absolute,Y    EOR oper,Y    59    3     4*"),
	instrForString("(indirect,X)  EOR (oper,X)  41    2     6"),
	instrForString("(indirect),Y  EOR (oper),Y  51    2     5*"),
	instrForString("zeropage      INC oper      E6    2     5"),
	instrForString("zeropage,X    INC oper,X    F6    2     6"),
	instrForString("absolute      INC oper      EE    3     6"),
	instrForString("absolute,X    INC oper,X    FE    3     7"),
	instrForString("implied       INX           E8    1     2"),
	instrForString("implied       INY           C8    1     2"),
	instrForString("absolute      JMP oper      4C    3     3"),
	instrForString("indirect      JMP (oper)    6C    3     5"),
	instrForString("absolute      JSR oper      20    3     6"),
	
	//instrForString("relative      JSR oper      20    2     6"), // Added because fuck it
	
	instrForString("immediate     LDA #oper     A9    2     2"),
	instrForString("zeropage      LDA oper      A5    2     3"),
	instrForString("zeropage,X    LDA oper,X    B5    2     4"),
	instrForString("absolute      LDA oper      AD    3     4"),
	instrForString("absolute,X    LDA oper,X    BD    3     4*"),
	instrForString("absolute,Y    LDA oper,Y    B9    3     4*"),
	instrForString("(indirect,X)  LDA (oper,X)  A1    2     6"),
	instrForString("(indirect),Y  LDA (oper),Y  B1    2     5*"),
	instrForString("immediate     LDX #oper     A2    2     2"),
	instrForString("zeropage      LDX oper      A6    2     3"),
	instrForString("zeropage,Y    LDX oper,Y    B6    2     4"),
	instrForString("absolute      LDX oper      AE    3     4"),
	instrForString("absolute,Y    LDX oper,Y    BE    3     4*"),
	instrForString("immediate     LDY #oper     A0    2     2"),
	instrForString("zeropage      LDY oper      A4    2     3"),
	instrForString("zeropage,X    LDY oper,X    B4    2     4"),
	instrForString("absolute      LDY oper      AC    3     4"),
	instrForString("absolute,X    LDY oper,X    BC    3     4*"),
	instrForString("accumulator   LSR A         4A    1     2"),
	instrForString("zeropage      LSR oper      46    2     5"),
	instrForString("zeropage,X    LSR oper,X    56    2     6"),
	instrForString("absolute      LSR oper      4E    3     6"),
	instrForString("absolute,X    LSR oper,X    5E    3     7"),
	instrForString("implied       NOP           EA    1     2"),
	instrForString("immediate     ORA #oper     09    2     2"),
	instrForString("zeropage      ORA oper      05    2     3"),
	instrForString("zeropage,X    ORA oper,X    15    2     4"),
	instrForString("absolute      ORA oper      0D    3     4"),
	instrForString("absolute,X    ORA oper,X    1D    3     4*"),
	instrForString("absolute,Y    ORA oper,Y    19    3     4*"),
	instrForString("(indirect,X)  ORA (oper,X)  01    2     6"),
	instrForString("(indirect),Y  ORA (oper),Y  11    2     5*"),
	instrForString("implied       PHA           48    1     3"),
	instrForString("implied       PHP           08    1     3"),
	instrForString("implied       PLA           68    1     4"),
	instrForString("implied       PLP           28    1     4"),
	instrForString("accumulator   ROL A         2A    1     2"),
	instrForString("zeropage      ROL oper      26    2     5"),
	instrForString("zeropage,X    ROL oper,X    36    2     6"),
	instrForString("absolute      ROL oper      2E    3     6"),
	instrForString("absolute,X    ROL oper,X    3E    3     7"),
	instrForString("accumulator   ROR A         6A    1     2"),
	instrForString("zeropage      ROR oper      66    2     5"),
	instrForString("zeropage,X    ROR oper,X    76    2     6"),
	instrForString("absolute      ROR oper      6E    3     6"),
	instrForString("absolute,X    ROR oper,X    7E    3     7"),
	instrForString("implied       RTI           40    1     6"),
	instrForString("implied       RTS           60    1     6"),
	instrForString("immediate     SBC #oper     E9    2     2"),
	instrForString("zeropage      SBC oper      E5    2     3"),
	instrForString("zeropage,X    SBC oper,X    F5    2     4"),
	instrForString("absolute      SBC oper      ED    3     4"),
	instrForString("absolute,X    SBC oper,X    FD    3     4*"),
	instrForString("absolute,Y    SBC oper,Y    F9    3     4*"),
	instrForString("(indirect,X)  SBC (oper,X)  E1    2     6"),
	instrForString("(indirect),Y  SBC (oper),Y  F1    2     5*"),
	instrForString("implied       SEC           38    1     2"),
	instrForString("implied       SED           F8    1     2"),
	instrForString("implied       SEI           78    1     2"),
	instrForString("zeropage      STA oper      85    2     3"),
	instrForString("zeropage,X    STA oper,X    95    2     4"),
	instrForString("absolute      STA oper      8D    3     4"),
	instrForString("absolute,X    STA oper,X    9D    3     5"),
	instrForString("absolute,Y    STA oper,Y    99    3     5"),
	instrForString("(indirect,X)  STA (oper,X)  81    2     6"),
	instrForString("(indirect),Y  STA (oper),Y  91    2     6"),
	instrForString("zeropage      STX oper      86    2     3"),
	instrForString("zeropage,Y    STX oper,Y    96    2     4"),
	instrForString("absolute      STX oper      8E    3     4"),
	instrForString("zeropage      STY oper      84    2     3"),
	instrForString("zeropage,X    STY oper,X    94    2     4"),
	instrForString("absolute      STY oper      8C    3     4"),
	instrForString("implied       TAX           AA    1     2"),
	instrForString("implied       TAY           A8    1     2"),
	instrForString("implied       TSX           BA    1     2"),
	instrForString("implied       TXA           8A    1     2"),
	instrForString("implied       TXS           9A    1     2"),
	instrForString("implied       TYA           98    1     2")]



