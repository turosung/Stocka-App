//
//  CompanyDetailsModel.swift
//  Stocka
//
//  Created by Nuhu Sulemana on 25/01/2024.
//

import Foundation

struct CompanyDetails: Codable {
    let symbol: String?
    let website: String?
    let description: String?
    let image: String?
}
typealias CompanyDetailsList = [CompanyDetails]
