//
//  SettingModel.swift
//  ImageCollector
//
//  Created by NHNEnt on 30/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Foundation

class SettingModel: Codable {
    var location: String
    var tags: [TagModel]?
    
    init(location: String, tags: [TagModel]?) {
        self.location = location
        self.tags = tags
    }
}

class TagModel: Codable {
    var name: String
    var key: String
    var idx: Int
    var childs: [TagModel]?
    
    init() {
        self.name = ""
        self.key = ""
        self.idx = 0
        self.childs = []
    }

    
    init(name: String, idx: Int) {
        self.name = name
        self.idx = idx
        self.childs = []
        self.key = Utility.shared.getTagKey()
    }
    
    func reArrangeChild() {
        if let child = self.childs {
            
            var tempChilds: [TagModel] = []
            
            for (idx, tag) in child.enumerated() {
                let newTag = tag
                newTag.idx = idx
                newTag.reArrangeChild()
                tempChilds.append(newTag)
            }
            
            self.childs = tempChilds
        }
    }
    
    func deleteChild(key: String) {
        if let child = self.childs {
            
            var targetIdx = 0
            
            for (idx, tag) in child.enumerated() {
                if tag.key == key {
                    targetIdx = idx
                    break
                }
            }
            
            self.childs?.remove(at: targetIdx)
        }
    }
}
