//
//  ImageInteractor.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-14.
//

import Foundation

typealias ViewModelClosure = ([ImageViewModel]?, Error?) -> Void

class ImageInteractor {
    
    private var serviceClient: ImageAPI
    private var pageToLoad = 1
    private var searchedTag = ""

    init(client: ImageAPI) {
        serviceClient = client
    }
    
    func getFirstPageOfResults(forTag tag: String, completion: @escaping ViewModelClosure) {
        
        pageToLoad = 1 // Reset page
        searchedTag = tag
        getImageViewModels(forTag: searchedTag,
                           andPage: pageToLoad,
                           completion: completion)
    }
    
    func getNextPageOfResults(completion: @escaping ViewModelClosure) {
        
        pageToLoad += 1
        getImageViewModels(forTag: searchedTag,
                           andPage: pageToLoad,
                           completion: completion)
    }
    
    func getImage(withUrl url: URL, completion: @escaping ImageClosure) {
        
        serviceClient.fetchImage(withUrl: url,
                                 completion: completion)
    }
}

private extension ImageInteractor {
    
    func getImageViewModels(forTag tag:String,
                                    andPage page:Int,
                                    completion: @escaping ViewModelClosure) {
        
        serviceClient.fetchImageInfo(forTag: tag,
                                     page: page) { (result, error) in
            
            guard let imageInfos = result?.imageInfos, error == nil else {
                
                completion(nil, error)
                return
            }
            
            var viewModels = [ImageViewModel]()
            
            let group = DispatchGroup.init()
            
            for imageInfo in imageInfos {
                
                group.enter()
                
                self.serviceClient.fetchImageSizeInfo(forId: imageInfo.id) { (sizeInfoResult, error) in
                    
                    if let sizeInfos = sizeInfoResult {
                        
                        // Combine image info with size info for displaying in view
                        viewModels.append(ImageViewModel(info: imageInfo,
                                                         sizes: sizeInfos))
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
