//
//  SearchViewControllerTests.swift
//  StockUITests
//
//  Created by Nuhu Sulemana on 25/01/2024.
//

import Foundation
import XCTest
import Combine

@testable import Stock


class SearchViewControllerTests: XCTestCase {
    var sut: SearchViewController!
    
    override func setUp() {
        super.setUp()
        sut = SearchViewController()
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSearchViewControllerHasSearchBar() {
        XCTAssertNotNil(sut.searchBar)
    }
    
    func testSearchViewControllerHasTableView() {
        XCTAssertNotNil(sut.tableView)
    }
    
    func testSearchViewControllerHasImageView() {
        XCTAssertNotNil(sut.imageView)
    }
    
    func testSearchViewControllerHasLabel() {
        XCTAssertNotNil(sut.label)
    }
    
    func testSearchViewControllerHasTextView() {
        XCTAssertNotNil(sut.textView)
    }
    
    func testSearchViewControllerHasViewModel() {
        XCTAssertNotNil(sut.viewModel)
    }
    
    func testSearchResultsStartEmpty() {
        XCTAssertTrue(sut.searchResults.isEmpty)
    }
    
    func testSearchBarDelegateIsSet() {
        XCTAssertNotNil(sut.searchBar.delegate)
    }
    
    func testTableViewDataSourceIsSet() {
        XCTAssertNotNil(sut.tableView.dataSource)
    }
    
    func testTableViewDelegateIsSet() {
        XCTAssertNotNil(sut.tableView.delegate)
    }
    
    func testTableViewDidSelectRowAt() {
        let indexPath = IndexPath(row: 0, section: 0)

           // Use XCTestExpectation for the asynchronous part
           let expectation = XCTestExpectation(description: "Wait for animation")

           sut.tableView(sut.tableView, didSelectRowAt: indexPath)

           // Fulfill the expectation after a short delay to allow time for animations
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               
               XCTAssertFalse(self.sut.searchBar.isFirstResponder)

               // Fulfill the expectation
               expectation.fulfill()
           }

           // Wait for the expectation with a timeout
           wait(for: [expectation], timeout: 1.0)
    }
    
    func testViewModelFetchCompanyDetails() {
        let symbol = "AAPL" // Replace with a valid symbol for your tests
        sut.viewModel.fetchCompanyDetails(symbol: symbol)
        
        // API call is triggered
        XCTAssertTrue(sut.viewModel.cancellables.count > 0)
    }
    
    func testUpdateUIWithCompanyDetails() {
        // a sample CompanyDetails object for testing
        let companyDetails =  CompanyDetails(symbol: "AAGIY", website: "https://www.aia.com",
                                             description: "sampleDescription", image: "https://financialmodelingprep.com/image-stock/AAGIY.png")
        sut.viewModel.companyDetails = companyDetails
        sut.updateUI()
        
        //  image view is updated with the expected image
        if let actualIdentifier = sut.imageView.image?.accessibilityIdentifier {
            XCTAssertEqual(actualIdentifier, "https://financialmodelingprep.com/image-stock/AAGIY.png")
        }
        
        // text view are updated with the expected content
        XCTAssertEqual(sut.label.text, "https://www.aia.com")
        XCTAssertEqual(sut.textView.text, "sampleDescription")
    }
//    func testHandleSearchError() {
//        let error = APIError(errorMessage: "Limit reached. Please upgrade your plan or visit our documentation for more details at https://site.financialmodelingprep.com/")
//            sut.handleSearchError(error)
//
//            // Wait for the presentation animation to complete
//            RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))
//
//            // alert is presented
//            XCTAssertTrue(sut.presentedViewController is UIAlertController)
//    }
}
