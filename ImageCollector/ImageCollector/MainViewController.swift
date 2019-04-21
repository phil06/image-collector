//
//  MainViewController.swift
//  ImageCollector
//
//  Created by NHNEnt on 23/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//
//https://developer.apple.com/library/archive/samplecode/TableViewPlayground/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010727

import Cocoa
import SDWebImage

//MARK: reload, scroll 페이지 넘어갈때 확인
class MainViewController: ExNSViewController {
    
    var indicator: DisableIndicator!
    var tags: [TagModel]!
    var itemBeginDrag: TagModel!
    var currentTagKey: String!

    @IBOutlet weak var outlineTagView: NSOutlineView!
    @IBOutlet weak var collectionView: NSCollectionView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allocNotification()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event) -> NSEvent? in
            self.keyDown(with: event)
            return event
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { (event) -> NSEvent? in
            self.mouseUp(with: event)
            return event
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let path = UserDefaults.standard.string(forKey: UserDefaultKeys.filePath) {
            self.view.window?.title = path
        } else {
  
            indicator = NSView.loadFromNib(nibName: "DisableIndicator", owner: self) as? DisableIndicator
            
            view.addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            indicator.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            indicator.message.stringValue = "저장 위치가 설정되어야 사용 가능합니다"

            if let path = PanelManager.shared.openDefaultPathPanel() {
                //view가 window에 추가되기 전에 호출되서 viewDidLoad에선 window의 title에 접근 할 수 없음
                self.view.window?.title = path
                indicator.isHidden = true
            }  else {
                NSApplication.shared.terminate(self)
            }
        }
        
        configureCollectionView()
        
        self.fetchData()
        
        outlineTagView.delegate = self
        outlineTagView.dataSource = self
        outlineTagView.registerForDraggedTypes([.string])
    }
    
    override func viewWillDisappear() {
        guard self.tags != nil else {
            return
        }
        
        AppSettingFileManager.shared.setDataSource(data: self.tags)
    }
    

    
    @IBAction func openImportWindow(_ sender: Any) {
        if outlineTagView.selectedRow < 0 {
            AlertManager.shared.infoMessage(messageTitle: "태그를 먼저 선택해주세요")
            return
        }
        
        let vc = ImportImageCanvasController()
        self.presentAsModalWindow(vc)
    }
    
    @IBAction func addTag(_ sender: Any) {
        
        var targetIdx = outlineTagView.selectedRow

        if let tagName = AlertManager.shared.showAddTagAlert(messageText: "태그명을 입력해주세요",
                                                                       infoText: "선택한 태그 아래 위치에 추가됩니다. 선택한 태그가 없을경우 최상단 하위에 추가됩니다.",
                                                      okTitle: "추가",
                                                      cancelTitle: "취소",
                                                      suppressionTitle: targetIdx < 0 ? nil : "태그를 선택한 태그의 하위로 추가합니다.") {

            //하위로 추가할때
            if tagName["suppression"] != nil {
                let selectedItem = outlineTagView.item(atRow: targetIdx) as! TagModel
                selectedItem.childs?.insert(TagModel(name: tagName["input"] as! String, idx: 0), at: 0)
            } else {
                
                if targetIdx < 0 {
                    self.tags.insert(TagModel(name: tagName["input"] as! String, idx: 0), at: 0)
                } else {
                    let selectedItem = outlineTagView.item(atRow: targetIdx) as! TagModel
                    let parentOfSelected = outlineTagView.parent(forItem: outlineTagView.item(atRow: targetIdx))
                    
                    if let parent = parentOfSelected as? TagModel {
                        
                        if let foundIdx = findGroupIndexByKey(arr: parent.childs!, keyToFind: selectedItem.key) {
                            targetIdx = foundIdx
                        }
                        
                        targetIdx = targetIdx + 1
                        parent.childs?.insert(TagModel(name: tagName["input"] as! String, idx: targetIdx), at: targetIdx)
                        
                    } else {
                        
                        if let foundIdx = findGroupIndexByKey(arr: self.tags, keyToFind: selectedItem.key) {
                            targetIdx = foundIdx
                        }
                        
                        targetIdx = targetIdx + 1
                        self.tags.insert(TagModel(name: tagName["input"] as! String, idx: targetIdx), at: targetIdx)
                    }
                }

            }

            outlineTagView.reloadData()
        }
        
    }
    

    
    @IBAction func deleteTag(_ sender: Any) {
        var targetIdx = outlineTagView.selectedRow
        
        guard targetIdx >= 0 else {
            AlertManager.shared.infoMessage(messageTitle: "선택된 태그가 없습니다.")
            return
        }
        
        let selectedItem = outlineTagView.item(atRow: targetIdx) as! TagModel
        
        let parentOfSelected = outlineTagView.parent(forItem: outlineTagView.item(atRow: targetIdx)) as? TagModel
        
        if AlertManager.shared.confirmDeleteTag() {
            if parentOfSelected == nil {
                //root에서 삭제
                if let foundIdx = findGroupIndexByKey(arr: self.tags, keyToFind: selectedItem.key) {
                    targetIdx = foundIdx
                }
                self.tags.remove(at: targetIdx)
            } else {
                //부모에서 삭제
                parentOfSelected!.deleteChild(key: selectedItem.key)
            }
            
        }
        
        self.outlineTagView.reloadData()
    }
    
    @IBAction func editTag(_ sender: Any) {
        var targetIdx = outlineTagView.selectedRow
        
        if targetIdx < 0 {
            AlertManager.shared.infoMessage(messageTitle: "변경할 태그를 선택해주세요")
            return
        }
        
        if let tagName = AlertManager.shared.showAddTagAlert(messageText: "태그명을 입력해주세요",
                                                             infoText: "변경할 내용을 입력해주세요",
                                                             okTitle: "수정",
                                                             cancelTitle: "취소",
                                                             suppressionTitle: nil) {

            let selectedItem = outlineTagView.item(atRow: targetIdx) as! TagModel
            let parentOfSelected = outlineTagView.parent(forItem: outlineTagView.item(atRow: targetIdx)) as? TagModel
            
            if parentOfSelected == nil {
                //root에서 삭제
                if let foundIdx = findGroupIndexByKey(arr: self.tags, keyToFind: selectedItem.key) {
                    targetIdx = foundIdx
                }
                self.tags[targetIdx].name = tagName["input"] as! String
            } else {
                //부모에서 삭제
                parentOfSelected?.changeChildName(key: selectedItem.key, name: tagName["input"] as! String)
            }
        }
        
        self.outlineTagView.reloadData()
    }
    
    
    @IBAction func save(_ sender: Any) {
        AppSettingFileManager.shared.setDataSource(data: self.tags)
    }
    
    @IBAction func changeDefaultSetting(_ sender: Any) {
        let oldPath = AppSettingFileManager.shared.settingFileURL
        
        if let path = PanelManager.shared.openDefaultPathPanel() {
            AppSettingFileManager.shared.moveFile(oldPath: oldPath!)
            self.view.window?.title = path
        }
    }
    
    @IBAction func clearImageCache(_ sender: Any) {
        SDWebImageManager.shared().imageCache?.clearDisk()
        SDWebImageManager.shared().imageCache?.clearMemory()
    }

    
    func fetchData() {
        tags = AppSettingFileManager.shared.getDataSource()
        self.outlineTagView.reloadData()
    }
    
    func findGroupIndexByKey(arr: [TagModel], keyToFind: String) -> Int? {
        for (idx, item) in arr.enumerated() {
            if item.key == keyToFind {
                return idx
            }
        }
        return nil
    }
    
    //MARK: collection view
    private func configureCollectionView() {
        // 1
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 130.0, height: 130.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout
        // 2
        view.wantsLayer = true
        // 3
        collectionView.layer?.backgroundColor = NSColor.black.cgColor
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
    }
    
    func fetchCollectionView() {
        collectionImageLoader.fetchData(fileName: self.currentTagKey)
        collectionView.reloadData()
    }
    
    override func mouseUp(with event: NSEvent) {
        
        if event.clickCount < 2 {
            return
        }

        let indexPath = collectionView.selectionIndexPaths.first
        if indexPath == nil {
            return
        }
        
        let imageFile = collectionImageLoader.imageForIndexPath(indexPath: indexPath!)
        
        let vc = EnlargeImageViewController()
        vc.setImage(imageFile: imageFile)
        vc.view.window?.titleVisibility = .hidden
        
        self.presentAsModalWindow(vc)
    }
    
    override func keyDown(with event: NSEvent) {
        
        if event.keyCode != 0x33 {
            return
        }

        let indexPaths = collectionView.selectionIndexPaths
        
        if indexPaths.count < 1 {
            return
        }
        
        let newArr = indexPaths.map( { return $0.item } ).sorted(by: >)

        collectionImageLoader.deleteItem(idx: newArr)
        collectionView.deleteItems(at: indexPaths)
    }

    
    @objc func addCollectionViewItem(notification: Notification) {

        guard outlineTagView.selectedRow >= 0 else {
//            AlertManager.shared.infoMessage(messageTitle: "tag selection required")
            return
        }
        
        if let data = notification.userInfo as? [String: String] {
            self.addItem(url: data["url"]!)
        } else if let data = notification.userInfo as? [String: [String]] {
            for url in data["urls"]! {
                self.addItem(url: url)
            }
        }
    }
    
    private func addItem(url: String) {
        collectionImageLoader.addItem(url: url, desc: "")
        
        let itemInSectionCnt = collectionImageLoader.numberOfItemsInSection(section: 0)
        let count = itemInSectionCnt < 1 ? 1 : itemInSectionCnt - 1
        let indexPath = IndexPath(item: count, section: 0)
        
        collectionView.insertItems(at: [indexPath])
        
        NotificationCenter.default.post(name: .DidCompleteAddImageToTagCollection , object: self, userInfo: nil)
    }

 
    //MARK: Notification
    func allocNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(addCollectionViewItem), name: .AddImageToTagCollection , object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AddImageToTagCollection , object: nil)
    }
    
    
}

