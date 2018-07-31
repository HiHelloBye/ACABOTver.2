import UIKit
import Photos
import Foundation
import AssetsLibrary

extension Bool {
    mutating func toggle() {
        self = !self
    }
}

extension Int {
    var stringValue:String {
        return "\(self)"
    }
}

class Album: UICollectionViewController,PHPhotoLibraryChangeObserver{

    let defaults            = UserDefaults.standard
    
    let imageManager        = PHCachingImageManager()
    var previousPreheatRect = CGRect.zero
   
    let photoManager        = PhotoManager()
    let albumManager        = AlbumManager()
    let alertManager        = AlertManager()

    var assetsCollection: PHAssetCollection!
    let fetchOptions        = PHFetchOptions()

    var failure:Int!

    var assetsFetchResult:PHFetchResult<PHAsset>?
    var albums:PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.alpha = 0.7
        navigationController?.navigationBar.isTranslucent = true
       
        
        
        if albums.count == 0 {
            albumManager.create()
        }
        
        //MARK:NavigationItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCustomAlbum))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        
        var cCheck:Bool  = UserDefaults.standard.bool(forKey: "classfyingCalled")
        var tCheck:Bool  = UserDefaults.standard.bool(forKey: "trashCalled")
        
        if cCheck == true {
            collectionView?.reloadData()
            resetCachedAssets()
            cCheck.toggle()
            UserDefaults.standard.set(false, forKey:"classfyingCalled")
        }
        
        if tCheck == true {
            collectionView?.reloadData()
            resetCachedAssets()
            tCheck.toggle()
            UserDefaults.standard.set(false, forKey:"trashCalled")
        }
        
