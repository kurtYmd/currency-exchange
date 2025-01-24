//
//  WatchlistEntry.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 23/01/2025.
//

import Foundation

struct WatchlistEntry: Codable, Identifiable {
    var id: String {
        code
    }
    let currency: String
    let code: String
}
