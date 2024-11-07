//
//  ExchangeSheetView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 29/10/2024.
//

import SwiftUI

struct ExchangeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let rate: Rate
    @State var transactionType: TransactionType
    @State var isPresented = false
    @State var amount: String
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("0", text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
            }
            .navigationTitle(transactionType == .buy ? "Buy \(rate.code)" : "Sell \(rate.code)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if transactionType == .buy {
                        Button {
                            // Handle buy
                            isPresented = true
                        } label: {
                            Text("Buy")
                        }
                        // Handle amount validation
                        .disabled(amount.isEmpty)
                    } else if transactionType == .sell {
                        Button {
                            isPresented = true
                            // Handle sell
                        } label: {
                            Text("Sell")
                        }
                        // Handle amount validation
                        .disabled(amount.isEmpty)
                    }
                }
            }
            .confirmationDialog("Transaction Confirmation", isPresented: $isPresented) {
                Button((transactionType == .buy ? "Buy": "Sell") + " \(amount) \(rate.code)", role: .destructive) {
                    isPresented = false
                }
                Button ("Cancel Transaction", role: .cancel) { }
            } message: {
                Text("Are you sure you want to " + (transactionType == .buy ? "buy": "sell") + " \(amount) \(rate.code)")
            }
        }
    }
}

#Preview {
    ExchangeSheetView(rate: Rate(currency: "US Dollar", code: "USD", mid: 0.0), transactionType: .buy, amount: "")
}
