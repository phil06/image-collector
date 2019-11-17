//
//  ExNotification.swift
//  ImageCollector
//
//  Created by NHNEnt on 01/02/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

extension Notification.Name {
    static let DidCompleteLoadImage = Notification.Name("DidCompleteLoadImage")
    static let AddImageToTagCollection = Notification.Name("AddImageToTagCollection")
    static let DidCompleteAddImageToTagCollection = Notification.Name("DidCompleteAddImageToTagCollection")
    
    static let WillUpdateCollectionItemDescription = Notification.Name("WillUpdateItem")
}
