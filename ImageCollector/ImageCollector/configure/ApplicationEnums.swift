//
//  ApplicationEnums.swift
//  ImageCollector
//
//  Created by NHNEnt on 25/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Foundation

enum Appearance {
    static let maxDimension: CGFloat = 350.0
}

enum UserDefaultKeys {
    static let filePath:String = "filePath"
}

enum PropertyListKeys {
    static let defaultLocation:String = "location"
    static let tagCollection:String = "tags"
    
    static let tagCollectionIDName: String = "name"
    static let tagCollectionIDKey: String = "key"
    static let tagCollectionIDIdx: String = "idx"
    static let tagCollectionIDChilds: String = "childs"
}

enum InterfaceStyle : String {
    case Dark, Light
    
    init() {
        let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        self = InterfaceStyle(rawValue: type)!
    }
}
