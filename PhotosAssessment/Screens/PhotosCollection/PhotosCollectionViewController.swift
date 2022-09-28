//
//  PhotosCollectionViewController.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 28.09.22.
//

import UIKit
import SnapKit

class PhotosCollectionViewController: UIViewController {
    var viewModel: PhotosCollectionViewModelProtocol!

    private lazy var collectionView: UICollectionView = {
        let layout = UIHelper.createFourColumnFlowLayout(in: view)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseID)
        collectionView.delegate = self
        return collectionView
    }()
       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.loadPhotos()
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
        viewModel.dataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, asset -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseID, for: indexPath) as! PhotoCollectionViewCell
            cell.setupWith(cellModel: .init(image: UIImage(), title: asset.name))
            return cell
        })
    }
}

extension PhotosCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let asset = viewModel.model?[indexPath.item] else {
            return
        }
        
        print(asset)
        
//        let destVC = DetailsVC()
//        destVC.delegate = self
//        destVC.asset = asset
//        present(destVC, animated: true)
    }
}
