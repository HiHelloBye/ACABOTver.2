import UIKit

/*
 * 제스처로 앨범을 삭제하는 기능이 있다
 */
class AlbumCell: UICollectionViewCell ,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var AlbumImage: UIImageView!
    @IBOutlet weak var AlbumName:  UILabel!
    @IBOutlet weak var PhotoCount: UILabel!
    
    var pan: UIPanGestureRecognizer!
    var deleteLabel:UILabel!
    
    var receivedRow: Int!
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = .white

        deleteLabel = UILabel()
        deleteLabel.text = "앨범삭제"
        deleteLabel.textColor = UIColor.black
        self.insertSubview(deleteLabel, belowSubview: self.contentView)
        
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_ :)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
    }
    
    override func prepareForReuse() {
        self.contentView.frame = self.bounds
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (pan.state == UIGestureRecognizerState.changed) {

            let p:CGPoint = pan.translation(in: self)
            
            let width  = self.contentView.frame.width
            let height = self.contentView.frame.height
            self.contentView.frame = CGRect(x: p.x, y: 0, width: width, height: height)
            
            deleteLabel.frame = CGRect(x:p.x + width + deleteLabel.frame.size.width, y: 0, width: 100, height: height)
        }
    }
    
    @objc func onPan(_ pan: UIPanGestureRecognizer) {
        if pan.state == UIGestureRecognizerState.began {
            
        } else if pan.state == UIGestureRecognizerState.changed {
            self.setNeedsLayout()
        } else {
            if abs(pan.velocity(in: self).x) > 500 {
                let collectionView: UICollectionView = self.superview as! UICollectionView
                let indexPath:IndexPath = collectionView.indexPathForItem(at: self.center)!
                collectionView.delegate?.collectionView!(collectionView, performAction: #selector(onPan(_:)), forItemAt: indexPath, withSender: nil)
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                    })
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()

    }
}
