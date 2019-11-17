//
//  EnlargeImageViewController.swift
//  ImageCollector
//
//  Created by NHNEnt on 18/02/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa
import SDWebImage

class EnlargeImageViewController: NSViewController, NSWindowDelegate, NSOpenSavePanelDelegate {

    let maxWidth: CGFloat = 750
    let maxHeight: CGFloat = 600
    let minSize: CGFloat = 400
    let minWindowWidth: CGFloat = 450
    
    var tagName: String!

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var zoomInBtn: NSButton!
    @IBOutlet weak var zoomOutBtn: NSButton!
    @IBOutlet weak var download: NSButton!
    
    @IBOutlet weak var menuBackgroundView: NSView!
    @IBOutlet weak var menuViewConst: NSLayoutConstraint!
    
    var magnification: CGFloat?
    var imageView: NSImageView?
    var imageUrl: String!
    var isShownFloatingMenu: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        let options: NSTrackingArea.Options = [.mouseMoved, .activeAlways]
        let trackingArea = NSTrackingArea(rect: self.view.bounds, options: options, owner: self, userInfo: nil)
        self.view.addTrackingArea(trackingArea)
        
        menuBackgroundView.wantsLayer = true
        menuBackgroundView.layer?.backgroundColor = NSColor.black.cgColor
        menuBackgroundView.layer?.opacity = 0.7
    }

    func setImage(imageFile: ItemFile) {
        imageUrl = imageFile.fileUrl
        
        var image = NSImage(contentsOf: URL(string: imageUrl)!)!

        if let repImage = (image.representations as? [NSBitmapImageRep])?.first {
            let cgImage = repImage.cgImage!
            image = NSImage(cgImage: cgImage, size: NSSize.zero)
        }
        
//        imageView = NSImageView(image: image)
        imageView = NSImageView(image: imageFile.thumbnail!)
        imageView?.image?.size = image.size
        imageView!.animates = true
        imageView!.frame.size = image.size

        estimateFrameSize(viewSize: image.size)

        layoutSubviews()
    }
    
    func layoutSubviews() {
        scrollView?.contentView = CenteredClipView()
        scrollView?.documentView = imageView
    }
    
    func estimateFrameSize(viewSize: NSSize) {
        let adjustWidth: CGFloat = viewSize.width > maxWidth ? maxWidth : (viewSize.width < minWindowWidth ? minWindowWidth : viewSize.width)
        let adjustHeight: CGFloat = viewSize.height > maxHeight ? maxHeight : (viewSize.height < minSize ? minSize : viewSize.height)
        
        view.frame = CGRect.init(x: 0.0, y: 0.0, width: adjustWidth, height: adjustHeight)
        debugPrint("adjusted size width:\(adjustWidth), height:\(adjustHeight)")
    }

    override func mouseUp(with event: NSEvent) {
        view.window?.performClose(self)
    }
    
    override func mouseMoved(with event: NSEvent) {
        
        guard let locWindow = self.view.window, NSApplication.shared.keyWindow === locWindow else {
            return
        }
 
        if event.locationInWindow.y <= 60, menuViewConst.constant > 0 {
            isShownFloatingMenu = true
            return
        } else if event.locationInWindow.y > 60, menuViewConst.constant < 0 {
            isShownFloatingMenu = false
            return
        }
        
        toggleFloatingMenu()
    }
    
    func toggleFloatingMenu() {
        isShownFloatingMenu = isShownFloatingMenu ?? false ? false : true
        
        NSAnimationContext.runAnimationGroup( { context in
            context.allowsImplicitAnimation = true
            menuViewConst.constant = isShownFloatingMenu ?? false ? -60 : 1
            self.view.layoutSubtreeIfNeeded()
        })
    }
    
    @IBAction func zoomIn(_ sender: Any) {
        self.magnification = (magnification ?? 1) + 0.25
        scrollView.magnification = magnification!
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        self.magnification = (magnification ?? 1) - 0.25
        scrollView.magnification = magnification!
    }
    
    @IBAction func download(_ sender: Any) {
        
        let imageUrl = URL(string: self.imageUrl)!
        
        let openPanel = NSSavePanel();
        openPanel.title = "Select a folder to download image"
        openPanel.showsResizeIndicator=true;
        openPanel.canCreateDirectories = true;
        openPanel.delegate = self
        openPanel.nameFieldStringValue = imageUrl.lastPathComponent
        
        openPanel.runModal()
    }
    
    
    func panel(_ sender: Any, validate url: URL) throws {
        
        let imgUrl = URL(string: self.imageUrl)!
        
        let saveFile = { (data: Data) in
            do {
                try data.write(to: url, options: .atomic)
            } catch (let err) {
                print("file write failed! >>> \(err.localizedDescription)")
            }
        }
        
        SDWebImageManager.shared.imageCache.queryImage(forKey: imgUrl.makeCacheKey(tagName: tagName), options: .queryMemoryData, context: nil, completion: { (image, data, type) in
            if let downloadedImage = data {
                saveFile(downloadedImage)
            } else {
                SDWebImageManager.shared.loadImage(with: imgUrl , options: [ .fromCacheOnly, .queryMemoryData], progress: { (a, b, url) in
                    
                }, completed: { (image, data, error, type, bool, fileurl) in
                    saveFile(data!)
                })
            }
        })
        
    }
    
    
    
}



final class CenteredClipView: NSClipView {
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

