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
    case invalidJSON
    case noMoreImagesForTag
    case mustFetchFirstPageFirst
    case invalidTag
    
    var errorDescription: String? {
        switch self {
        case .invalidResponseCode: return "Error returned from server, response code not 200"
        case .noData: return "Response did not contain any data!"
        case .fileNotFound: return "File not found in bundle!"
        case .emptyImageId: return "Empty image id passed as parameter!"
        case .invalidJSON: return "Received invalid JSON"
        case .noMoreImagesForTag: return "No more images to load!"
        case .mustFetchFirstPageFirst: return "You need to get first page of results before next page"
        case .invalidTag: return "Can't search for empty tag!"
        }
    }
}
