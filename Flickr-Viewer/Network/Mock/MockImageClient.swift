//
//  MockImageClient.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-16.
//

import UIKit

class MockImageClient {
    
    static let shared: MockImageClient = MockImageClient()
}

extension MockImageClient: ImageAPI {
    
    func fetchImageInfo(forTag tag: String, page: Int, completion: @escaping ImageInfoClosure) {
        completion(ImageInfoResult(page: 1, pages: 3, imageInfos: [ImageInfo(id: "123", owner: "456", title: "MockTitle")]),
                   nil)
    }
    
    func fetchImageSizeInfo(forId imageId: String, completion: @escaping ImageSizeInfoClosure) {
        completion(ImageSizeInfoResult(imageSizeInfos: [ImageSizeInfo(source: "mock", flickrURL: "mockUrl", size: .Large),
                                                        ImageSizeInfo(source: "mock2", flickrURL: "mockUrl2", size: .LargeSquare)]),
                  nil)
    }
    
    func fetchImage(withUrl url: URL, completion: @escaping ImageClosure) {
        
        completion(UIImage(), nil)
    }
}
