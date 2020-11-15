//
//  ImageNetworkRequestBuilder.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import Alamofire
import AlamofireImage

enum ImageRequestBuilder {
    
    case infoForTag(tag: String, page: Int)
    case infoForSize(id: String)
    case imageFromURL(url: URL)
}

extension ImageRequestBuilder: NetworkRequestBuilder {
    
    var baseUrlString: String {
        switch self {
        
        case .infoForTag(_, _),
             .infoForSize(_):
            return Constants.Networking.hostServer
        
        case .imageFromURL(let url):
            return url.absoluteString
        }
    }
    
    var path: String {
        
        switch self {
       
        case .infoForTag(_, _),
             .infoForSize(_):
            return Constants.Networking.restAPIPath
        
        case .imageFromURL(_):
            return ""
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders? {
        return ["Content-Type" : "application/json; charset=UTF-8"]
    }
    
    var parameters: Parameters? {
        
        switch self {
        
        case .infoForTag(let tag, let page):
            return [
                "method" : Constants.Networking.flickrSearchMethod,
                "api_key" : Constants.Networking.flickrAPIKey,
                "tags" : tag,
                "page" : page,
                "per_page": Constants.Networking.imagesPerPage,
                "format" : "json",
                "nojsoncallback" : 1,
            ]
            
        case .infoForSize(let id):
            return [
                "method" : Constants.Networking.flickrSizeMethod,
                "api_key" : Constants.Networking.flickrAPIKey,
                "photo_id" : id,
                "format" : "json",
                "nojsoncallback" : 1,
            ]
            
        case .imageFromURL(_):
            return [String:Any]()
        }
    }
    
    func body() throws -> Data? {
        return nil
    }
    
    func asURLRequest() throws -> URLRequest {
        
        var urlWithParameters = URLComponents(string: baseUrlString)
        
        if path != "" {
            urlWithParameters?.path = path
        }
        
        urlWithParameters?.queryItems = parameters?.map({ (key, value) -> URLQueryItem in
            URLQueryItem(name: key, value: "\(value)")
        })
        
        let url = try urlWithParameters?.url?.absoluteString.asURL()
        var request = try URLRequest(url: url!, method: method, headers: headers)
        request.httpBody = try body()
        
        return request
    }
    
    func download(usingNetworkService service: ImageNetworkService, completion: @escaping ImageDataResponse) throws -> Void {
        
        try service.download(asURLRequest(), completion: completion)
    }
}

