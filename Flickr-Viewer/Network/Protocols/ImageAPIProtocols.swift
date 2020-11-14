//
//  ImageProtocols.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import UIKit

typealias ImageInfoClosure = (ImageInfoResult?, Error?) -> Void
typealias ImageSizeInfoClosure = (ImageSizeInfoResult?, Error?) -> Void
typealias ImageClosure = (UIImage?, Error?) -> Void

protocol ImageAPI {
    
    func fetchImageInfo(forTag tag: String, page: Int, completion: @escaping ImageInfoClosure) -> Void
    
    func fetchImageSizeInfo(forId imageId: String, completion: @escaping ImageSizeInfoClosure) -> Void
    
    func fetchImage(withUrl url: URL, completion: @escaping ImageClosure) -> Void
}
