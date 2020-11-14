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
    let perpage: Int
    let total: String
    let imagesInfo: [ImageInfo]
    
    // JSON keys that are identical to properties default to raw string from case
    private enum CodingKeys: String, CodingKey {
        case imagesInfo = "photo"
        case total
        case page
        case pages
        case perpage
    }
}

struct ImageInfoTopLevelJSON: Codable {
    
    let photos: ImageInfoResult
}

// ******************************************************************************

struct ImageSizeInfo: Codable {
    
    let source: String
    let flickrURL: String
    let size: ImageSize?
    
    private enum CodingKeys: String, CodingKey {
        
        case source
        case flickrURL = "url"
        case size = "label"
    }
}

struct ImageSizeInfoResult: Codable {
    
    let imageSizeInfos: [ImageSizeInfo]
    
    private enum CodingKeys: String, CodingKey {
        case imageSizeInfos = "size"
    }
    
    func urlStringForType(_ type: ImageSize) -> String {
        
        guard let urlString = imageSizeInfos.first(where: {$0.size == type})?.source
        else { return "" }
        
        return urlString
    }
}

struct ImageSizeInfoTopLevelJSON: Codable {
    
    let sizes: ImageSizeInfoResult
}

// https://www.flickr.com/services/api/misc.urls.html
enum ImageSize: String, Codable, CodingKey {
    
    case Small
    case Small320 = "Small 320"
    case Small400 = "Small 400"
    case Medium
    case Medium500 = "Medium 500"
    case Medium640 = "Medium 640"
    case Medium800 = "Medium 800"
    case Large
    case Large1600 = "Large 1600"
    case Large2048 = "Large 2048"
    case XLarge3K = "X-Large 3K"
    case XLarge4K = "X-Large 4K"
    case XLarge5K = "X-Large 5K"
   
    case Square
    case LargeSquare = "Large Square"
    case Thumbnail
    case Original
}
