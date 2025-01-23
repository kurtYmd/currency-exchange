//
//  Watchlist.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 13/11/2024.
//

import Foundation

struct Watchlist: Codable, Identifiable, Hashable {
    var id: String {
        name
    }
    var name: String
    var rates: [Rate] = []
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func toDictionary() -> [String: Any] {
           let ratesDict = rates.map { rate in
               [
                   "currency": rate.currency,
                   "code": rate.code,
               ]
           }
           return [
               "name": name,
               "rates": ratesDict
           ]
       }
}

extension Watchlist {
    static let defaultWatchlist = Watchlist(name: "My Watchlist")
}
