//
//  ImageInteractor.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-14.
//

import Foundation

typealias ViewModelClosure = ([ImageViewModel]?, NetworkError?) -> Void

class ImageInteractor {
    
    private var serviceClient: ImageAPI
    private(set) var pageToLoad = 1
    private(set) var searchedTag = ""
    private(set) var noMoreImagesForTag = false

    init(client: ImageAPI) {
        // Inject mock client conforming to API to unit test interactor business logic
        serviceClient = client
    }
    
    func getFirstPageOfResults(forTag tag: String, completion: @escaping ViewModelClosure) {
        
        if tag == "" {
            completion(nil, NetworkError.invalidTag)
            return
        }
        
        noMoreImagesForTag = false
        pageToLoad = 1 // Reset page
        searchedTag = tag // Reset searched tag
        getImageViewModels(forTag: searchedTag,
                           andPage: pageToLoad,
                           completion: completion)
    }
    
    func getNextPageOfResults(completion: @escaping ViewModelClosure) {
    
        if pageToLoad == 1 {
            completion(nil, NetworkError.mustFetchFirstPageFirst)
            return
        }
        
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
        
        if noMoreImagesForTag {
            completion(nil, NetworkError.noMoreImagesForTag)
            return
        }
        
        serviceClient.fetchImageInfo(forTag: tag,
                                     page: page) { (result, error) in
            
            guard let imageInfos = result?.imageInfos, error == nil else {
                
                completion(nil, NetworkError.noData)
                return
            }
            
            var viewModels = [ImageViewModel]()
            
            // Use DispatchGroup to perform requests for size info of all
            // images for page concurrently and return once all are complete
            let group = DispatchGroup.init()
            
            for imageInfo in imageInfos {
                
                group.enter()
                
                self.serviceClient.fetchImageSizeInfo(forId: imageInfo.id) { (sizeInfoResult, error) in
                    
                    if let sizeInfos = sizeInfoResult, error == nil {
                        
                        // Combine image info with size info for displaying in view
                        viewModels.append(ImageViewModel(info: imageInfo,
                                                         sizes: sizeInfos))
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                
                // If we don't receive any images for the tag,
                // we shouldn't perform any more searches for it
                // nor should we increment the pageToLoad
                self.noMoreImagesForTag = viewModels.count == 0
                self.pageToLoad += (viewModels.count == 0 ? 0 : 1)
                
                completion(viewModels,nil)
            }
        }
    }
}
