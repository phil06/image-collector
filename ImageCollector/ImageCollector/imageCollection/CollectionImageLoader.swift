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
    
    func fetchData(fileName: String) {
        fileManager = TagFileManager(tagKey: fileName)
        imageList = fileManager!.getData()
        
        dataSource.removeAll()
        
        imageList.forEach { (model) in
            dataSource.append(ImageFile(url: URL.init(string: model.imageUrl)!, tagName: fileName))
        }
    }
    
    func addItem(url: String, desc: String) {
        
        //MARK: 처음 저장할때(파일이 없을떄)에 대한 대응이 필요함 파일매니저가 nil 이거나 할테이니...
        

        imageList.append(ImageListModel(imageUrl: url, description: desc))
        dataSource.append(ImageFile(url: URL.init(string: url)!, tagName: fileManager!.fileURL.lastPathComponent))
        
        self.fileManager!.setData(data: self.imageList)
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
    
}
