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
	var cpu6502 = scpu()
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		
	}
	@IBAction func startCpu(sender: AnyObject) {
		cpu6502 = scpu()
		
		cpu6502.ram.graphicsCallbacks.append(updateScreen)
		
		let documentsPath = String(NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString)
		var filestuff: String
		do {
			try filestuff = String(contentsOfFile: NSBundle.mainBundle().pathForResource("test", ofType: "6502")!)
			
		} catch {
			filestuff = ""
			print("File not found")
		}
		
		let asmbr = assembler()
		let binary = asmbr.assemble(filestuff, offset: cpu6502.binaryOffset)
		cpu6502.ram.loadData(binary, startAddress: cpu6502.binaryOffset)
		
		let qualityOfServiceClass = QOS_CLASS_BACKGROUND
		let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
		dispatch_async(backgroundQueue, {
			self.cpu6502.run()
			
		})
	}
	
	private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
	private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
	
	func imageFromARGB32Bitmap(pixels:[PixelData], width:Int, height:Int)->UIImage {
		let bitsPerComponent:UInt = 8
		let bitsPerPixel:UInt = 32
		
		assert(pixels.count == Int(width * height))
		
		var data = pixels // Copy to mutable []
		let providerRef = CGDataProviderCreateWithCFData(
			NSData(bytes: &data, length: data.count * 4)
		)
		
		let cgim = CGImageCreate(
			Int(width),
			Int(height),
			Int(bitsPerComponent),
			Int(bitsPerPixel),
			Int(width * sizeof(PixelData)),
			rgbColorSpace,
			bitmapInfo,
			providerRef,
			nil,
			true,
			kCGRenderingIntentDefault
		)
		return UIImage(CGImage: cgim)
	}


	@IBOutlet weak var wButton: UIButton!
	@IBOutlet weak var aButton: UIButton!
	@IBOutlet weak var sButton: UIButton!
	@IBOutlet weak var dButton: UIButton!
	
	@IBOutlet weak var screenView: UIImageView!
	
	func updateScreen(offset: Int) {
		screenView.layer.magnificationFilter = kCAFilterNearest
		let width = 32
		let height = 32
		let len = width * height
		
		var pixData = [PixelData]()
		
		for (var i = offset; i < offset+len; i++) {
			let color = getRGBFor6502(cpu6502.ram[i])
			let thePix = PixelData(a: 0xff, r: color.r, g: color.g, b: color.b)
			pixData.append(thePix)
		}
		
		dispatch_async(dispatch_get_main_queue(), { () -> Void in
			self.screenView.image = self.imageFromARGB32Bitmap(pixData, width: width, height: height)
		})
		
		
		
	}
	
	@IBAction func someButtonPressed(sender: UIButton) {
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
	
	
}

