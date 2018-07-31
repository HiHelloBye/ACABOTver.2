import UIKit

class SinglePhotoCell: UICollectionViewCell {
    
    var representedAssetIdentifier: String!
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init Fatal Error")
    }
}
