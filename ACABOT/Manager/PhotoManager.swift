import UIKit
import Photos
import CoreData

/* 앨범 정보를 가지고 있다
 * 호출된 인자(indexPath)에 따라 해당하는 앨범을 찾고
 *  -indexPath(0): 정리해야 할 앨범
 *  -1~6 : 기본 앨범
 *  -7.. : 사용자가 만든 앨범
 * 필요한 정보들을 리턴한다
 *  - 앨범을 호출
 *  - 앨범 정보(개수, 썸네일, 이미지들)을 반환하는 함수
 * 사진을 보여주는 함수
 */
class PhotoManager{
    
    var albumCount:Int         = 0
    var numofAlbumSelected:Int = 0
   
    let fetchOptions:PHFetchOptions = PHFetchOptions()

    var imageArray = [UIImage]()
    let assetArray:NSMutableArray! = NSMutableArray()
    
    
    
    
    
    //MAKR: getAllPhotos
    func  getAllPhotos() -> [PHAsset]{
        
        let imageManager   = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        var assets:[PHAsset] = [PHAsset()]
        
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode  = .highQualityFormat
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        if let fetchResult:PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) {
            if fetchResult.count > 0 {
                for i in 0 ..< fetchResult.count {
                    imageManager.requestImage(for: fetchResult.object(at: i) , targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                        image, _ in
                        assets.append(fetchResult.object(at: i))
                    })
                }
                return assets
            }
            else {
                print("You have no images")
            }
        }
        return [PHAsset]()
    }
    //end_of_getAllPhotos
    
    
    //MARK: getCameraRoll
    func getCameraRoll() -> PHAssetCollection{
        let albums: PHFetchResult<PHAssetCollection>  =
            PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any , options: fetchOptions)
        
        for i in 0 ..< albums.count {
           
            let assetCollection:PHAssetCollection = albums[i]
           
            if assetCollection.localizedTitle == "Camera Roll" {
                return assetCollection
            }
            
            //print(assetsFetchResult.count) //앨범에 들은 사진 개수
        }
        return PHAssetCollection()
    }
    //end_of_getCameraRoll
    
    //MAKR:getAlbumByAlbumName
    func getAlbumByAlbumName(name:String) -> PHAssetCollection {
     
        let fetchOptions:PHFetchOptions = PHFetchOptions()
        let albums: PHFetchResult       = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        var assetCollection:PHAssetCollection?
        
        for i in 0 ..< albums.count {
            assetCollection  = albums[i]
            
            if assetCollection == nil {
                return PHAssetCollection()
            }
            else if assetCollection?.localizedTitle == name {
                return assetCollection!
            }
        }
    
        return PHAssetCollection()
    }
    //end_of_getAlbumByAlbumName
    
    
    // MARK: getThumbnail
    func getAssetThumbnail(asset: PHAsset, width:Int, height:Int) ->UIImage {
        
        let manager   = PHImageManager.default()
        let option    = PHImageRequestOptions()
        var thumbnail = UIImage()
        
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: width, height: height), contentMode: .aspectFit, options: option, resultHandler: {(result, info) -> Void in
            thumbnail = result!
        })
        return thumbnail
    }
    //end_of_getThumbnail
    
    //MARK:getAlbumPhoto
    func getAlbumPhoto(ac:PHAssetCollection) -> PHFetchResult<PHAsset> {
        
        let fetchOptions = PHFetchOptions()
        let assetCollection:PHAssetCollection = ac
        let assetsFetchResult:PHFetchResult<PHAsset> = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
        
        return assetsFetchResult
    }
    //end_of_getAlbumPhoto
    
}






