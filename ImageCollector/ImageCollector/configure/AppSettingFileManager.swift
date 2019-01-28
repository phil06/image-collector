//
//  AppSettingFileManager.swift
//  ImageCollector
//
//  Created by NHNEnt on 25/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class AppSettingFileManager: NSObject {
    
    static let shared = AppSettingFileManager()
    
    var basePath: String!
    var settingFileURL: URL!
    
    var data:[String:Any] = [:]
    
    override init(){
        basePath = UserDefaults.standard.string(forKey: UserDefaultKeys.filePath)!
        settingFileURL = URL(fileURLWithPath: basePath).appendingPathComponent("settings.plist")
    }
    
    func initFile() {
        data[PropertyListKeys.defaultLocation] = basePath
        self.updateFile()
    }
    
    private func readFile() {
        data = NSDictionary(contentsOfFile: settingFileURL.path) as! [String : Any]
        debugPrint("result plist >>> \(data)")
    }
    
    //data는 딕셔너리로 가지고 있고... 다른데서 쓸때 필요한 모델을 따로 둬야 하는건가...???
    //그리고 저장/읽어들일때만 변환을 해야 하나봥..
    
    func addField() {
        self.readFile()
        
        //data 딕셔너리를 업데이트
        
                var tags = [Tags]()
        //
        //
        //
        //        //MARK: 계층구조를 어떻게 만들지???? 고민좀 해봐야 함...
                let tagsDic = ["2019":[:],
                               "2018": [ "4월":[:], "5월":[:], "6월":[:], "7월":[:], "8월":[:] ],
                               "2016": [ "11월":[:], "12월":[:] ],
                               "2015":[:]]
        //
//                for (key, val) in tagsDic {
//                    let newItem = Tags(name: key, child: val)
//                    tags.append(newItem)
//                }
        //
        //        debugPrint("tags >>> \(tags)")
        
        data[PropertyListKeys.tagCollection] = tagsDic
        
        self.updateFile()
    }
    
    func convertTagData(data: [Tags]) {
        var tempData:[String:Any] = [:]
        for (idx, item) in data.enumerated() {
            tempData[item.name] = item.getForMigration(newIdx: idx)
        }
        
        self.data[PropertyListKeys.tagCollection] = tempData
        
        self.updateFile()
    }
    
    func readConvertedTagData() -> [Tags] {
        self.readFile()
        
        guard self.data[PropertyListKeys.tagCollection] != nil else {
            return []
        }
        
        var tags = [Tags]()
        
        for (_, val) in data[PropertyListKeys.tagCollection] as! [String : Any] {
            let dat = val as! [String:Any]
            
            
            let newItem: Tags
            newItem = Tags(name: dat[PropertyListKeys.tagCollectionIDName] as! String,
                           idx: dat[PropertyListKeys.tagCollectionIDIdx] as! Int,
                           key: dat[PropertyListKeys.tagCollectionIDKey] as! String,
                           child: dat[PropertyListKeys.tagCollectionIDChilds] as? [String:Any])
            
            tags.append(newItem)
        }
        
        tags.sort(by: {$0.idx < $1.idx})

        return tags
    }
    
    private func updateFile() {
        do  {
            let resultFile = try PropertyListSerialization.data(fromPropertyList: data, format: PropertyListSerialization.PropertyListFormat.xml, options: 0)
            do {
                try resultFile.write(to: settingFileURL, options: .atomic)
                print("Successfully write")
            }catch (let err){
                print(err.localizedDescription)
            }
        }catch (let err){
            print(err.localizedDescription)
        }
    }

}
