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

        imageInteractor = ImageInteractor(client: MockImageClient.shared)
    }
    
    override func tearDown() {
        imageInteractor = nil
        super.tearDown()
    }
    
    func test_get_first_page() {
        
        XCTAssertEqual(imageInteractor.pageToLoad, 1, "Page to load should be 1 after initialization")
        
        let expectation = self.expectation(description: "Loading first page of results")
        
        imageInteractor.getFirstPageOfResults(forTag: "Tag1") { (viewModels, error) in
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(imageInteractor.searchedTag, "Tag1", "Interactor should remember the tag that was searched")
        XCTAssertEqual(imageInteractor.pageToLoad, 2, "Page to load should have incremented to 2")
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
    
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertEqual(imageInteractor.searchedTag, "Tag1")
        XCTAssertEqual(imageInteractor.pageToLoad, 3,
                       "Page to load should have incremented to 3 after initial fetch and following page")
    }
    
    func test_searching_different_tags() {
        
        let expectation = self.expectation(description: "Loading results")
        let expectation2 = self.expectation(description: "Loading different results")
        
        imageInteractor.getFirstPageOfResults(forTag: "Tag1") { (viewModels, error) in
            
            expectation.fulfill()
            
            self.imageInteractor.getFirstPageOfResults(forTag: "Tag2") { (viewModels, error) in
                
                expectation2.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        
        XCTAssertEqual(imageInteractor.searchedTag, "Tag2")
        XCTAssertEqual(imageInteractor.pageToLoad, 2)
    }
    
    func test_get_next_page_without_fetching_first_page() {
        
        let expectation = self.expectation(description: "Loading next page without first")
        var vm: [ImageViewModel]?
        
        imageInteractor.getNextPageOfResults { (viewModels, error) in
            
            XCTAssertEqual(error, NetworkError.mustFetchFirstPageFirst)
            
            vm = viewModels
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNil(vm, "Should not have returned any view models")
        XCTAssertEqual(imageInteractor.searchedTag, "", "No tag should have been searched")
        XCTAssertEqual(imageInteractor.pageToLoad, 1, "Should not have incremented pageToLoad")
    }
    
    func test_searching_empty_tag() {
        
        let expectation = self.expectation(description: "Loading results for empty tag")
        var vm: [ImageViewModel]?
        
        imageInteractor.getFirstPageOfResults(forTag: "") { (viewModels, error) in
            
            XCTAssertEqual(error, NetworkError.invalidTag)
            
            vm = viewModels
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNil(vm, "Should not have returned any view models")
        XCTAssertEqual(imageInteractor.pageToLoad, 1, "Should not have incremented pageToLoad")
    }
}
