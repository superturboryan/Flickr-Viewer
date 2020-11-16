//
//  Constants.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-14.
//

import UIKit

struct Constants {
    
    struct ImageGridUI {
        static let cellsPerRow:CGFloat = 2.0
        static let cellMargin:CGFloat = 2.0
        static let imageDefaultTitle = "No title"
    }
    
    struct Networking {
        
        static let timeout: TimeInterval = 10
        static let hostServer = "https://api.flickr.com"
        static let restAPIPath = "/services/rest"
        static let flickrAPIKey = "f9cc014fa76b098f9e82f1c288379ea1"
        static let flickrSearchMethod = "flickr.photos.search"
        static let flickrSizeMethod = "flickr.photos.getSizes"
        static let imagesPerPage = 20
    }
}
