//
//  APIError.swift
//  Stocka
//
//  Created by Nuhu Sulemana on 25/01/2024.
//

import Foundation

// MARK: - APIError
struct APIError: Codable, Error {
    let errorMessage: String

    enum CodingKeys: String, CodingKey {
        case errorMessage = "Error Message"
    }
}
