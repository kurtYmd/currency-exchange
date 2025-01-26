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
    @State var amount: String = ""
    @State var receiveValue: String = ""

    var body: some View {
        if viewModel.currentUser != nil {
            NavigationStack {
                exchange
                Spacer()
                exchangeButton
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
                        Button("Buy \(receiveValue) \(rate.code)", role: .destructive) {
                            Task {
                                try await viewModel.buyCurrency(amount: Double(amount) ?? 0.0, currencyCode: rate.code, rate: rate.mid ?? 0.0)
                            }
                            isPresented = false
                        }
                    } else {
                        Button("Sell \(receiveValue) \(rate.code)", role: .destructive) {
                            Task {
                                try await viewModel.sellCurrency(amount: Double(amount) ?? 0.0, currencyCode: rate.code, rate: rate.mid ?? 0.0)
                            }
                            isPresented = false
                        }
                    }
                    Button ("Cancel Transaction", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to " + (transactionType == .buy ? "buy": "sell") + " \(amount) \(transactionType == .buy ? "PLN" : rate.code)")
                }
            }
        }
    }

    @ViewBuilder
    private var exchange: some View {
        VStack {
            if transactionType == .buy {
                VStack(alignment: .leading) {
                    HStack {
                        Text("You pay")
                        Spacer()
                        HStack {
                            Text("Max:")
                            Text(String(format: "%.0f \("PLN")", viewModel.currentUser?.balance["PLN"] ?? 0.0))
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    HStack {
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 55))
                            .bold()
                        Text("PLN")
                            .foregroundStyle(Color.secondary)
                            .font(.system(size: 55))
                            .bold()
                    }
                }
                .padding(.top)
            } else if transactionType == .sell {
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
                        TextField("0", text: $receiveValue)
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
                .padding(.top)
            }
            
            toggleExchangeType

            if transactionType == .buy {
                VStack(alignment: .leading) {
                    HStack {
                        Text("You receive")
                    }
                    HStack {
                        TextField("0", text: $receiveValue)
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
            } else if transactionType == .sell {
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
                        Text("PLN")
                            .foregroundStyle(Color.secondary)
                            .font(.system(size: 55))
                            .bold()
                    }
                }
            }
        }
        .padding(.horizontal)
        .onChange(of: amount) { oldValue, newValue in
            let value = (Double(newValue) ?? 0) * /*(rate.mid ?? 0)*/ 2
            receiveValue = String(format: "%.3f", value)
        }
        .onChange(of: receiveValue) { oldValue, newValue in
            let value = (Double(newValue) ?? 0) / /*(rate.mid ?? 0)*/ 2
            amount = String(format: "%.3f", value)
        }
    }
    
    private func calculcateAmount(amount: String) {
        
        
    }
    
    private var exchangeButton: some View {
        Button {
            isPresented = true
        } label: {
            Text("Exchange")
        }
        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .disabled(amount.isEmpty)
        .padding(.bottom)
    }

    private var toggleExchangeType: some View {
        ZStack(alignment: .trailing) {
            Divider()
            Button {
                transactionType = transactionType == .buy ? .sell : .buy
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.largeTitle)
                    .symbolEffect(transactionType == .buy ? .rotate.clockwise.byLayer : .rotate.counterClockwise.byLayer, options: .speed(10),value: transactionType)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 10)
        }
        .padding(.vertical, 10)
    }
}
