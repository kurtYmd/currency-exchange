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
    @FocusState private var focusedField: Field?
    
    enum Field {
        case first, second
    }
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private var maxPLN: Double {
        viewModel.currentUser?.balance["PLN"] ?? 0.0
    }
    
    private var maxExchange: Double {
        viewModel.currentUser?.balance[rate.code] ?? 0.0
    }

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
                                try await viewModel.buyCurrency(amount:  Double(receiveValue) ?? 0.0, currencyCode: rate.code, rate: rate.mid ?? 0.0)
                            }
                            isPresented = false
                        }
                    } else {
                        Button("Sell \(receiveValue) \(rate.code)", role: .destructive) {
                            Task {
                                try await viewModel.sellCurrency(amount: Double(receiveValue) ?? 0.0, currencyCode: rate.code, rate: rate.mid ?? 0.0)
                            }
                            isPresented = false
                        }
                    }
                    Button ("Cancel Transaction", role: .cancel) { }
                } message: {
                    if transactionType == .buy {
                        Text("Are you sure you want to buy \(receiveValue) \(rate.code)?")
                    } else if transactionType == .sell {
                        Text("Are you sure you want to sell \(receiveValue) \(rate.code)?")
                    }
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
                                .onTapGesture {
                                    amount = formatter.string(from: NSNumber(value: maxPLN)) ?? ""
                                }
                            Text(String(format: "%.0f \("PLN")", maxPLN))
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            TextField("0", text: $amount)
                                .focused($focusedField, equals: .first)
                                .foregroundStyle((Double(amount) ?? 0.0 > maxPLN ? Color.red : Color.primary))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 55))
                                .bold()
                            Text("Not enough funds.")
                                .opacity(Double(amount) ?? 0.0 > maxPLN ? 1 : 0)
                                .font(.caption)
                                .foregroundStyle(Color.red)
                        }
                        
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
                                .onTapGesture {
                                    receiveValue = formatter.string(from: NSNumber(value: maxExchange)) ?? ""
                                }
                            Text(String(format: "%.0f \(rate.code)", maxExchange))
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            TextField("0", text: $receiveValue)
                                .focused($focusedField, equals: .second)
                                .foregroundStyle((Double(amount) ?? 0.0 > maxExchange ? Color.red : Color.primary))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 55))
                                .bold()
                            Text("Not enough funds.")
                                .opacity(Double(receiveValue) ?? 0.0 > maxExchange ? 1 : 0)
                                .font(.caption)
                                .foregroundStyle(Color.red)
                        }
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
                            .focused($focusedField, equals: .second)
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
                            .focused($focusedField, equals: .first)
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
            if focusedField == .first {
                if newValue.isEmpty {
                    receiveValue = ""
                } else {
                    let value = (Double(newValue) ?? 0) / (rate.mid ?? 0)
                    receiveValue = String(format: "%.3f", value)
                }
            }
        }
        .onChange(of: receiveValue) { oldValue, newValue in
            if focusedField == .second {
                if newValue.isEmpty {
                    amount = ""
                } else {
                    let value = (Double(newValue) ?? 0) * (rate.mid ?? 0)
                    amount = String(format: "%.3f", value)
                }
            }
        }
    }
    
    private var exchangeButton: some View {
        HStack(spacing: 15) {
            Button {
                isPresented = true
            } label: {
                VStack {
                    Text("Review Order")
                        .fontWeight(.semibold)
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .disabled(!exchangeIsValid)
        .padding()
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

extension ExchangeSheetView: ExchangeProtocol {
    var exchangeIsValid: Bool {
        guard let amountValue = Double(amount), let receiveValue = Double(receiveValue) else {
            return false
        }
        
        return amountValue > 0 &&
        receiveValue > 0 &&
        
        focusedField == .first && amountValue <= maxPLN ||
        focusedField == .second && receiveValue <= maxExchange && amountValue != 0
    }
}
