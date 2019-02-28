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
    
    var zoomIn: NSButton!
    var zoomOut: NSButton!
    
    let maxWidth: CGFloat = 750
    let maxHeight: CGFloat = 600
    
    override func loadView() {
        self.view = NSView()
        
        self.view.window?.styleMask.remove(.titled)

        zoomIn = NSButton(image: NSImage(named: NSImage.enterFullScreenTemplateName)!, target: self, action: #selector(zoomInScrollView))
        zoomIn.setButtonType(.momentaryLight)
        zoomIn.title = "ZoomIn"
        zoomIn.imagePosition = .imageLeading
        zoomIn.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(zoomIn)
        
        zoomOut = NSButton(image: NSImage(named: NSImage.exitFullScreenTemplateName)!, target: self, action: #selector(zoomOutScrollView))
        zoomOut.setButtonType(.momentaryLight)
        zoomOut.title = "ZoomOut"
        zoomOut.imagePosition = .imageLeading
        zoomOut.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(zoomOut)
        
        
        
        //기본사이즈
        view.frame = CGRect.init(x: 0, y: 0, width: 300, height: 300)
        
        //스크롤뷰 오토레이아웃 적용해주기
        
        
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { (event) -> NSEvent? in
            self.mouseUp(with: event)
            return event
        }
    }
    
    @objc func zoomInScrollView() {
        debugPrint("zoom in ...")
         scrollView?.magnification = 2
    }
    
    @objc func zoomOutScrollView() {
        debugPrint("zoom out ...")
         scrollView?.magnification = 0.5
    }
    
    func setImage(imageFile: ImageFile) {
        let image = imageFile.thumbnail!
        imageView = NSImageView(image: image)
        imageView!.frame.size = image.size
        
        estimateFrameSize(viewSize: image.size)
        
        scrollView = NSScrollView(frame: view.frame)
        scrollView?.contentView = CenteringClipView()
        scrollView?.documentView = imageView
        view.addSubview(scrollView!)
        
        layoutSubviews()
    }
    
    func estimateFrameSize(viewSize: NSSize) {
        view.frame = CGRect.init(x: 0.0, y: 0.0, width: viewSize.width > maxWidth ? maxWidth : viewSize.width, height: viewSize.height > maxHeight ? maxHeight : viewSize.height)
    }
    
    func layoutSubviews() {
        
        imageView?.animates = true
        
        scrollView?.backgroundColor = NSColor.clear
        scrollView?.allowsMagnification = true
        scrollView?.minMagnification = 0.1
        scrollView?.maxMagnification = 3.0
        scrollView?.magnification = 1
        scrollView?.translatesAutoresizingMaskIntoConstraints = false
        
        var allConstraints: [NSLayoutConstraint] = []

        let constraint1 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[zoomIn(==32)]-0-[scrollView]-0-|",  metrics: nil, views: ["scrollView": scrollView!,
                                                                                                                                             "zoomIn": zoomIn])
        allConstraints += constraint1
        let constraint2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[scrollView]-0-|",  metrics: nil, views: ["scrollView": scrollView!])
        allConstraints += constraint2
        let constraint3 = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[zoomIn(==100)]-20-[zoomOut(==100)]",  metrics: nil, views: ["zoomIn": zoomIn,
                                                                                                                                                   "zoomOut": zoomOut])
        allConstraints += constraint3
        let constraint4 = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[zoomOut(==32)]",  metrics: nil, views: ["zoomOut": zoomOut])
        allConstraints += constraint4
        
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    
    
    override func mouseUp(with event: NSEvent) {
        view.window?.performClose(self)
    }
    
}

final class CenteringClipView: NSClipView {
    override func constrainBoundsRect(_ proposedBounds: NSRect) -> NSRect {
        var constrainedClipViewBounds = super.constrainBoundsRect(proposedBounds)

        guard let documentView = documentView else {
            return constrainedClipViewBounds
        }

        let documentViewFrame = documentView.frame

        // If proposed clip view bounds width is greater than document view frame width, center it horizontally.
        if documentViewFrame.width < proposedBounds.width {
            constrainedClipViewBounds.origin.x = floor((proposedBounds.width - documentViewFrame.width) / -2.0)
        }

        // If proposed clip view bounds height is greater than document view frame height, center it vertically.
        if documentViewFrame.height < proposedBounds.height {
            constrainedClipViewBounds.origin.y = floor((proposedBounds.height - documentViewFrame.height) / -2.0)
        }

        return constrainedClipViewBounds
    }
}
