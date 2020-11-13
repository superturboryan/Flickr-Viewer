//
//  NetworkError.swift
//  Flickr-Viewer
//
//  Created by Ryan David Forsyth on 2020-11-12.
//

import Foundation

enum NetworkError: Error {
    
    case invalidResponseCode
    case noData
    case fileNotFound
    case emptyImageId
    case serviceSetToReturnError
    case invalidJSON
    
    var errorDescription: String? {
        switch self {
        case .invalidResponseCode: return "Error returned from server, response code not 200"
        case .noData: return "Response did not contain any data!"
        case .fileNotFound: return "File not found in bundle!"
        case .emptyImageId: return "Empty image id passed as parameter!"
        case .serviceSetToReturnError: return "This service's shouldReturnError is set to true"
        case .invalidJSON: return "Received invalid JSON"
        }
    }
}
