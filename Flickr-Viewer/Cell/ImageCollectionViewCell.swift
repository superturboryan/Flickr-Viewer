//
//  ImageCollectionViewCell.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import UIKit

protocol ImageCollectionViewCellDelegate {
    
    func imageCellDidTapShareButton(WithSelectedImage image: UIImage)
}

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate: ImageCollectionViewCellDelegate?
    
    static let id = "ImageCollectionViewCell"
    
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
            
            let raise = CGAffineTransform(translationX: 0, y: -40)
            UIView.animate(withDuration: 0.35,
                           delay: 0.05,
                           options: .curveEaseInOut) {
                self.titleLabel.transform = self.showTitleLabel ? raise : .identity
                if self.showTitleLabel { self.titleLabel.alpha = 1.0 }
            } completion: { finished in /*Completion*/ }
        }
    }
    
    var showShareButton = false {
        didSet{
            if !showShareButton { self.shareButton.alpha =  0.0 }
            
            let lower = CGAffineTransform(translationX: 0, y: 70)
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .curveEaseInOut) {
                self.shareButton.transform = self.showShareButton ? lower : .identity
                if self.showShareButton { self.shareButton.alpha = 1.0 }
            } completion: { finished in /*Completion*/ }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = false // Allow label to be shown outside cell
        titleLabel.alpha = 0.0
        shareButton.alpha = 0.0
        activityIndicator.hidesWhenStopped = true
        
        shareButton.setFullyRoundCornerRadius()
        shareButton.backgroundColor = .init(white: traitCollection.userInterfaceStyle == .light ? 0.2 : 0.8,
                                            alpha: 0.2)
    }
    
    @IBAction func tappedShareButton(_ sender: UIButton) {
        guard let displayedImage = self.mainImageView.image else { return }
        self.delegate?.imageCellDidTapShareButton(WithSelectedImage: displayedImage)
    }
    
    
    // When the share button is moved outside (below) the bounds of the cell,
    // we still need it to be tappable so must override hitTest and pass event
    // to shareButton's hitTest method
    //https://stackoverflow.com/questions/5432995/interaction-beyond-bounds-of-uiview
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let translatedPoint = shareButton.convert(point, from: self)
        
        if (shareButton.bounds.contains(translatedPoint)) {
            return shareButton.hitTest(translatedPoint, with: event)
        }
        return super.hitTest(point, with: event)
    }
}
