//
//  PanelManager.swift
//  ImageCollector
//
//  Created by saera on 28/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class PanelManager: NSObject {
    static let shared = PanelManager()
 
    func openDefaultPathPanel() -> String? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        
        if panel.runModal() == NSApplication.ModalResponse.OK {
            if let result = panel.url {
                let path = result.path
                UserDefaults.standard.set(path, forKey: UserDefaultKeys.filePath)
                
                AppSettingFileManager.shared.initFile()
                
                return path
            }
        }
        
        return nil
    }
}
