//
//  Currenct.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 14/10/2024.
//

import Foundation

struct Rate: Codable, Identifiable, Equatable {
    var id: String {
        code
    }
    let currency: String
    let code: String
    let mid: Double?
}

struct CurrencyRates: Codable {
    let table: String
    let no: String
    let effectiveDate: String
    let rates: [Rate]
}

