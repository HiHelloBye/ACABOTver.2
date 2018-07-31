import UIKit
import Photos

extension CGFloat {
    static var screenWidth = UIScreen.main.bounds.width

}
extension Int {
    var cgFloat: CGFloat { return CGFloat(self) }
    var half:CGFloat     { return self.cgFloat / 2 }
    var adapt:CGFloat    { return self.cgFloat * CGFloat.screenWidth / 375.0}
}
extension PHAsset {
    var isSelect:Bool {return false}
}


class PhotoCell: UICollectionViewCell {
    
    let photoImageView = UIImageView()
    let checkBoxImage = UIImageView()
    
    let iconButton = UIButton()
    var iconClickAction: ((Bool) -> Void)?
    
    var representedAssetIdentifier: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        let padding = 5.cgFloat
        let iconWH = 20.adapt
        
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.frame = bounds
        
        contentView.addSubview(photoImageView)
        checkBoxImage.frame = CGRect(x:frame.width - padding - iconWH, y: padding, width: iconWH, height: iconWH)
        
        addSubview(checkBoxImage)
        
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
