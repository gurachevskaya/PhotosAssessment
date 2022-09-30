//
//  UIViewController+Ext.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 29.09.22.
//

import UIKit

extension UIViewController {
    func showAlert(text: String) {
        let alertController = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}
