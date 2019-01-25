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
        
        do  {
            let resultFile = try PropertyListSerialization.data(fromPropertyList: data, format: PropertyListSerialization.PropertyListFormat.binary, options: 0)
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
