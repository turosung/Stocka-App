//
//  CompanyViewModelTests.swift
//  StockTests
//
//  Created by Nuhu Sulemana on 26/01/2024.
//

import XCTest
import Combine

@testable import Stock

class CompanyViewModelTests: XCTestCase {
    
    var viewModel: CompanyViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        viewModel = CompanyViewModel()
    }
    
    override func tearDownWithError() throws {
        cancellables.removeAll()
    }
    
    func testFetchCompanyDetails() {
        let symbol = "AAPL"
        
        let expectation = XCTestExpectation(description: "Wait for fetch completion")
        
        viewModel.$companyDetails
            .dropFirst() // Ignore initial nil value
            .sink { details in
                XCTAssertNotNil(details)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchCompanyDetails(symbol: symbol)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchCompanyDetailsFailure() {
        let symbol = "INVALID_SYMBOL"
           let expectation = XCTestExpectation(description: "Fetch company details with invalid symbol")

           viewModel.$companyDetails
               .sink { companyDetails in
                   XCTAssertNil(companyDetails)
                   expectation.fulfill()
               }
               .store(in: &cancellables)

           viewModel.fetchCompanyDetails(symbol: symbol)

           wait(for: [expectation], timeout: 5.0)
    }
    
}
