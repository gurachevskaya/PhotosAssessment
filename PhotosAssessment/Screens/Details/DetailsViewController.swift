//
//  DetailsViewController.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 30.09.22.
//

import UIKit

class DetailsViewController: UIViewController {
    var presenter: DetailsPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        presenter.viewIsReady()
    }
    
    private func config() {
        configureViewController()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        configNavigationBar()
    }
    
    private func configNavigationBar() {
        navigationController?.navigationBar.tintColor = .label
        
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        let toggle = UIBarButtonItem(image: UIImage(systemName: "arrow.up.left.and.down.right.magnifyingglass"), style: .plain, target: self, action: #selector(toggleContentMode))
        navigationItem.rightBarButtonItems = [toggle]
    }
    
    @objc
    private func toggleContentMode() {
    }
}
