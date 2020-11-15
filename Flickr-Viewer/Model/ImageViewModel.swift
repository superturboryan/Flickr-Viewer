//
//  ImageViewModel.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-14.
//

import Foundation

/*
 This object is initialized with ImageInfo and ImageSizeInfoResult objects
 and exposes only those properties needed for the view
 */

struct ImageViewModel: Hashable {
    
    var largeSquare: String
    var large: String
    var title: String
    
    init(info: ImageInfo, sizes: ImageSizeInfoResult) {
        
        title = info.title
        large = sizes.urlStringForType(.Large)
        largeSquare = sizes.urlStringForType(.LargeSquare)
    }
}
