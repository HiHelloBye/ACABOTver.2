import UIKit
import Photos
import CoreData

class AlbumPhotoView: UIViewController, PHPhotoLibraryChangeObserver {
  
    /* 선택된 앨범의 사진들을 collectionView로 보여준다
     *  - segue를 통해 선택된 앨범 정보를 상위 뷰로부터 받는다
     *  - 선택된 앨범 정보로 PhotoManager를 호출한다
     *  - PhotoManager를 통해 얻은 앨범 사진들을 뿌려준다
     *  - 하위 뷰로 앨범에 들은 사진 리스트를 넘긴다(segue)
     */
    
    fileprivate var collectionView: UICollectionView!
    
    var albumName: String?
    
    let photoManager     = PhotoManager()
    let albumManager     = AlbumManager()
    let alertManager     = AlertManager()
    let photoCell        = PhotoCell()
    
    var assetsCollection:PHAssetCollection!
    
    var asset: PHAsset?
    var assetsFetchResult: PHFetchResult<PHAsset>?
   
    
    let imageManager                        = PHCachingImageManager()
    var previousPreheatRect                 = CGRect.zero

    
    var unClassifiedPhoto: NSMutableArray!  = NSMutableArray()
    var identifiers: NSMutableArray!        = NSMutableArray()
    var core_photo:  NSMutableArray!        = NSMutableArray()
    
    var nameArray: NSMutableArray!          = NSMutableArray()
    var selectedName: String?
    
    var assetArray: NSMutableArray!         = NSMutableArray()
    var selectedIndexes: [Int:Bool]         = [:]
    var images                              = [UIImage]()
    var multiSelect:Bool                    = false
    
    var selectButton:UIButton!              = UIButton()
    
    var items = [UIBarButtonItem]()

    override func awakeFromNib() {
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context     = appDelegate.persistentContainer.viewContext
    

        let coreDataRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CheckPhoto")
        coreDataRequest.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(coreDataRequest)
            for data in result as! [NSManagedObject] {
                if let key = data.value(forKey: "identifier") {
                    identifiers.add(key)
                }
            }
        } catch {
            print("Failed")
        }
        
        print("사진개수" ,assetsFetchResult!.count)
        
