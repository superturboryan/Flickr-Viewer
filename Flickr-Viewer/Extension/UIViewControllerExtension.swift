//
//  UIViewControllerExtension.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-13.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTapped() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