extension MainViewController: NSOutlineViewDataSource {

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard self.tags != nil else {
            return 0
        }
        
        if let tag = item as? TagModel {
            return (tag.childs?.count)!
        }
        return tags.count
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let tag = item as? TagModel {
            return (tag.childs?.count)! > 0
        }
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let tags = item as? TagModel {
            return tags.childs![index]
        }
        return self.tags[index]
    }

}

extension MainViewController: NSOutlineViewDelegate {
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let selected =  outlineTagView.item(atRow: outlineTagView.selectedRow) as? TagModel {
            debugPrint("selected tag : \(selected.key)")
            self.currentTagKey = selected.key
            fetchCollectionView()
        }
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var text = ""
        if let tag = item as? TagModel {
            text = tag.name
        }
        
        let tableCell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "tagCell"), owner: self) as! NSTableCellView
        tableCell.textField!.stringValue = text
        return tableCell
    }
    
    //support dran and drop
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        var text = ""
        if let tag = item as? TagModel {
            text = tag.name
        }

        let pasteBoard = NSPasteboardItem()
        pasteBoard.setString(text, forType: .string)

        return pasteBoard
    }
    
    func outlineView(_ outlineView: NSOutlineView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItems draggedItems: [Any]) {
        self.itemBeginDrag = nil
        if draggedItems.count == 1 {
            self.itemBeginDrag = draggedItems.last as? TagModel
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        if self.itemBeginDrag == nil {
            return NSDragOperation()
        }
        
        var tag = item as? TagModel
        
        while (tag != nil) {
            if (tag?.key == self.itemBeginDrag.key) {
                return NSDragOperation()
            }

            tag = outlineTagView.parent(forItem: tag) as? TagModel
        }
        return NSDragOperation.move
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        var targetIdx = index

        let oldParent = outlineTagView.parent(forItem: self.itemBeginDrag) as? TagModel
        
        var fromIndex: Int = 0
        let tag = item as? TagModel
        
        if oldParent == nil {
            
            if let foundIdx = findGroupIndexByKey(arr: self.tags, keyToFind: self.itemBeginDrag.key) {
                fromIndex = foundIdx
            }
            self.tags.remove(at: fromIndex)

        } else {
            if let foundIdx = findGroupIndexByKey(arr: (oldParent?.childs)!, keyToFind: self.itemBeginDrag.key) {
                fromIndex = foundIdx
            }
            oldParent?.childs?.remove(at: fromIndex)
        }
        
        if (oldParent?.key == tag?.key) {
            if (fromIndex < targetIdx) {
                targetIdx = targetIdx - 1;
            }
        }
        
        if tag == nil {
            self.tags.insert(self.itemBeginDrag, at: targetIdx)
        } else {
            tag?.childs?.insert(self.itemBeginDrag, at: targetIdx < 0 ? 0 : targetIdx)
        }
        
        self.itemBeginDrag = nil
        
        outlineTagView.reloadData()
    
        return true

    }
}