        //collectionView?.reloadData()
    }
    
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK:addCustomAlbum
    /*
     * 사용자가 추가로 앨범을 만들 수 있다
     *  - 앨범이름이 기존에 있는 앨범이라면 만들 수 없다
     */
    @objc func addCustomAlbum() {
        
        let alert = UIAlertController(title: "새로운 앨범", message: "앨범 이름을 알려주세요", preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "확인", style: .default) { (alertAction) in
            let customAlbumName = alert.textFields![0] as UITextField
            
            self.albumManager.createAlbum(albumName: customAlbumName.text!)
            UserDefaults.standard.set(true, forKey:"createCustomAlbum")


            if self.albumManager.failure == 0 as Int {
                let alert:UIAlertController = self.alertManager.createOneBtnAlert(title: "실패", message: "이미 있는 앨범입니다")
                self.present(alert, animated: true, completion: nil)
                
            }
            self.collectionView?.reloadData()
        }
        alert.addTextField { (textField) in
            textField.placeholder = "앨범 이름"
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    
    }
    //end_of_addCustomAlbum

    
    
    // MARK: UICollectionViewDataSource
    /*
     * <<CollectionView의 데이터 반환 함수(필수)>>
     */
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    /* <<항목 개수>>
     * 앨범의 개수를 가져와서 반환한다
     */
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return albums.count
    }

    /* <<셀에 넣을 항목들>>
     * 셀을 지정해 주고(AlbumCell)
     * 셀에 무엇을 넣을지 알려주어야 한다
     *  - 셀의 이미지는 각 앨범의 썸네일이다(없으면 기본 이미지로 설정)
     */
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
    

        let name = albums[indexPath.row].localizedTitle
        cell.AlbumName.text = name
        
        let albumName = name

        for _ in 1 ..< albums.count {
    
            if albumName == "Unclassified" {
                cell.AlbumImage.image = UIImage.init(named: "un.jpg")
                cell.PhotoCount.textColor = .clear
            }
            
            else if albumName == "AllPhotos" {
                assetsCollection = photoManager.getCameraRoll()
                assetsFetchResult = PHAsset.fetchAssets(in: assetsCollection, options: nil)
                let asset = assetsFetchResult?.lastObject as? PHAsset
                cell.PhotoCount.text = assetsFetchResult?.count.stringValue
                if asset == nil {
                   
                } else {
                    cell.AlbumImage.image = photoManager.getAssetThumbnail(asset: asset!, width: 200, height: 200)
                }
            }
                
            else {
                assetsCollection = photoManager.getAlbumByAlbumName(name: name!)
                assetsFetchResult = PHAsset.fetchAssets(in: assetsCollection, options: fetchOptions)
                let asset = assetsFetchResult?.lastObject
             
                if asset == nil {
                        switch albumName {
                        case "Human":
                            cell.AlbumImage.image = UIImage.init(named: "human.jpg")
                        case "Animal":
                            cell.AlbumImage.image = UIImage.init(named: "animal.jpg")
                        case "Food":
                            cell.AlbumImage.image = UIImage.init(named: "food.jpg")
                        case "Landscape":
                            cell.AlbumImage.image = UIImage.init(named: "landscape.jpg")
                        case "Concert":
                            cell.AlbumImage.image = UIImage.init(named: "concert.jpg")
                        case "Etc":
                            cell.AlbumImage.image = UIImage.init(named: "etc.jpg")
                        default:
                            cell.AlbumImage.image = UIImage.init(named: "custom.jpg")
                           break
                        }
                } else {
                    cell.PhotoCount.text = assetsFetchResult?.count.stringValue
                    cell.AlbumImage.image = photoManager.getAssetThumbnail(asset:asset!,width: 200, height: 200)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        //access to minimumInteritemSpacing by casting to UICollectionViewFlowLayout
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let spacing = layout.minimumInteritemSpacing
        
        return UIEdgeInsetsMake(0.5,0,0.5,0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    //UICollectionViewDataSource_End
    
    //MAKR:deleteAlbum
    /*
      제스처로 앨범 삭제
     */
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        let albumCell = AlbumCell()
        albumCell.receivedRow = indexPath.row
        
        
        if indexPath.row > 6 {
            let albumName = albums[indexPath.row].localizedTitle
            let assetCollection:PHAssetCollection = photoManager.getAlbumByAlbumName(name: albumName!)

            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.deleteAssetCollections([assetCollection] as! NSFastEnumeration)
                
            }, completionHandler: nil)
        }
    }
    //end_of_deleteAlbum
    
    // MARK: - Navigation
    /*
     * segue로 넘겨줄 값
     * 어떤 앨범(셀)이 선택되었는지 다음 뷰로 넘긴다
     *  - PHAssetCollection 정보를 넘긴다
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UICollectionViewCell ,let indexPath = self.collectionView?.indexPath(for: cell) {
            let vc   = segue.destination as! AlbumPhotoView

            for i in 2 ..< albums.count {
                vc.nameArray.add(albums.object(at: i).localizedTitle) 
            }
            let name_ = albums.object(at: indexPath.row).localizedTitle!
            vc.albumName = name_

            if name_ == "AllPhotos" || name_ == "Unclassified" {
                assetsCollection = photoManager.getCameraRoll()
            }
            else {
                assetsCollection = photoManager.getAlbumByAlbumName(name: name_)
            }
            
            vc.assetsCollection = assetsCollection
            vc.assetsFetchResult = photoManager.getAlbumPhoto(ac: assetsCollection)
            
        }
    }
    
    
    func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
   // MAKR: PHPhotoLibraryChangeObserver
    /*
     * 앨범에 변화가 생겼는지 확인한다
     */
   func photoLibraryDidChange(_ changeInstance: PHChange) {
    DispatchQueue.main.sync {
        guard let changes = changeInstance.changeDetails(for: albums)
                else { return }
            
            albums = changes.fetchResultAfterChanges
            
            if changes.hasIncrementalChanges {
                guard let collectionView = self.collectionView else {
                    fatalError()
                }
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({
                            IndexPath(item: $0, section: 0) }))
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
            }
            else {
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
    }
    // end_of_PHPhotoLibraryChangeObserver
}
