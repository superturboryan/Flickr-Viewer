//
//  ImageViewModel.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-14.
//

import Foundation

/*
 Initialized with ImageInfo and ImageSizeInfoResult objects
 and exposes only those properties needed for the cell/view
 */

struct ImageViewModel: Hashable {
    
    private(set) var largeSquare: String
    private(set) var large: String
    private(set) var title: String
    
    init(info: ImageInfo, sizes: ImageSizeInfoResult) {
        
        title = info.title == "" ? Constants.ImageGridUI.imageDefaultTitle : info.title
        large = sizes.urlStringForType(.Large)
        largeSquare = sizes.urlStringForType(.LargeSquare)
    }
}
