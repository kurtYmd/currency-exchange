//
//  Transaction.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 14/10/2024.
//

import Foundation

struct Transaction {
    var userId: Int
    var currencyFrom: String
    var currencyTo: String
    var amount: Double
    var type: String
    var date: Date
}
