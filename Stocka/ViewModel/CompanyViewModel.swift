//
//  CompanyViewModel.swift
//  Stocka
//
//  Created by Nuhu Sulemana on 25/01/2024.
//

import Foundation
import Combine

class CompanyViewModel: ObservableObject {
    @Published var companyDetails: CompanyDetails?
    
    var cancellables: Set<AnyCancellable> = []
    
    func fetchCompanyDetails(symbol: String) {
        let apiURL = "\(AppConfig.baseURL)profile/\(symbol)?apikey=\(AppConfig.apiKey)"
        
        URLSession.shared.dataTaskPublisher(for: URL(string: apiURL)!)
            .map(\.data)
            .decode(type: [CompanyDetails].self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .finished:
                    break // Do nothing on success
                case .failure(let error):
                    print("Failed to fetch company details: \(error)")
                }
            } receiveValue: { [weak self] details in
                self?.companyDetails = details.first
            }
            .store(in: &cancellables)
    }
}