        for i in 0 ..< assetsFetchResult!.count {
            let asset:PHAsset = assetsFetchResult![i]
            assetArray.add(asset)
            if !(identifiers.contains(asset.localIdentifier)) {
                unClassifiedPhoto.add(asset)
            }
        }

    }
    
    override func viewDidLoad() {
        
        // 분류 버튼
        if(albumName == "Unclassified") {
            let button:UIButton = UIButton.init(type: .custom)
            button.setImage(UIImage.init(named: "classifying"), for: UIControlState.normal)
            button.addTarget(self, action: #selector(classification), for: UIControlEvents.touchUpInside)
            button.frame = CGRect(x: 0, y: 0, width: 53.0, height: 51.0)
            button.sizeToFit()
            let barbutton = UIBarButtonItem(customView: button)
            
            self.navigationItem.rightBarButtonItem = barbutton
        }
        // 선택 버튼
        else {
            if (assetsFetchResult?.count)! > 0 {
                selectButton = UIButton.init(type: .custom)
                selectButton.addTarget(self, action: #selector(multiSelectInit), for: UIControlEvents.touchUpInside)
                selectButton.frame = CGRect(x: 0, y: 0, width: 53.0, height: 51.0)
                selectButton.sizeToFit()
                selectButton.setTitle("Select", for: .normal)
                selectButton.setTitleColor(Colors.defaultBlack, for: .normal)
            
                let barbutton = UIBarButtonItem(customView: selectButton)
                self.navigationItem.rightBarButtonItem = barbutton
                if unClassifiedPhoto.count == 0 {
                    barbutton.isEnabled = false
                }
            }
        }
        
        
        let layout = UICollectionViewFlowLayout()
        let wh = view.bounds.width / 4.0  // 4개씩 보여줌
        layout.itemSize = CGSize(width: wh, height: wh)
        layout.minimumLineSpacing      = 1
        layout.minimumInteritemSpacing = 0
    
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate         = self
        collectionView.dataSource       = self
        collectionView.backgroundColor  = .white
        view.addSubview(collectionView)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.description())
        
        let button:UIButton = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "trash"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(trashSelected), for: UIControlEvents.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 53.0, height: 51.0)
        button.sizeToFit()
        let barbutton = UIBarButtonItem(customView: button)
        
        
        items.append(barbutton)
        
        self.toolbarItems = items
        
    }
    
    @objc func multiSelectInit() {
        activateSelection(bool: !multiSelect)
    }
    
    func activateSelection(bool: Bool) {
        multiSelect = bool
      
        navigationController?.isToolbarHidden = !multiSelect

        let title = multiSelect ? "Done" : "Select"
        let titleColor = multiSelect ? Colors.defaultBlack : .black
        selectButton.setTitle(title, for: .normal)
        selectButton.setTitleColor(titleColor, for: .normal)
        
        self.selectedIndexes.removeAll()
        self.collectionView.reloadData()
        
    }
    
    
    //MARK:trashSelected
    /*
     * 휴지통 버튼이 선택되었을 때 실행
     *  - 사용자가 선택한 사진(들)을 삭제 할 수 있다
     */
    @objc func trashSelected() -> Void {
        let completion = { (success: Bool, error: Error?) -> () in
            if success {
                PHPhotoLibrary.shared().unregisterChangeObserver(self)
                DispatchQueue.main.sync {
                }
            } else {
                print("can't remove asset")
            }
        }
        
        for data in selectedIndexes {
            if data.value {
                let assets = [assetsFetchResult?.object(at: data.key)]
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetCollectionChangeRequest(for: self.assetsCollection)
                    request?.removeAssets(assets as NSFastEnumeration)
                }, completionHandler: completion)
            }
        }
        
        UserDefaults.standard.set(true, forKey:"trashCalled")
        _ = self.navigationController!.popViewController(animated: true)
    }
    //end_of_trashSelected
    
    
    func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }

    
    // MAKR: PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {

        guard let changes = changeInstance.changeDetails(for: self.assetsFetchResult!)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            self.assetsFetchResult! = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
    }
    // end_of_PHPhotoLibraryChangeObserver
    
}

