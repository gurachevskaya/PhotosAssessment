//
//  DetailsPresenter.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 30.09.22.
//

import Foundation

protocol DetailsPresenterProtocol {
    var asset: PhotoAsset? { get }
    var delegate: DetailsPresenterDelegate? { get set }
    
    func viewIsReady()
}

protocol DetailsPresenterDelegate: AnyObject {
}

class DetailsPresenter: DetailsPresenterProtocol {
    
    weak var delegate: DetailsPresenterDelegate?
    
    var asset: PhotoAsset?
    
    func viewIsReady() {
    }
}
