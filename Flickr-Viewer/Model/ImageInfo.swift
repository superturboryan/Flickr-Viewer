//
//  Image.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import UIKit

struct ImageInfo: Codable, Hashable {
    
    let id: String
    let owner: String
    let title: String
}

struct ImageInfoResult: Codable {
    
    let page: Int
    let pages: Int
    let imagesInfo: [ImageInfo]
    
    // JSON keys that are identical to properties default to raw string from case
    private enum CodingKeys: String, CodingKey {
        case imagesInfo = "photo"
        case page
        case pages
    }
}

struct ImageInfoTopLevelJSON: Codable {
    
    let photos: ImageInfoResult
}
