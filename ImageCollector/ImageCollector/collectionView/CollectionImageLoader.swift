//
//  CollectionImageLoader.swift
//  ImageCollector
//
//  Created by NHNEnt on 31/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

//section 안씀
class CollectionImageLoader: NSObject {

    private var fileList = [SourceModel]()
    var dataSource = [ItemFile]()
    
    var fileManager: TagFileManager?
    
    //웹뷰용
    func fetchData(itemList: [String], type: SourceType) {
        dataSource.removeAll()
        fileList.removeAll()

        for item in itemList {
            dataSource.append(ItemFile(item: item, tagName: "", type: type))
            fileList.append(SourceModel(source: item, description: "", type: type.rawValue))
        }
    }
    
    //파일용
    func fetchData(fileName: String) {
        fileManager = TagFileManager(tagKey: fileName)
        fileList = fileManager!.getData()
        
        dataSource.removeAll()
        
        fileList.forEach { (model) in
            dataSource.append(ItemFile(item: model.itemSource,
                                       tagName: fileName,
                                       type: SourceType.init(rawValue: model.type!)!))
        }
    }
    
    func addItem(url: String, desc: String, type: SourceType) {
        fileList.append(SourceModel(source: url, description: desc, type: type.rawValue))
        dataSource.append(ItemFile(item: url,
                                   tagName: fileManager!.fileURL.lastPathComponent,
                                   type: type))
        
        self.fileManager!.setData(data: self.fileList)
    }
    
    func deleteItem(idx: [Int]) {
     
        idx.forEach { (index) in
            fileList.remove(at: index)
            dataSource.remove(at: index)
        }
        
        self.fileManager?.setData(data: self.fileList)
    }
    
    func updateItem(idx: Int, dat: String) {
        fileList[idx].description = dat
        
        self.fileManager?.setData(data: self.fileList)
    }
    
    func numberOfSection() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return dataSource.count
    }
    
    func imageForIndexPath(indexPath: IndexPath) -> ItemFile {
        return dataSource[indexPath.item]
    }
    
    func imageURLForIdexPath(indexPath: IndexPath) -> SourceModel {
        return fileList[indexPath.item]
    }
}
