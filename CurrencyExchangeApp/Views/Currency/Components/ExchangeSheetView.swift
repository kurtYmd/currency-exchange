//
//  ExchangeSheetView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 29/10/2024.
//

import SwiftUI

struct ExchangeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: AuthViewModel
    let rate: Rate
    @State var transactionType: TransactionType
    @State var isPresented = false
    @State var amount: String
    //TODO: Add animation if can't exchange due to error
    
    var body: some View {
        if viewModel.currentUser != nil {
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
                                isPresented = true
                            } label: {
                                Text("Buy")
                            }
                            // Handle amount validation
                            .disabled(amount.isEmpty)
                        } else if transactionType == .sell {
                            Button {
                                isPresented = true
                            } label: {
                                Text("Sell")
                            }
                            // Handle amount validation
                            .disabled(amount.isEmpty)
                        }
                    }
                }
                .confirmationDialog("Transaction Confirmation", isPresented: $isPresented) {
                    if transactionType == .buy {
                        Button("Buy \(amount) \(rate.code)", role: .destructive) {
                            Task {
                                try await viewModel.buyCurrency(amount: Double(amount) ?? 0.0, currencyCode: rate.code, rate: rate.mid ?? 0.0)
                            }
                            isPresented = false
                        }
                    } else {
                        Button("Sell \(amount) \(rate.code)", role: .destructive) {
                            Task {
                                try await viewModel.sellCurrency(amount: Double(amount) ?? 0.0, currencyCode: rate.code, rate: rate.mid ?? 0.0)
                            }
                            isPresented = false
                        }
                    }
                    Button ("Cancel Transaction", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to " + (transactionType == .buy ? "buy": "sell") + " \(amount) \(rate.code)")
                }
            }
        }
    }
}

#Preview {
    ExchangeSheetView(rate: Rate(currency: "US Dollar", code: "USD", mid: 0.0), transactionType: .buy, amount: "")
}
