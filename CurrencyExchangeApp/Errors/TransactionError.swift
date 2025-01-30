//
//  TransactionError.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 30/01/2025.
//

import Foundation

enum TransactionError: Error, LocalizedError {
    case invalidAmount
    case insufficientFunds
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid amount"
        case .insufficientFunds:
            return "Insufficient funds"
        }
    }
}
