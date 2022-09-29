//
//  PhotosCollectionViewController.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 28.09.22.
//

import UIKit
import SnapKit

class PhotosCollectionViewController: UIViewController {
    var presenter: PhotosCollectionPresenterProtocol!

    private lazy var collectionView: UICollectionView = {
        let layout = UIHelper.createFourColumnFlowLayout(in: view)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseID)
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        return collectionView
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
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupDataSouce() {
        presenter.dataSource = .init(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, asset -> UICollectionViewCell? in
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

extension PhotosCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = presenter.model?[indexPath.item] else {
            return
        }
        
        print(asset)
        
//        let destVC = DetailsVC()
//        destVC.delegate = self
//        destVC.asset = asset
//        present(destVC, animated: true)
    }
}

extension PhotosCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        presenter.startCachingAssets(indexPaths: indexPaths)
    }
}

extension PhotosCollectionViewController: PhotosCollectionPresenterDelegate {
    func didLoadPhotos() {
        print("did load")
    }
    
    func didFailWithError(_ error: String) {
    }
}
