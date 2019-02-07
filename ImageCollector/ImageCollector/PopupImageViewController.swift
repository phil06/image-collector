//
//  PopupImageViewController.swift
//  ImageCollector
//
//  Created by NHNEnt on 07/02/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class PopupImageViewController: NSViewController {
    
    var imageView: NSImageView?
    var scrollView: NSScrollView?
    
    let maxWidth: CGFloat = 750
    let maxHeight: CGFloat = 600
    
    override func loadView() {
        self.view = NSView()
        imageView?.animates = true
        
        //기본사이즈
        view.frame = CGRect.init(x: 0, y: 0, width: 300, height: 300)
        
        //스크롤뷰 오토레이아웃 적용해주기
        
    }
    
    func setImage(imageFile: ImageFile) {
        let image = imageFile.thumbnail!
        imageView = NSImageView(image: image)
        imageView!.frame.size = image.size
        
        debugPrint("image original size : \(image.size)")
        
        estimateFrameSize(viewSize: image.size)
        
        scrollView = NSScrollView(frame: view.frame)
        scrollView?.documentView = imageView
        view.addSubview(scrollView!)
    }
    
    func estimateFrameSize(viewSize: NSSize) {
        debugPrint("width : \(viewSize.width)")
        debugPrint("height : \(viewSize.height)")
        
        view.frame = CGRect.init(x: 0.0, y: 0.0, width: viewSize.width > maxWidth ? maxWidth : viewSize.width, height: viewSize.height > maxHeight ? maxHeight : viewSize.height)
    }
    
}
