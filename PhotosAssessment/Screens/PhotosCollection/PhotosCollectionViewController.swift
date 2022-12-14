//
//  PhotosCollectionViewController.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 28.09.22.
//

import UIKit

extension PhotosCollectionViewController {
    enum ViewConstants {
        static let numberOfColumns = 4
        static let collectionItemsSpacing: CGFloat = 5
    }
}

class PhotosCollectionViewController: UIViewController {
    var presenter: PhotosCollectionPresenterProtocol!

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseID)
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        return collectionView
    }()
    
    private lazy var collectionLayout: UICollectionViewLayout = {
        .createSquaredLayout(
            numberOfColumns: ViewConstants.numberOfColumns,
            spacing: ViewConstants.collectionItemsSpacing
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        presenter.viewIsReady()
    }
    
    private func config() {
        configureViewController()
        setupCollectionView()
        setupDataSouce()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("RECENTS", comment: "")
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.prepareForAutoLayout()
        collectionView.pinEdgesTo(view: view)
    }
    
    private func setupDataSouce() {
        presenter.dataSource = .init(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, asset -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseID, for: indexPath) as! PhotoCollectionViewCell
           
            let imageLoadingTask = Task {
                let image = try? await self?.presenter.fetchImage(id: asset.localIdentifier)
                if !Task.isCancelled {
                    cell.setupWith(cellModel: .init(image: image))
                }
            }
            
            cell.onReuse = {
                imageLoadingTask.cancel()
            }
                        
            return cell
        })
    }
}

// MARK: - UICollectionViewDelegate

extension PhotosCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = presenter.model?[indexPath.item] else {
            return
        }
                
        let destination = presenter.obtainDetailsViewController(asset: asset)
        navigationController?.pushViewController(destination, animated: true)
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension PhotosCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        presenter.startCachingAssets(indexPaths: indexPaths)
    }
}

// MARK: - PhotosCollectionPresenterDelegate

extension PhotosCollectionViewController: PhotosCollectionPresenterDelegate {
    func didFailWithError(_ error: String) {
        showAlert(text: error)
    }
}
