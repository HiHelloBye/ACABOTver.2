import UIKit
import Photos

/* 앨범을 관리한다
 *  - 앨범이름으로 필요한 정보를 fetch 한다
 *  - 앨범 이름은 배열로 갖고있는다
 *  -
 *  - Custom 앨범을 만든다
 *  - 앨범을 삭제한다
 */


class AlbumManager {
    
    static let sharedInstance = AlbumManager()
    
    var albumName:String!
    var failure:Int!
    
    var assetsCollection:PHAssetCollection!
    var albumArray:NSMutableArray = NSMutableArray()

    let photoManager = PhotoManager()
    
    init() {
        //기본앨범
        albumArray.add("tmp")
        albumArray.add("AllPhotos"   )
        albumArray.add("Unclassified")
        albumArray.add("Human"       )
        albumArray.add("Animal"      )
        albumArray.add("Food"        )
        albumArray.add("Landscape"   )
        albumArray.add("Concert"     )
        albumArray.add("Etc"         )
        
    }
    
    func create() -> Void {
        for i in 0 ..< albumArray.count {
            createAlbum(albumName: albumArray[i] as! String)
        }
    }
    
    //MARK:createAlbum
    func createAlbum(albumName:String) -> Void{
        let album = Album()
        for i in 0 ..< album.albums.count {
            if albumName == album.albums.object(at: i).localizedTitle! {
                self.failure = 0
                print("동일한 이름의 앨범이 있습니다")
                return
            }
        }
        
        func fetchAssetsCollectionForAlbum() -> PHAssetCollection! {
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                return collection.firstObject! as PHAssetCollection
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetsCollectionForAlbum() {
            self.assetsCollection = assetCollection
        }
        
        PHPhotoLibrary.shared().performChanges({
        PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }) {success, _ in
            if success {
                self.assetsCollection = fetchAssetsCollectionForAlbum()
            }
        }
        
        return
    }
    //end_of_createCustomAlbum

    //MARK:saveImageDuplicate
    func saveImageDuplicate(image:UIImage, name:String) -> Void {
        
        let photoManaer = PhotoManager()
        self.assetsCollection = photoManaer.getAlbumByAlbumName(name: name)
        
        if assetsCollection == nil {
            print("앨범이 없습니다")
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetsCollection)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let enumeration: NSArray = [assetPlaceHolder]
            albumChangeRequest?.insertAssets(enumeration, at: [0])

        }, completionHandler: nil)
        
    }
    //end_of_saveImageDuplicate
    
    func saveImage(assets:[PHAsset], ac: PHAssetCollection) -> Void {
       
        PHPhotoLibrary.shared().performChanges({
            let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: ac)
            assetCollectionChangeRequest?.addAssets(assets as NSFastEnumeration)
        }, completionHandler: nil)
    }

}
