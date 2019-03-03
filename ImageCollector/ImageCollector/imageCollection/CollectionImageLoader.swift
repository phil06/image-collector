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

    private var imageList = [ImageListModel]()
    var dataSource = [ImageFile]()
    
    var fileManager: TagFileManager?
    
    //웹뷰용
    func fetchData(urlList: [String]) {
        dataSource.removeAll()
        imageList.removeAll()

        for url in urlList {
            dataSource.append(ImageFile(url: URL.init(string: url)!, tagName: ""))
            imageList.append(ImageListModel(imageUrl: url, description: ""))
        }
    }
    
    //파일용
    func fetchData(fileName: String) {
        fileManager = TagFileManager(tagKey: fileName)
        imageList = fileManager!.getData()
        
        dataSource.removeAll()
        
        imageList.forEach { (model) in
            dataSource.append(ImageFile(url: URL.init(string: model.imageUrl)!, tagName: fileName))
        }
    }
    
    func addItem(url: String, desc: String) {
        imageList.append(ImageListModel(imageUrl: url, description: desc))
        dataSource.append(ImageFile(url: URL.init(string: url)!, tagName: fileManager!.fileURL.lastPathComponent))
        
        self.fileManager!.setData(data: self.imageList)
    }
    
    func deleteItem(idx: [Int]) {
     
        idx.forEach { (index) in
            imageList.remove(at: index)
            dataSource.remove(at: index)
        }
        
        self.fileManager?.setData(data: self.imageList)
    }
    
    func numberOfSection() -> Int {
        return 1
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        return dataSource.count
    }
    
    func imageForIndexPath(indexPath: IndexPath) -> ImageFile {
        return dataSource[indexPath.item]
    }
    
    func imageURLForIdexPath(indexPath: IndexPath) -> ImageListModel {
        return imageList[indexPath.item]
    }
}
