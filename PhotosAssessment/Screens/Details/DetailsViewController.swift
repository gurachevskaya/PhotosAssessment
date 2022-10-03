//
//  DetailsViewController.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 30.09.22.
//

import UIKit

class DetailsViewController: UIViewController {
    var presenter: DetailsPresenterProtocol!
    
    private lazy var imageView: AnimatableContentModeImageView = {
        let imageView = AnimatableContentModeImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        presenter.viewIsReady()
    }
    
    private func config() {
        configureViewController()
        setupImageView()
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
    
    private func setupImageView() {
        view.addSubview(imageView)
        imageView.prepareForAutoLayout()
        imageView.pinEdgesToSafeArea(in: view)
    }
    
    @objc
    private func toggleContentMode() {
        animateImage()
    }
    
    func animateImage() {
        let contentMode: UIView.ContentMode = imageView.contentMode == .scaleAspectFill ? .scaleAspectFit : .scaleAspectFill
        UIView.animate(withDuration: 0.6) {
            self.imageView.contentMode = contentMode
        }
    }

}

extension DetailsViewController: DetailsPresenterDelegate {
    func setupInitialState(image: UIImage?) {
        imageView.image = image
    }
    
    func drawRectangle(_ rect: CGRect) {
        guard let image = imageView.image else { return }

        UIGraphicsBeginImageContext(image.size)
        
        let context = UIGraphicsGetCurrentContext()
        image.draw(at: CGPoint.zero)
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.stroke(rect, width: 20)
        let imageWithRect = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

        guard let imageWithRect = imageWithRect else { return }
        
        imageView.image = imageWithRect
    }
}
