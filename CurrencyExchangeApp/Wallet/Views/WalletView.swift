//
//  WalletView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import SwiftUI

struct WalletView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @State private var showSheet = false
    @State private var amount: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showAllTransactions = false
    @State private var showProfile = false
    
    var body: some View {
        if viewModel.currentUser != nil {
            NavigationStack {
                List {
                    Section {
                        userTotalBalance
                    }
                    Section {
                        listOfUserCurrency
                    } header : {
                        Text("Available Currencies")
                    }
                    .headerProminence(.increased)
                    NavigationLink(destination: transactionHistory) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .iconStyle(font: .title, shape: AnyShape(RoundedRectangle(cornerRadius: 10)))
                            Text("Transaction History")
                        }
                    }
                }
                .navigationTitle("Wallet")
                .sheet(isPresented: $showProfile) {
                    ProfileView()
                }
                .sheet(isPresented: $showSheet) {
                    TopUpSheetView(amount: $amount)
                }
                .toolbar(content: {
                    toolbar
                })
            }
        }
    }
    
    @ViewBuilder
    fileprivate var transactionHistory: some View {
        if let transactions = viewModel.currentUser?.transactionHistory, !transactions.isEmpty {
            List {
                ForEach(transactions, id: \.date) { transaction in
                    transactionRow(transaction: transaction)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .toolbar {
                sortToolbar
            }
        } else {
            ContentUnavailableView("No recent transactions", systemImage: "clock")
        }
    }
    
    @ViewBuilder
    fileprivate func transactionRow(transaction: Transaction) -> some View {
        if transaction.type == .buy || transaction.type == .sell {
            HStack(alignment: .center) {
                Image(systemName: "arrow.left.arrow.right")
                    .iconStyle(font: .title2, fontWeight: .regular)
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(transaction.currencyFrom ?? "N/A")" + " to " + "\(transaction.currencyTo ?? "N/A")")
                            .bold()
                    }
                    // TODO: Format date
                    Text("\(transaction.date.displayFormat)")
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                VStack(alignment: .center) {
                    HStack {
                        Text(String(format: "%.2f", transaction.amount) + " \(transaction.currencyTo ?? "N/A")")
                            .bold()
                    }
                }
            }
        } else if transaction.type == .topUp {
            HStack(alignment: .center) {
                Image(systemName: "arrow.down.to.line.alt")
                    .iconStyle(font: .title2, fontWeight: .regular)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Deposit in " + "\(transaction.currencyTo ?? "N/A")")
                            .bold()
                    }
                    Text("\(transaction.date.displayFormat)")
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                VStack(alignment: .center) {
                    HStack {
                        Text(String(format: "+%.2f", transaction.amount) + " \(transaction.currencyTo ?? "N/A")")
                            .bold()
                    }
                    .foregroundStyle(Color(.systemGreen))
                }
            }
        }
    }
    
    fileprivate var sortToolbar: some View {
        Menu {
            Button {
                
            } label : {
                Text("Show All")
                Image(systemName: "tray.full")
            }
            Button {
                
            } label : {
                Text("Show Exchanges")
                Image(systemName: "arrow.left.arrow.right")
            }
            Button {
                
            } label : {
                Text("Show Deposits")
                Image(systemName: "arrow.down.to.line.alt")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
    
    //TODO: Hide all recent transaction
    fileprivate var toolbar: some View {
        Menu {
            Button {
                showProfile.toggle()
            } label : {
                Text("Account")
                Image(systemName: "person.circle")
            }
            Button {
                showSheet.toggle()
            } label : {
                Text("Add Money")
                Image(systemName: "polishzlotysign.circle")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
    
    //TODO: Show Total Balance (not only in PLN)
    fileprivate var userTotalBalance: some View {
        VStack(alignment: .leading) {
            Text("Balance")
                //.font(.title3)
                .foregroundStyle(Color(.secondaryLabel))
            Text(String(format: "%.2f PLN", viewModel.currentUser?.balance["PLN"] ?? 0.0))
                //.contentTransition(.numericText())
                .font(.system(size: 20, weight: .bold))
        }
    }
    
    @ViewBuilder
    fileprivate var listOfUserCurrency: some View {
        ForEach(Array((viewModel.currentUser?.balance.keys)!), id: \.self) { currency in
            if viewModel.currentUser?.balance[currency] != 0.0 {
                HStack {
                    Text("\(currency)")
                        .iconStyle(font: .caption)
                    Text(String(format: "%.1f", viewModel.currentUser?.balance[currency] ?? 0.0))
                        .font(.headline)
                }
            } else {
                ContentUnavailableView("Your currency list is empty", systemImage: "dollarsign")
            }
        }
    }
}




#Preview {
    WalletView()
}
