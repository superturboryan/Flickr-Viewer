//
//  ImageServiceClient.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import Alamofire

typealias ImageInfoParseResult = (result:ImageInfoResult?, error:Error?)
typealias ImageSizeParseResult = (result:ImageSizeInfoResult?, error:Error?)

class ImageClient {
    
    static let shared: ImageClient = ImageClient()
    
    private lazy var imageService = ImageNetworkService.shared
}

extension ImageClient: ImageAPI {
    
    func fetchImageInfo(forTag tag: String, page: Int, completion: @escaping ImageInfoClosure) {
        do {
            try ImageRequestBuilder
                .infoForTag(tag: tag, page: page)
                .request(usingNetworkService: imageService)
                .responseJSON(completionHandler: { (result) in
                    
                    let parsingResult = self.parseJSONDataResultForImageInfoList(result: result)
                    completion(parsingResult.0, parsingResult.1)
                })
        }
        catch { completion(nil,error) }
    }
    
    func fetchImageSizeInfo(forId imageId: String, completion: @escaping ImageSizeInfoClosure) {
        do {
            try ImageRequestBuilder
                .infoForSize(id: imageId)
                .request(usingNetworkService: imageService)
                .responseJSON(completionHandler: { (result) in
                    
                    let parsingResult = self.parseJSONDataResultForImageSizeList(result: result)
                    completion(parsingResult.0, parsingResult.1)
                })
        }
        catch { completion(nil,error) }
    }
    
    func fetchImage(withUrl url: URL, completion: @escaping ImageClosure) {
        do {
            try ImageRequestBuilder
                .imageFromURL(url: url)
                .download(usingNetworkService: imageService, completion: { (response) in
                    guard let image = response.value else { return }
                    completion(image,nil)
                })
        }
        catch { completion(nil,error) }
    }
}

extension ImageClient {
    
    private func parseJSONDataResultForImageInfoList(result: AFDataResponse<Any>) -> ImageInfoParseResult {
        
        guard [200,201].contains(result.response?.statusCode)
        else { return (result:nil, error:NetworkError.invalidResponseCode) }
        
        guard let data = result.data
        else { return (result:nil, error:NetworkError.noData) }
        
        do {
            let json = try JSONDecoder().decode(ImageInfoTopLevelJSON.self, from: data)
            return (result: json.photos, error:nil)
        }
        catch {
            return (result:nil, error:NetworkError.invalidJSON)
        }
    }
    
    private func parseJSONDataResultForImageSizeList(result: AFDataResponse<Any>) -> ImageSizeParseResult {
        
        guard [200,201].contains(result.response?.statusCode)
        else { return (result:nil, error:NetworkError.invalidResponseCode) }
        
        guard let data = result.data
        else { return (result:nil, error:NetworkError.noData) }
        
        do {
            let json = try JSONDecoder().decode(ImageSizeInfoTopLevelJSON.self, from: data)
            return (result: json.sizes, error:nil)
        }
        catch {
            return (result:nil, error:NetworkError.invalidJSON)
        }
    }
}
