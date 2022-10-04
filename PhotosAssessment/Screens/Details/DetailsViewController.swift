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
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private var originalImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        presenter.viewIsReady()
    }

    private func config() {
        configureViewController()
        setupImageView()
        setupActivityIndicatorView()
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        configNavigationBar()
    }
    
    private func setupActivityIndicatorView() {
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()

        activityIndicator.prepareForAutoLayout()
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func configNavigationBar() {
        navigationController?.navigationBar.tintColor = .label
        
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        
        let toggle = UIBarButtonItem(
            image: SFSymbols.magnifyingGlass,
            style: .plain,
            target: self,
            action: #selector(toggleContentMode)
        )
        navigationItem.rightBarButtonItems = [toggle]
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        imageView.prepareForAutoLayout()
        imageView.pinEdgesToSafeArea(in: view)
    }
    
    @objc
    private func toggleContentMode() {
        let contentMode: UIView.ContentMode = imageView.contentMode == .scaleAspectFill ? .scaleAspectFit : .scaleAspectFill

        let croppedImage = originalImage?.cropTo(view: imageView)
        let image = contentMode == .scaleAspectFill ? croppedImage : originalImage
        
        UIView.animate(withDuration: 0.6) {
            self.imageView.contentMode = contentMode
            self.imageView.image = image
        }
        
        presenter.drawSaliencyRectangle(for: image)
    }
}

// MARK: - DetailsPresenterDelegate

extension DetailsViewController: DetailsPresenterDelegate {
    func setupInitialState(image: UIImage?) {
        activityIndicator.stopAnimating()
        originalImage = image
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


