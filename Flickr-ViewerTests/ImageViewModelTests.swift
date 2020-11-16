//
//  ImageViewModelTests.swift
//  Flickr-ViewerTests
//
//  Created by Ryan David Forsyth on 2020-11-15.
//

import XCTest
@testable import Flickr_Viewer

class ImageViewModelTests: XCTestCase {
    
    var imageViewModel: ImageViewModel!
    
    override func setUp() {
        super.setUp()
        imageViewModel = ImageViewModel(info: ImageInfo.mockData(),
                                        sizes: ImageSizeInfoResult.mockData())
    }
    
    override func tearDown() {
        imageViewModel = nil
        super.tearDown()
    }

    func test_url_getters() {
        
        XCTAssertEqual(imageViewModel.large, "largeSource")
        XCTAssertEqual(imageViewModel.largeSquare, "largeSquareSource")
    }
    
    func test_empty_title() {
        // Mock data below is initialized with empty string title,
        // it should be converted to a default value
        XCTAssertEqual(imageViewModel.title, Constants.ImageGridUI.cellDefaultTitle)
    }
}

private extension ImageInfo {
    static func mockData() -> ImageInfo {
        return ImageInfo(id: "12345",
                         owner: "Unit Tester",
                         title: "")
    }
}

private extension ImageSizeInfoResult {
    static func mockData() -> ImageSizeInfoResult {
        return ImageSizeInfoResult(imageSizeInfos: [ImageSizeInfo(source: "largeSource",
                                                                  flickrURL: "",
                                                                  size: .Large),
                                                    ImageSizeInfo(source: "largeSquareSource",
                                                                  flickrURL: "",
                                                                  size: .LargeSquare)])
    }
}
