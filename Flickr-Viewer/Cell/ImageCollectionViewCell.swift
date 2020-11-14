//
//  ImageCollectionViewCell.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isLoading = false {
        didSet {
            isLoading ?
                activityIndicator.startAnimating() :
                activityIndicator.stopAnimating()
        }
    }
    
    var showTitleLabel = false {
        didSet{
            if !showTitleLabel { self.titleLabel.alpha =  0.0 }
            
            UIView.animate(withDuration: 0.4,
                           delay: 0.1,
                           options: .curveEaseInOut) {
                let raise = CGAffineTransform(translationX: 0, y: -40)
                self.titleLabel.transform = self.showTitleLabel ? raise : .identity
                if self.showTitleLabel { self.titleLabel.alpha = 1.0 }
            } completion: { (finished) in
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.clipsToBounds = false // Allow label to be shown outside cell
        
        mainImageView.layer.cornerRadius = 5.0
        mainImageView.clipsToBounds = true
        
        self.titleLabel.alpha = 0.0
        activityIndicator.hidesWhenStopped = true
    }
}
