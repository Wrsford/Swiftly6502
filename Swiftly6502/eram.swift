//
//  eram.swift
//  SwiftlyARM
//
//  Created by Will Stafford on 7/26/15.
//  Copyright © 2015 Wrsford. All rights reserved.
//

import Foundation

class eram {
	var name : String?
	var graphicsCallbacks = [Any]()
	
	var gpu = egpu()
	
	var vramLocation = 0x200
	var vramSize: Int
	
	fileprivate var memory : [Int]
	
	init(theName: String = "Emulated Ram") {
		name = theName
		memory = [Int](repeating: 0, count: 0xFFFF) // Memory is 64KB
		vramSize = gpu.screenHeight * gpu.screenWidth
	}
	
	var stack = [Int](repeating: 0, count: 256)
	
	func loadData(_ data: [Int], startAddress addr: Int) {
		var off = addr
		for i in data {
			self[off] = i
			off += 1
		}
	}
	
	subscript (address: Int) -> Int {
		get {
			return memory[address]
		}
		set(value) {
			memory[address] = value
			
			if graphicsCallbacks.count != 0 {
				
					//print("Modifying pixel: \(")
					for g in graphicsCallbacks {
						(g as! (Int) -> Void)(0x200)
					}
				}
			}
			
		}
	}
