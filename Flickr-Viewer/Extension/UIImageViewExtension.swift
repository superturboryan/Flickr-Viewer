//
//  UIImageViewExtension.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-14.
//

import UIKit

extension UIImageView {
    
    func fadeOutAndInToImage(_ image:UIImage, completion: ()->Void) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       options: .curveEaseIn) {
            self.alpha = 0.4
        } completion: { (finished) in
            self.image = image
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: .curveEaseOut) {
                self.alpha = 1.0
            } completion: { (finished) in
                
            }
        }
    }
}
