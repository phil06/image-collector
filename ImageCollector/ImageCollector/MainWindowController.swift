//
//  MainWindowController.swift
//  ImageCollector
//
//  Created by NHNEnt on 08/02/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }

}
