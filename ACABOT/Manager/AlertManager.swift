import Foundation
import UIKit

/*
 * 필요한 alert들을 제작
 */
class AlertManager {
    
    var alert:UIAlertController = UIAlertController()
    
    //MAKR:createOneBtnAlert
    // 하나의 버튼만 가지고 있는 alert
    func createOneBtnAlert (title:String, message:String) -> UIAlertController {
     
        alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "YES", style: UIAlertActionStyle.default, handler: { (action) in
            self.alert.dismiss(animated: true, completion: nil)
        }))
        
        return alert

    }
    //end_of_createOneBtnAlert
    
    
    //MARK:createListSheet
    // 리스트를 보여줄 수 있는 alert
    func createListSheet (title:[String]) -> String {
       
        let albumPV = AlbumPhotoView()
        var selected:String = String()
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        

        for i in 0 ..< title.count {
            alert.addAction(UIAlertAction(title: title[i], style: UIAlertActionStyle.default, handler: {
                action in
                selected = title[i]
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancle", style: UIAlertActionStyle.cancel, handler: nil))
        
        albumPV.present(alert, animated: true, completion: nil)
        
       return selected
    }
    //end_of_createListSheet
}
