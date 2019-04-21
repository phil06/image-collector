//
//  EnlargeImageViewController.swift
//  ImageCollector
//
//  Created by NHNEnt on 18/02/2019.
//  Copyright © 2019 tldev. All rights reserved.
//

import Cocoa

class EnlargeImageViewController: NSViewController {

    let maxWidth: CGFloat = 750
    let maxHeight: CGFloat = 600
    let minSize: CGFloat = 300

    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var zoomInBtn: NSButton!
    @IBOutlet weak var zoomOutBtn: NSButton!
    
    @IBOutlet weak var zoomInBtnBottomConst: NSLayoutConstraint!
    
    var magnification: CGFloat?
    var imageView: NSImageView?
    var isShownFloatingMenu: Bool?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
//        self.view.becomeFirstResponder()
//        if scrollView.acceptsFirstResponder {
//            self.scrollView.becomeFirstResponder()
//        }
//        self.view.window?.makeFirstResponder(self.scrollView)
//        self.view.window?.acceptsMouseMovedEvents = true
 
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { (event) -> NSEvent? in
            self.mouseUp(with: event)
            return event
        }
        

        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { (event) -> NSEvent? in
            self.mouseMoved(with: event)
            return event
        }
    }
    
    func setImage(imageFile: ImageFile) {
        let image = imageFile.thumbnail!
        imageView = NSImageView(image: image)
        imageView?.animates = true
        imageView!.frame.size = image.size
        
        
        debugPrint("imageSize : \(image.size)")
        
        estimateFrameSize(viewSize: image.size)

        layoutSubviews()
    }
    
    func layoutSubviews() {
        scrollView?.contentView = CenteredClipView()
        scrollView?.documentView = imageView
    }
    
    func estimateFrameSize(viewSize: NSSize) {
        let adjustWidth: CGFloat = viewSize.width > maxWidth ? maxWidth : (viewSize.width < minSize ? minSize : viewSize.width)
        let adjustHeight: CGFloat = viewSize.height > maxHeight ? maxHeight : (viewSize.height < minSize ? minSize : viewSize.height)
        
        view.frame = CGRect.init(x: 0.0, y: 0.0, width: adjustWidth, height: adjustHeight)
    }

    override func mouseUp(with event: NSEvent) {
        view.window?.performClose(self)
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        
        if event.locationInWindow.y <= 60, zoomInBtnBottomConst.constant > 0 {
            isShownFloatingMenu = true
            return
        } else if event.locationInWindow.y > 60, zoomInBtnBottomConst.constant < 0 {
            isShownFloatingMenu = false
            return
        }
        
        toggleFloatingMenu()
    }
    
    func toggleFloatingMenu() {
        isShownFloatingMenu = isShownFloatingMenu ?? false ? false : true
        
        NSAnimationContext.runAnimationGroup( { context in
            context.allowsImplicitAnimation = true
            zoomInBtnBottomConst.constant = isShownFloatingMenu ?? false ? -30 : 30
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
