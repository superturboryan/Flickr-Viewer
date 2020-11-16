//
//  UIViewExtension.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-15.
//

import UIKit

extension UIView {
    
    func setFullyRoundCornerRadius() {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.size.height/2
    }
}
