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

    static func == (lhs: Watchlist, rhs: Watchlist) -> Bool {
        lhs.id == rhs.id
    }
}

extension Watchlist {
    static let defaultWatchlist = Watchlist(name: "My Watchlist")
}
