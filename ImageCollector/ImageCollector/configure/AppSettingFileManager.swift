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
    
    var dataSource:SettingModel?
    
    override init(){
        super.init()
        defaultSetting()
    }
    
    func initFile() {
        self.dataSource = SettingModel(location: basePath, tags: nil)
        self.updateFile()
    }
    
    private func readFile() {
        do {
            let data = try Data(contentsOf:  self.settingFileURL)
            let decoder = PropertyListDecoder()
            self.dataSource = try decoder.decode(SettingModel.self, from: data)
        } catch let err {
            print("erro occured! \(err.localizedDescription)")
        }
    }
    
    func getDataSource() -> [TagModel] {
        self.readFile()
        
        guard self.dataSource?.tags != nil else {
            return []
        }
        
        self.dataSource?.tags?.sort(by: {$0.idx < $1.idx})
        
        return (self.dataSource?.tags)!
    }
    
    func setDataSource(tagName: String) {
        
    }
    
    func setDataSource(data: [TagModel]) {
        
        self.dataSource?.tags = []
        
        var fileList:[String] = []
        
        do {
            fileList = try FileManager.default.contentsOfDirectory(atPath: basePath)
            
            for (idx, tag) in data.enumerated() {
                tag.idx = idx
                tag.reArrangeChild()
                self.dataSource?.tags?.append(tag)
            }
            
            if let keys = self.dataSource?.getAllTagKeys() {
                
                for file in fileList {
                    let fileName  = String(file.split(separator: ".")[0])
                    if !keys.contains(fileName) {
                        if fileName == "settings" {
                            continue
                        }
                        debugPrint("fileName:\(fileName) doesn't belong to plist. delete it!")
                        try FileManager.default.removeItem(atPath: basePath + "/" + file)
                    }
                }
                
            }
        } catch (let err) {
            print("file error : \(err)")
        }
       
        self.updateFile()
    }
    
    func updateFile() {
        do  {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            let data = try encoder.encode(self.dataSource)
            try data.write(to: settingFileURL, options: .atomic)
        }catch (let err){
            print(err.localizedDescription)
        }
    }
    
    private func defaultSetting() {
        basePath = UserDefaults.standard.string(forKey: UserDefaultKeys.filePath)!
        settingFileURL = URL(fileURLWithPath: basePath).appendingPathComponent("settings.plist")
        
        
    }
    
    func moveFile(oldPath: URL) {
        do {
            
            self.defaultSetting()
            try FileManager.default.moveItem(at: oldPath, to: self.settingFileURL)
            
        } catch (let err) {
            print("file error : \(err)")
        }
        
    }

}
