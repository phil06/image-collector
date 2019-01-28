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
    var idx: Int
    var childs:[Tags]?

    override init() {
        self.name = ""
        self.key = ""
        self.idx = 0
        self.childs = nil
    }
    
    convenience init(name: String, idx: Int) {
        self.init()
        self.name = name
        self.key = makeKey()
        self.idx = idx
        self.childs = []
    }
    
    convenience init(name: String, idx: Int, key: String, child: [String:Any]?) {
        self.init()
        self.name = name
        self.key = key
        self.idx = idx
        self.childs = []
        
        if !(child?.isEmpty)! {
            for (_, val) in child! {
                let dat = val as! [String:Any]
                let newItem = Tags(name: dat[PropertyListKeys.tagCollectionIDName] as! String,
                                   idx: dat[PropertyListKeys.tagCollectionIDIdx] as! Int,
                                   key: dat[PropertyListKeys.tagCollectionIDKey] as! String,
                                   child: dat[PropertyListKeys.tagCollectionIDChilds] as? [String : Any])
                self.childs?.append(newItem)
            }
        }
        
        self.childs?.sort(by: {$0.idx < $1.idx})
    }
    
    func getForMigration(newIdx: Int) -> [String:Any] {
        
        var tempChilds: [String:Any] = [:]
        
        if !(self.childs?.isEmpty)! {
            for (idx, item) in (self.childs?.enumerated())! {
                tempChilds[item.name] = item.getForMigration(newIdx: idx)
            }
        }
        
        return [PropertyListKeys.tagCollectionIDName : self.name,
                PropertyListKeys.tagCollectionIDKey : self.key,
                PropertyListKeys.tagCollectionIDIdx : newIdx,
                PropertyListKeys.tagCollectionIDChilds : tempChilds]
    }
    
    func deleteChild(key: String) {
        var deleteTargetIdx = 0
        for (idx, child) in (self.childs?.enumerated())! {
            if child.key == key {
                deleteTargetIdx = idx
                break
            }
        }
        self.childs?.remove(at: deleteTargetIdx)
    }

    private func makeKey() -> String {
        return String.init(format: "%@-%@",
                    Utility.shared.randomString(length: 10),
                    Utility.shared.getCurrentDateFormat(format: DateFormats.yyyyMMddHHmmss))
    }
}
