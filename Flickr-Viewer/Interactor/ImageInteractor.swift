//
//  ImageInteractor.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-14.
//

import Foundation

struct ImageInteractor {
    
    var serviceClient: ImageAPI
    
    func getImageViewModels(forTag tag:String, andPage page:Int, completion: @escaping ([ImageViewModel]?, Error?) -> Void) {
        
        serviceClient.fetchImageInfo(forTag: tag, page: page) { (result, error) in
            
            guard let imageInfos = result?.imagesInfo, error == nil else {
                
                completion(nil, error)
                return
            }
            
            var viewModels = [ImageViewModel]()
            
            let group = DispatchGroup.init()
            
            for imageInfo in imageInfos {
                
                group.enter()
                
                ImageServiceClient.shared.fetchImageSizeInfo(forId: imageInfo.id) { (sizeInfoResult, error) in
                    
                    if let sizeInfos = sizeInfoResult {
                        
                        viewModels.append(ImageViewModel(largeSquare: sizeInfos.urlStringForType(ImageSize.LargeSquare),
                                                         large: sizeInfos.urlStringForType(ImageSize.Large),
                                                         title: imageInfo.title))
                    }
                    
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                
                completion(viewModels,nil)
                
            }
        }
        
    }
}
