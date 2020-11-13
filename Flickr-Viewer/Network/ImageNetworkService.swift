//
//  ImageNetworkService.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import Alamofire
import AlamofireImage

typealias ImageDataResponse = (DataResponse<Image,AFIError>) -> Void

final class ImageNetworkService: NetworkService {
    
    var sessionManager: Session = .default
    
    static let shared: ImageNetworkService = ImageNetworkService()
    
    var imageDownloader: ImageDownloader = ImageDownloader()
    
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest {
        return sessionManager.request(urlRequest).validate(statusCode: 200..<400)
    }
    
    func download(_ urlRequest: URLRequestConvertible, completion: @escaping ImageDataResponse) -> Void {
        imageDownloader.download(urlRequest, completion: completion)
    }
}
