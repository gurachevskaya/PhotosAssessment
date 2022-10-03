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
    
    private lazy var collectionLayout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(1 / CGFloat(ViewConstants.numberOfColumns))
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: ViewConstants.numberOfColumns
        )
        group.interItemSpacing = .fixed(ViewConstants.collectionItemsSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = ViewConstants.collectionItemsSpacing

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
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
        title = "Recents"
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
                let image = try? await self?.presenter.fetchImage(id: asset.name)
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
    func didLoadPhotos() {
        print("did load")
    }
    
    func didFailWithError(_ error: String) {
        showAlert(text: error)
    }
}
