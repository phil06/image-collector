//
//  ImageListModel.swift
//  ImageCollector
//
//  Created by NHNEnt on 30/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class ImageListModel: Codable {
    var imageUrl: String
    var description: String
    
    init(imageUrl: String, description: String) {
        self.imageUrl = imageUrl
        self.description = description
    }
}
