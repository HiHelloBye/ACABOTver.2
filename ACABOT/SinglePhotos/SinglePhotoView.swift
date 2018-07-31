import UIKit
import Photos

class SinglePhotoView: UIViewController {

    /* 선택된 사진을 하나씩 보여준다(CollectionView 사용)
     *  - 사진들은 옆으로 넘겨가면서 볼 수 있다(PageViewController
     *  - 페이지뷰컨트롤러로 보여줄 사진들을 갖고있는 배열은 상위뷰(AlbumPhotoView)에서 갖고온다
     */
    private var collectionView: UICollectionView!

    var index:Int = 0
    var customIndexPath: IndexPath?
    var collection:PHAssetCollection?             = nil
    var assetsFetchResult:PHFetchResult<PHAsset>!
    
    let pageControl = UIPageControl()
    
    
    let cellId = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "ACABOT"
        
        addCollectionView()
        addPageControl()
        collectionView.register(SinglePhotoCell.self,
                                forCellWithReuseIdentifier: cellId)
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.automaticallyAdjustsScrollViewInsets = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        customIndexPath = [1, index]
    }
    
    // MARK:PageControl
    func addPageControl() {
        self.view.addSubview(pageControl)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 50).isActive = true

        pageControl.backgroundColor = UIColor.clear
        pageControl.numberOfPages = (assetsFetchResult?.count)!
        pageControl.currentPage = index
       //pageControl.pageIndicatorTintColor = UIColor.black
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    // end_of_PageControl
    
    // MARK:CollectionView
    func addCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing      = 0
        
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource      = self
        collectionView.delegate        = self
        collectionView.backgroundColor = UIColor.white
        collectionView.isPagingEnabled = true
        
        
        self.view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SinglePhotoView: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(assetsFetchResult?.count == nil) {
            return 0
        }
        else {
            return (assetsFetchResult?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SinglePhotoCell
        
        let imageManager = PHCachingImageManager()
        let asset = assetsFetchResult?.object(at: pageControl.currentPage)
        
        cell.representedAssetIdentifier = asset?.localIdentifier

        imageManager.requestImage(for: asset!, targetSize: CGSize(width: view.frame.width, height: view.frame.height), contentMode: .aspectFill, options: nil, resultHandler: {image, _ in
            if cell.representedAssetIdentifier == asset?.localIdentifier {
                cell.imageView.image = image
            }
        })
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    func moveViewLeftRight(sender: UIPageControl) {
        
    }
}
//end_of_CollectionView
