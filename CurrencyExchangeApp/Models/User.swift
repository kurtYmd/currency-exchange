//
//  User.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 14/10/2024.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let fullname: String
    let email: String
    var balance = ["PLN": 0.0]
    var transactionHistory: [Transaction] = []
    var watchlists: [Watchlist] = [Watchlist.defaultWatchlist]
    
    var intials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
