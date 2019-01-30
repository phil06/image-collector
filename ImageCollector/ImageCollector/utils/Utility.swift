//
//  Utility.swift
//  ImageCollector
//
//  Created by saera on 28/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class Utility: NSObject {
    
    static let shared = Utility()
    
    //https://learningswift.brightdigit.com/swift-4-2-random-changes-wwdc-2018/
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    func getCurrentDateFormat(format: String) -> String {
        let now = Date()
        
        let date = DateFormatter()
        date.locale = Locale(identifier: "ko_kr")
        date.timeZone = TimeZone(abbreviation: "KST")
        date.dateFormat = format
        
        return date.string(from: now)
    }
    
    func getTagKey() -> String {
        return String.init(format: "%@-%@",
                           Utility.shared.randomString(length: 10),
                           Utility.shared.getCurrentDateFormat(format: DateFormats.yyyyMMddHHmmss))
    }
}
