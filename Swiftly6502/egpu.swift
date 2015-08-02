//
//  egpu.swift
//  Swiftly6502
//
//  Created by Will Stafford on 8/1/15.
//  Copyright © 2015 Wrsford. All rights reserved.
//

import Foundation

var palette = [
	"000000", "ffffff", "880000", "aaffee",
	"cc44cc", "00cc55", "0000aa", "eeee77",
	"dd8855", "664400", "ff7777", "333333",
	"777777", "aaff66", "0088ff", "bbbbbb"
]

func getRGBFor6502(color: Int) -> (r: UInt8, g: UInt8, b: UInt8) {
	
	
	let base = Int(palette[color & 0x0f], radix: 16)!
	
	let r = (base >> 16) & 0xff
	let g = (base >> 8) & 0xff
	let b = (base) & 0xff
	
	return (UInt8(r), UInt8(g), UInt8(b))
}

class egpu {
	
}