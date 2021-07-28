//
//  Network Errors.swift
//  Virtual Tourists
//
//  Created by Sushma Adiga on 27/07/21.
//

import Foundation


enum NetworkErrors: Error {
    case invalidComponents
    case invalidURL
    case nilData
    case httpError
}
