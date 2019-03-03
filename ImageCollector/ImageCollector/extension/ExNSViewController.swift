//
//  ExNSViewController.swift
//  ImageCollector
//
//  Created by saera on 03/03/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class ExNSViewController: NSViewController {

    let collectionImageLoader = CollectionImageLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    /// displays an error
    func handleError(_ error: Error) {
        OperationQueue.main.addOperation {
            if let window = self.view.window {
                self.presentError(error, modalFor: window, delegate: nil, didPresent: nil, contextInfo: nil)
            } else {
                self.presentError(error)
            }
        }
    }

}


extension ExNSViewController: NSCollectionViewDataSource {
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return collectionImageLoader.numberOfSection()
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionImageLoader.numberOfItemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"), for: indexPath)
        
        guard let collectionViewItem = item as? CollectionViewItem else {
            return item
        }
        
        let imageFile = collectionImageLoader.imageForIndexPath(indexPath: indexPath)
        collectionViewItem.imageFile = imageFile
        collectionViewItem.toggleSelect(stat: collectionViewItem.isSelected)
        collectionViewItem.layoutIndicator()
        return item
    }
}

extension ExNSViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        indexPaths.forEach { (indexPath) in
            if let item = collectionView.item(at: indexPath) as? CollectionViewItem {
                item.toggleSelect(stat: true)
            }
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        indexPaths.forEach { (indexPath) in
            if let item = collectionView.item(at: indexPath) as? CollectionViewItem {
                item.toggleSelect(stat: false)
            }
        }
    }
}
