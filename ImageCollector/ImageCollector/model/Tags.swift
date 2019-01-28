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
    
    //MARK: 키도 다 직접 받는거로 나중엔 바꾸자...
    convenience init(name: String, idx: Int, child: [String:Any]?) {
        self.init()
        self.name = name
        self.key = String.init(format: "%@-key", name)
        self.idx = idx
        self.childs = []
        
        if !(child?.isEmpty)! {
            for (key, val) in child! {
                let dat = val as! [String:Any]
                let newItem = Tags(name: dat[PropertyListKeys.tagCollectionIDName] as! String,
                                   idx: dat[PropertyListKeys.tagCollectionIDIdx] as! Int,
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
}
