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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.mainImageView.layer.cornerRadius = 5.0
        self.mainImageView.clipsToBounds = true
        
        self.activityIndicator.hidesWhenStopped = true
    }
    
    func setLoading(_ loading: Bool) {
        loading ?
            self.activityIndicator.startAnimating() :
            self.activityIndicator.stopAnimating()
    }

}
