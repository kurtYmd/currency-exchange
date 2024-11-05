//
//  User.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 14/10/2024.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var fullname: String
    var email: String
    var balance: Double = 0.0
    var transactionHistory: [Transaction] = []
    
    var intials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
