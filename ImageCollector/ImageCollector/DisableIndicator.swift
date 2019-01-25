//
//  DisableIndicator.swift
//  ImageCollector
//
//  Created by NHNEnt on 25/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class DisableIndicator: NSView {

    @IBOutlet weak var message: NSTextField!
    
    let currentStyle = InterfaceStyle()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.wantsLayer = true
        
        if currentStyle == .Dark {
            self.layer?.backgroundColor = NSColor.init(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
            message.textColor = NSColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        } else {
            self.layer?.backgroundColor = NSColor.init(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
            message.textColor = NSColor.init(red: 1, green: 1, blue: 1, alpha: 0.5)
        }

    }

}
