import UIKit

class AlbumImage: UIImageView {

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        
        backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        self.isOpaque = true
     
        let blurEffect = UIBlurEffect(style:.light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = self.bounds
        self.addSubview(blurredEffectView)
        blurredEffectView.alpha = 0.6
        blurredEffectView.isOpaque = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }

}
