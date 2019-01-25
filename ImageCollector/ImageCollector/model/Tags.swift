//
//  Tags.swift
//  ImageCollector
//
//  Created by NHNEnt on 25/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class Tags: NSObject {
    var name: String
    var key: String
    var childs:[String:Any]?
    
    init(name: String, key: String, child: [String:Any]?) {
        self.name = name
        self.key = key
        self.childs = child
    }
}
