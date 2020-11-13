//
//  ImageNetworkRequestBuilder.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import Alamofire
import AlamofireImage

enum ImageNetworkRequestBuilder {
    
    case infoForTag(tag: String, page: Int)
    case infoForSize(id: String)
    case imageFromURL(url: URL)

}

extension ImageNetworkRequestBuilder: NetworkRequestBuilder {
    
    var baseUrlString: String {
        
        switch self {
        
        case .infoForTag(_, _),
             .infoForSize(_):
            return "https://api.flickr.com"
        
        case .imageFromURL(let url):
            return url.absoluteString
        }
        
    }
    
    var path: String {

        switch self {
       
        case .infoForTag(_, _),
             .infoForSize(_):
            return "/services/rest"
        
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
                "method" : "flickr.photos.search",
                "api_key" : "f9cc014fa76b098f9e82f1c288379ea1",
                "tags" : tag,
                "page" : page,
                "format" : "json",
                "nojsoncallback" : 1,
            ]
        case .infoForSize(let id):
            return [
                "method" : "flickr.photos.getSizes",
                "api_key" : "f9cc014fa76b098f9e82f1c288379ea1",
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
        
        var urlWithParamters = URLComponents(string: baseUrlString)
        urlWithParamters?.path = path
        urlWithParamters?.path = path
        urlWithParamters?.queryItems = parameters?.map({ (key, value) -> URLQueryItem in
            URLQueryItem(name: key, value: "\(value)")
        })
        
        var url = try urlWithParamters?.url?.absoluteString.asURL()
        
        var request = try URLRequest(url: url!, method: method, headers: headers)
        request.httpBody = try body()
        return request
    }
    
    func download(usingImageNetworkService service: ImageNetworkService, completion: @escaping ImageDataResponse) throws -> Void {
        try service.download(asURLRequest(), completion: completion)
    }
}

