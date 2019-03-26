//
//  ViewController.swift
//  Swiftly6502
//
//  Created by Will Stafford on 7/31/15.
//  Copyright © 2015 Wrsford. All rights reserved.
//

import UIKit

struct PixelData {
	var a:UInt8 = 255
	var r:UInt8
	var g:UInt8
	var b:UInt8
}

class ViewController: UIViewController {
	
	@IBOutlet weak var wButton: UIButton!
	@IBOutlet weak var aButton: UIButton!
	@IBOutlet weak var sButton: UIButton!
	@IBOutlet weak var dButton: UIButton!
	
	@IBOutlet weak var screenView: UIImageView!
	
	
	var cpu6502 = scpu()
	override func viewDidLoad() {
		super.viewDidLoad()
		screenView.layer.borderColor = UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
		screenView.layer.borderWidth = 2.0
		
		/*let data = NSData.dataWithContentsOfMappedFile("/Users/wrsford/Downloads/Metroid Source Code/MetroidBrinstarPage.o")!
		
		let count = data.length / sizeof(UInt8)
		
		// create array of appropriate length:
		var array = [UInt8](count: count, repeatedValue: 0)
		
		// copy bytes into array
		data.getBytes(&array, length:count * sizeof(UInt8))
		var real = [Int]()
		for (var i = 0; i < array.count; i++) {
			real.append(Int(array[i]))
		}
		
		print(disassemble(real))*/
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		
	}
	@IBAction func startCpu(_ sender: AnyObject) {
		cpu6502 = scpu()
		
		cpu6502.ram.graphicsCallbacks.append(updateScreen)
		
		//let documentsPath = String(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString)
		var filestuff: String
		do {
			try filestuff = String(contentsOfFile: Bundle.main.path(forResource: "test", ofType: "6502")!)
			
		} catch {
			filestuff = ""
			print("File not found")
		}
		
		let asmbr = assembler()
		let binary = asmbr.assemble(filestuff, offset: cpu6502.binaryOffset)
		cpu6502.ram.loadData(binary, startAddress: cpu6502.binaryOffset)
		
		let qualityOfServiceClass = DispatchQoS.QoSClass.background
		let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
		backgroundQueue.async(execute: {
			self.cpu6502.run()
			
		})
	}
	
	fileprivate let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
	fileprivate let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
	
	func imageFromARGB32Bitmap(_ pixels:[PixelData], width:Int, height:Int)->UIImage {
		let bitsPerComponent:UInt = 8
		let bitsPerPixel:UInt = 32
		
		assert(pixels.count == Int(width * height))
		
		var data = pixels // Copy to mutable []
        let providerRef = CGDataProvider(data: NSData(bytes: &data, length: data.count * MemoryLayout<PixelData>.size))
		
		let cgim = CGImage(
			width: width,
			height: height,
			bitsPerComponent: Int(bitsPerComponent),
			bitsPerPixel: Int(bitsPerPixel),
			bytesPerRow: width * 4,
			space: rgbColorSpace,
			bitmapInfo: bitmapInfo,
			provider: providerRef!,
			decode: nil,
			shouldInterpolate: true,
			intent: CGColorRenderingIntent.defaultIntent
		)
		return UIImage(cgImage: cgim!)
	}

	func updateScreen(_ offset: Int) {
		
		let width = 32
		let height = 32
		let len = width * height
		
		var pixData = [PixelData]()
		
		for i in offset ..< offset+len {
			let color = getRGBFor6502(cpu6502.ram[i])
			let thePix = PixelData(a: 0xff, r: color.r, g: color.g, b: color.b)
			pixData.append(thePix)
		}
		
		DispatchQueue.main.async(execute: { () -> Void in
            self.screenView.layer.magnificationFilter = CALayerContentsFilter.nearest
			self.screenView.image = self.imageFromARGB32Bitmap(pixData, width: width, height: height)
		})
		
		
		
	}
	
	@IBAction func someButtonPressed(_ sender: UIButton) {
		if sender == wButton {
			cpu6502.inputKey("w")
		}
			
		else if sender == aButton {
			cpu6502.inputKey("a")
		}
			
		else if sender == sButton {
			cpu6502.inputKey("s")
		}
			
		else if sender == dButton {
			cpu6502.inputKey("d")
		}
	}
	
	func hardwareKeyPressed(_ sender: UIKeyCommand) {
		cpu6502.inputKey(sender.input!)
	}
	
	
	/*override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	override var keyCommands: [UIKeyCommand] {
		get {
			let theCMDs: [UIKeyCommand] = [
			UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: 0, action: "hardwareKeyPressed:", discoverabilityTitle: "blah"),
			UIKeyCommand(input: "w" as NSString, modifierFlags: 0, action: "hardwareKeyPressed:", discoverabilityTitle: "blah"),
			UIKeyCommand(input: "w" as NSString, modifierFlags: 0, action: "hardwareKeyPressed:", discoverabilityTitle: "blah")
			]
			return theCMDs
		}
	}*/
	
}