extension AlbumPhotoView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    /*
     * 분류안 된 앨범 우측 상단에는 분류하기 버튼이 있다
     * 그 이외의 엘범에는 우측 상단 바에 선택 버튼이 있다
     * 선택 버튼을 눌러야만 셀을 선택할 수 있다
     */

    //MARK:classification
    @objc func classification() {
        
        /*CoreData용*/
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context     = appDelegate.persistentContainer.viewContext
        
        let cf = Classification()

        for i in 0 ..< unClassifiedPhoto!.count {
            imageManager.requestImage(for: unClassifiedPhoto.object(at: i) as! PHAsset, targetSize: CGSize(width: 224, height: 224), contentMode: .aspectFill, options: nil, resultHandler: {image, _ in
                cf.imageDict[image!] = self.unClassifiedPhoto.object(at: i) as? PHAsset
            
            })
        }
        
        cf.importFromAlbum()

        //분류된 카테고리에 맞게 저장
        for i in 0 ..< unClassifiedPhoto!.count {
            let assets = [unClassifiedPhoto.object(at: i) as? PHAsset]
            let ac = self.photoManager.getAlbumByAlbumName(name: cf.predictionName[i] as! String)
            print("앨범 이름",ac.localizedTitle!)
            
            PHPhotoLibrary.shared().performChanges({
                let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: ac)
                assetCollectionChangeRequest?.addAssets(assets as NSFastEnumeration)
            }, completionHandler: nil)
        }

        //분류된 identifier를 가지고있음
        for i in 0 ..< unClassifiedPhoto!.count {
            let checkPhoto  = NSEntityDescription.entity(forEntityName: "CheckPhoto", in: context)
            let newPhoto    = NSManagedObject(entity: checkPhoto!, insertInto: context)
            asset = unClassifiedPhoto?.object(at: i) as? PHAsset
            newPhoto.setValue(asset!.localIdentifier, forKey: "identifier")
        }


        //그리고 저장
        do {
            try context.save()
        } catch {
            print("Failed Saving")
        }
        
        UserDefaults.standard.set(true, forKey:"classfyingCalled")

        _ = self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    /* <<CollectionView의 데이터 반환 함수(필수)>>
     */
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /* <<항목 개수>>
     * 사진의 개수는 PhotoManager로부터 받는다
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if albumName == "Unclassified" {
            return unClassifiedPhoto.count
        }
        else {
            return (assetsFetchResult?.count)! 
        }
    }
    
    /* <<셀에 넣을 항목들>>
     * 셀을 지정해 주고(albumPhotoViewCell)
     * 셀에 무엇을 넣을지 알려주어야 한다
     *  - 셀의 이미지는 앨범에 들은 사진들
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let assetCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.description(), for: indexPath) as! PhotoCell
        
        let singlePV = SinglePhotoView()
        singlePV.index = indexPath.row
        
        
        //셀 선택
        if multiSelect {
            assetCell.photoImageView.alpha = 1
            assetCell.checkBoxImage.isHidden = false
            assetCell.layer.borderWidth = 1
            
            if let selected = selectedIndexes[indexPath.row] {
                if selected{
                    assetCell.checkBoxImage.image = UIImage.init(named: "selected.png")
                    assetCell.photoImageView.alpha = 0.6
                    assetCell.layer.borderColor = UIColor.white.cgColor
                }
                else {
                    assetCell.checkBoxImage.image = nil
                    assetCell.photoImageView.alpha = 1
                    assetCell.layer.borderColor = UIColor.clear.cgColor
                }
            }
            else {
                assetCell.checkBoxImage.image = nil
                assetCell.photoImageView.alpha = 1
                assetCell.layer.borderColor = UIColor.clear.cgColor
            }
        }
        else {
            assetCell.photoImageView.alpha = 1
            assetCell.checkBoxImage.isHidden = true
            assetCell.layer.borderWidth = 0
        }
        
        if albumName == "Unclassified" {
            asset = unClassifiedPhoto[indexPath.row] as! PHAsset
            assetCell.representedAssetIdentifier = asset?.localIdentifier

            imageManager.requestImage(for: asset!, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil, resultHandler: {image, _ in
                if assetCell.representedAssetIdentifier == self.asset?.localIdentifier {
                    assetCell.photoImageView.image = image
                }
            })
            
        }
        
        else {
            asset = (assetsFetchResult?.object(at: indexPath.item))!
            assetCell.representedAssetIdentifier = asset?.localIdentifier
            
            imageManager.requestImage(for: asset!, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil, resultHandler: {image, _ in
                if assetCell.representedAssetIdentifier == self.asset?.localIdentifier {
                    assetCell.photoImageView.image = image
                }
            })
        }
        
        return assetCell
    }
    //UICollectionViewDataSource_End
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 4-1
        
        return CGSize(width: width, height: width)
    }
    
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let row = indexPath.row
        
        if multiSelect {
            if let selected = selectedIndexes[row] {
                if selected {
                    selectedIndexes[row] = false
                    selectedIndexes.removeValue(forKey: row)
                }
                else {
                    selectedIndexes[row] = true
                }
            }
            else {
                selectedIndexes[row] = true
            }
            
            self.collectionView.reloadItems(at: [indexPath])
            print(selectedIndexes.keys)
        }
        
        else {
            performSegue(withIdentifier: "SinglePhotoView", sender: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        
        collectionView.reloadItems(at: [indexPath])
    }
    
    /*
     * segue로 넘겨줄 값
     * 어떤 앨범(셀)이 선택되었는지(indexPath) 다음 뷰로 정보를 넘긴다(x)
     * 어떤 앨범(셀)이 선택되었는지 다음 뷰로 넘긴다
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        guard let indexPath = sender as? IndexPath else { return }
        
        if segue.identifier == "SinglePhotoView" {
            let spv = segue.destination as! SinglePhotoView
            
            spv.index             = indexPath.row
            spv.assetsFetchResult = assetsFetchResult
        }
    }
}


