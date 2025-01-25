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
    @State var transactionType: TransactionType = .buy
    @State var isPresented = false
    @State var amount: String
    //TODO: Add animation if can't exchange due to error
    
    var body: some View {
        if viewModel.currentUser != nil {
            NavigationStack {
                VStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("You pay")
                            Spacer()
                            HStack {
                                Text("Max:")
                                Text(String(format: "%.0f \(rate.code)", viewModel.currentUser?.balance[rate.code] ?? 0.0))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        HStack {
                            TextField("0", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
    //                            .multilineTextAlignment(.center)
                                .font(.system(size: 55))
                                .bold()
    //                            .padding(.horizontal)
                            Text(rate.code)
                                .foregroundStyle(Color.secondary)
                                .font(.system(size: 55))
                                .bold()
                        }
                    }
                    .padding(.top)
                    ZStack(alignment: .trailing) {
                        Divider()
                        Button {
                            
                        } label : {
                            HStack(spacing: -5) {
                                Image(systemName: "arrow.up")
                                    .symbolEffect(.wiggle.up.byLayer, options: .repeat(.continuous))
                                Image(systemName: "arrow.down")
                                    .symbolEffect(.wiggle.down.byLayer, options: .repeat(.continuous))
                            }
                            .iconStyle(font: .title2, fontColor: .black)
                        }
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Text("You receive")
                        }
                        HStack {
                            TextField("0", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 55))
                                .bold()
                            Text(rate.code)
                                .foregroundStyle(Color.secondary)
                                .font(.system(size: 55))
                                .bold()
                        }
                    }
                }
                .padding(.horizontal)
                Spacer()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
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
