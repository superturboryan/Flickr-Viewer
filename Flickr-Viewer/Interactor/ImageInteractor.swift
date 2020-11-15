//
//  ImageInteractor.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-14.
//

import Foundation

struct ImageInteractor {
    
    private var serviceClient: ImageAPI

    init(client: ImageAPI) {
        serviceClient = client
    }
    
    func getImageViewModels(forTag tag:String, andPage page:Int, completion: @escaping ([ImageViewModel]?, Error?) -> Void) {
        
        serviceClient.fetchImageInfo(forTag: tag, page: page) { (result, error) in
            
            guard let imageInfos = result?.imageInfos, error == nil else {
                
                completion(nil, error)
                return
            }
            
            var viewModels = [ImageViewModel]()
            
            let group = DispatchGroup.init()
            
            for imageInfo in imageInfos {
                
                group.enter()
                
                serviceClient.fetchImageSizeInfo(forId: imageInfo.id) { (sizeInfoResult, error) in
                    
                    if let sizeInfos = sizeInfoResult {
                        
                        viewModels.append(ImageViewModel(largeSquare: sizeInfos.urlStringForType(.LargeSquare),
                                                         large: sizeInfos.urlStringForType(.Large),
                                                         title: imageInfo.title == "" ? "No title" : imageInfo.title))
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                
                completion(viewModels,nil)
            }
        }
    }
    
    func getImage(withUrl url: URL, completion: @escaping ImageClosure) {
        
        serviceClient.fetchImage(withUrl: url, completion: completion)
    }
}
