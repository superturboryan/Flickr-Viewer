//
//  ServiceProtocols.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import Alamofire

protocol NetworkService {
    
    var sessionManager: Session { get set }
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest
}

protocol NetworkRequestBuilder: URLRequestConvertible {
    
    var baseUrlString: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    func body() throws -> Data?
    
    func request(usingNetworkService service: NetworkService) throws -> DataRequest
}

extension NetworkRequestBuilder {
    
    func asURLRequest() throws -> URLRequest {
        
        let url = try baseUrlString.asURL()
        
        var request = try URLRequest(url: url, method: method, headers: headers)
        
        request.httpBody = try body()
        request.timeoutInterval = 10
        
        return request
    }
    
    func request(usingNetworkService service: NetworkService) throws -> DataRequest {
        return try service.request(asURLRequest())
    }
}
