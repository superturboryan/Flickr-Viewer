//
//  ImageCollectionViewCell.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var isLoading = false {
        didSet {
            isLoading ?
                activityIndicator.startAnimating() :
                activityIndicator.stopAnimating()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainImageView.layer.cornerRadius = 5.0
        mainImageView.clipsToBounds = true
        
        activityIndicator.hidesWhenStopped = true
    }
}
