//
//  ImageListModel.swift
//  ImageCollector
//
//  Created by NHNEnt on 30/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

enum SourceType: String {
    case IMAGE = "IMG"
    case VIDEO = "MOV"
}

class SourceModel: Codable {
    var itemSource: String
    var description: String
    var type: String?
    
    init(source: String, description: String, type: String = SourceType.IMAGE.rawValue) {
        self.itemSource = source
        self.description = description
        self.type = type
    }

}
