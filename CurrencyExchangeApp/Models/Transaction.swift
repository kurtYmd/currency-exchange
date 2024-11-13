//
//  Transaction.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 14/10/2024.
//

import Foundation
import FirebaseFirestore

struct Transaction: Codable {
    let currencyFrom: String
    let currencyTo: String
    let amount: Double
    let type: TransactionType
    let date: Date
    
    func toDictionary() -> [String: Any] {
            return [
                "currencyFrom": currencyFrom,
                "currencyTo": currencyTo,
                "amount": amount,
                "type": type,
                "date": Timestamp(date: date) // Firestore uses Timestamp for dates
            ]
        }
}
