import UIKit
import CoreML
import Photos
import CoreData

/* <분류>
 * 분류안 된 앨범에 사진이 있다면 분류한다(예외처리)
 */

class Classification: UIViewController {

    /*
     * 첫 번째 앨범(01Unclassification)의 정보를 가져온다
     * 사진을 읽어 들어와서 분류를 시작한다
     * 분류결과와 맞는 앨범에 사진을 이동한다
     */
    
    let mlModel   = CategoryClassifier()
   
    var imageDict = [UIImage: PHAsset] ()
    var predictionName:NSMutableArray = NSMutableArray()
   
    
    
    func importFromAlbum() -> Void {
        
        
        for data in imageDict {
            let image_:UIImage = data.key
            if let buffer = image_.buffer(with: CGSize(width:224, height:224)) {
                guard let prediction = try?
                    self.mlModel.prediction(image:buffer) else {fatalError("Unexpectied runtime error")}
                
                print("카테고리출력", prediction.categoryType, "\n")
                predictionName.add(prediction.categoryType) 
            
            } else{
                print("failed buffer")
            }
        }
        
        imageDict.removeAll()
        
        dismiss(animated:true, completion: nil)
    }
 }
