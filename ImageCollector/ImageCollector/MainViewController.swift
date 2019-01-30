//
//  MainViewController.swift
//  ImageCollector
//
//  Created by NHNEnt on 23/01/2019.
//  Copyright © 2019 tldev. All rights reserved.
//
//https://developer.apple.com/library/archive/samplecode/TableViewPlayground/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010727

import Cocoa

//MARK: reload, scroll 페이지 넘어갈때 확인
class MainViewController: NSViewController {
    
    var indicator: DisableIndicator!
    var tags: [TagModel]!
    var itemBeginDrag: TagModel!
    var currentTagKey: String!

    @IBOutlet weak var outlineTagView: NSOutlineView!
    @IBOutlet weak var collectionView: NSCollectionView!
    
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
    
    @IBAction func test(_ sender: Any) {
        if let key = currentTagKey {
            let manager = TagFileManager(tagKey: key)
            
            var imageList: [ImageListModel] = []
            imageList.append(ImageListModel(imageUrl: "https://www.flaticon.com/premium-icon/icons/svg/279/279165.svg", description: "그림1"))
            imageList.append(ImageListModel(imageUrl: "https://www.flaticon.com/premium-icon/icons/svg/279/279166.svg", description: "그림2"))
            imageList.append(ImageListModel(imageUrl: "https://www.flaticon.com/premium-icon/icons/svg/279/279171.svg", description: "그림"))
            imageList.append(ImageListModel(imageUrl: "https://www.flaticon.com/premium-icon/icons/svg/279/279163.svg", description: "카메라맨"))
            imageList.append(ImageListModel(imageUrl: "https://www.flaticon.com/premium-icon/icons/svg/279/279162.svg", description: "카메라 앱 아이콘"))
            imageList.append(ImageListModel(imageUrl: "https://www.flaticon.com/premium-icon/icons/svg/279/279170.svg", description: "풍경그림"))
            imageList.append(ImageListModel(imageUrl: "https://www.flaticon.com/premium-icon/icons/svg/279/279164.svg", description: "카메라 to 패드"))
            
            manager.setData(data: imageList)
            
            
            let result = manager.getData()
            debugPrint("result > \(result)")
        } else {
            //태그 선택 이벤트로 코드내용 옮기면 이 아이는 필요 없게 됨
            AlertManager.shared.infoMessage(messageTitle: "선택된 태그가 없으면 이미지를 추가 할 수 없습니다. 태그를 먼저 선택해주세요")
        }
        
        
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
            debugPrint("selected tag > name : \(selected.name), key : \(selected.key)")
            self.currentTagKey = selected.key
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
                debugPrint("[DEBUG] key value of tag is equal (tag/self.itemBeginDrag)")
                return NSDragOperation()
            }

            tag = outlineTagView.parent(forItem: tag) as? TagModel
        }
        debugPrint("[DEBUG] allow movement")
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

extension MainViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 
    }
}
