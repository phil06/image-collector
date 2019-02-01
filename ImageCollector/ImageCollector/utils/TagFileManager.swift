//
//  TagFileManager.swift
//  ImageCollector
//
//  Created by NHNEnt on 30/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class TagFileManager: NSObject {
    
    var key: String
    var fileURL: URL
    var data: [ImageListModel]
    
    init(tagKey: String) {
        self.key = tagKey
        //파일 생성
        
        let basePath = UserDefaults.standard.string(forKey: UserDefaultKeys.filePath)!
        self.fileURL = URL(fileURLWithPath: basePath).appendingPathComponent("\(tagKey).json")
        
        self.data = []
    }
    
    func setData(data: [ImageListModel]) {
        self.data = data
        self.update()
    }
    
    func getData() -> [ImageListModel] {
        self.read()
        return self.data
    }
    
    private func update() {
        do  {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self.data)
            try data.write(to: fileURL, options: .atomic)
        }catch (let err){
            print(err.localizedDescription)
        }
    }
    
    private func read() {
        do {
            let data = try Data(contentsOf:  self.fileURL)
            let decoder = JSONDecoder()
            self.data = try decoder.decode([ImageListModel].self, from: data)
        } catch let err {
            print("\(err.localizedDescription)")
        }
    }
    
    
}
