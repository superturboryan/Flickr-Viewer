//
//  ImageInteractorTests.swift
//  Flickr-ViewerTests
//
//  Created by Ryan David Forsyth on 2020-11-15.
//

import XCTest
@testable import Flickr_Viewer

class ImageInteractorTests: XCTestCase {
    
    var imageInteractor: ImageInteractor!
    
    override func setUp() {
        super.setUp()
        // TODO: Implement mock ImageClient for testing!
        // Using the real API is too slow...
        imageInteractor = ImageInteractor(client: ImageClient.shared)
    }
    
    override func tearDown() {
        imageInteractor = nil
        super.tearDown()
    }
    
    func test_get_first_page() {
        
        XCTAssertEqual(imageInteractor.pageToLoad, 1)
        
        let expectation = self.expectation(description: "Loading results")
        
        imageInteractor.getFirstPageOfResults(forTag: "Tag1") { (viewModels, error) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(imageInteractor.searchedTag, "Tag1")
        XCTAssertEqual(imageInteractor.pageToLoad, 2)
    }
    
    func test_get_next_page() {
        
        let expectation = self.expectation(description: "Loading first results")
        let expectation2 = self.expectation(description: "Loading next results")
        
        imageInteractor.getFirstPageOfResults(forTag: "Tag1") { (viewModels, error) in
            
            expectation.fulfill()
            
            self.imageInteractor.getNextPageOfResults { (viewModels, error) in
                
                expectation2.fulfill()
            }
        }
    
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(imageInteractor.searchedTag, "Tag1")
        XCTAssertEqual(imageInteractor.pageToLoad, 3)
    }
    
    func test_searching_different_tags() {
        
        let expectation = self.expectation(description: "Loading first results")
        let expectation2 = self.expectation(description: "Loading next results")
        
        imageInteractor.getFirstPageOfResults(forTag: "Tag1") { (viewModels, error) in
            
            expectation.fulfill()
            
            self.imageInteractor.getFirstPageOfResults(forTag: "Tag2") { (viewModels, error) in
                
                expectation2.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(imageInteractor.searchedTag, "Tag2")
        XCTAssertEqual(imageInteractor.pageToLoad, 2)
    }
    
    func test_get_next_page_without_fetching_first_page() {
        
        let expectation = self.expectation(description: "Loading results")
        var vm: [ImageViewModel]?
        
        imageInteractor.getNextPageOfResults { (viewModels, error) in
            vm = viewModels
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNil(vm, "Should not have returned any view models")
        XCTAssertEqual(imageInteractor.searchedTag, "")
        XCTAssertEqual(imageInteractor.pageToLoad, 1, "Should not have incremented pageToLoad")
    }
    
    func test_searching_empty_tag() {
        
        let expectation = self.expectation(description: "Loading results")
        var vm: [ImageViewModel]?
        
        imageInteractor.getFirstPageOfResults(forTag: "") { (viewModels, error) in
            vm = viewModels
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNil(vm, "Should not have returned any view models")
        XCTAssertEqual(imageInteractor.pageToLoad, 1, "Should not have incremented pageToLoad")
    }
}
