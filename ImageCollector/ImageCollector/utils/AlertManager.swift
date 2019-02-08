//
//  AlertManager.swift
//  ImageCollector
//
//  Created by saera on 27/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class AlertManager: NSObject {

    static let shared = AlertManager()
    
    override init(){
    }
    
    func showAddTagAlert(messageText: String,
                                   infoText: String,
                                   okTitle: String, cancelTitle: String,
                                   suppressionTitle: String?) -> [String:Any]? {
        let alert = NSAlert()
        
        alert.alertStyle = .informational
        alert.messageText = messageText
        alert.informativeText = infoText
        
        
        if let title = suppressionTitle {
            alert.showsSuppressionButton = true
            alert.suppressionButton?.title = title
        }
        
        alert.addButton(withTitle: okTitle)
        alert.addButton(withTitle: cancelTitle)
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = input
        alert.window.initialFirstResponder = input
        
        let button = alert.runModal()
        
        if button == NSApplication.ModalResponse.alertFirstButtonReturn {
            
            var result:[String:Any] = [:]
            
            if alert.suppressionButton?.state == NSControl.StateValue.on {
                result["suppression"] = true
            }
            
            input.validateEditing()
            result["input"] = input.stringValue
            return result
        }
        
        return nil
    }
    
    func confirmDeleteTag() -> Bool {
        let alert = NSAlert()
        
        alert.alertStyle = .warning
        alert.messageText = "하위 태그가 존재할 경우 함께 삭제됩니다. 삭제하겠습니까?"
        alert.addButton(withTitle: "예")
        alert.addButton(withTitle: "아니오")
        
        let button = alert.runModal()
        
        return button == NSApplication.ModalResponse.alertFirstButtonReturn
    }
    
    func infoMessage(messageTitle: String) {
        let alert = NSAlert()
        
        alert.alertStyle = .warning
        alert.messageText = messageTitle
        
        alert.runModal()
    }
}
