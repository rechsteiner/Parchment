import Parchment
import UIKit

@MainActor
protocol ImagesViewControllerDelegate: AnyObject {
    func imagesViewControllerDidScroll(_: ImagesViewController)
}

class ImagesViewController: UIViewController {
    weak var delegate: ImagesViewControllerDelegate?

    fileprivate let images: [UIImage]

    fileprivate lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 18, left: 0, bottom: 18, right: 0)
        layout.minimumLineSpacing = 15
        return layout
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    init(images: [UIImage], options _: PagingOptions) {
        self.images = images
        super.init(nibName: nil, bundle: nil)

        view.addSubview(collectionView)
        view.constrainToEdges(collectionView)

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            ImageCollectionViewCell.self,
            forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier
        )
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionViewLayout.invalidateLayout()
    }
}

extension ImagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.bounds.width - 36,
            height: 220
        )
    }

    func scrollViewDidScroll(_: UIScrollView) {
        delegate?.imagesViewControllerDidScroll(self)
    }
}

extension ImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.setImage(images[indexPath.item])
        return cell
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return images.count
    }
}
