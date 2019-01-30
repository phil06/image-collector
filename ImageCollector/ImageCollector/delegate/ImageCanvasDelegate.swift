//
//  ImageCanvasDelegate.swift
//  ImageCollector
//
//  Created by NHNEnt on 23/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

@objc protocol ImageCanvasDelegate: AnyObject {
    
    func performDragOperation(forImageCanvas imageCanvas: ImageCanvas, sender: NSDraggingInfo) -> Bool
    
    func draggingEntered(forImageCanvas imageCanvas: ImageCanvas, sender: NSDraggingInfo) -> NSDragOperation
    
    func replacePlaceholder()
}
