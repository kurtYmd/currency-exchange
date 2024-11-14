//
//  Transaction.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 14/10/2024.
//

import Foundation
import FirebaseFirestore

struct Transaction: Codable {
    let currencyFrom: String?
    let currencyTo: String?
    let amount: Double
    let type: TransactionType
    let date: Date
    
    init(currencyFrom: String? = nil, currencyTo: String? = nil, amount: Double, type: TransactionType, date: Date) {
        self.currencyFrom = currencyFrom
        self.currencyTo = currencyTo
        self.amount = amount
        self.type = type
        self.date = date
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "amount": amount,
            "type": type.rawValue,
            "date": Timestamp(date: date)
        ]
        if let currencyFrom = currencyFrom {dict["currencyFrom"] = currencyFrom }
        if let currencyTo = currencyTo { dict["currencyTo"] = currencyTo }
        return dict
    }
}
