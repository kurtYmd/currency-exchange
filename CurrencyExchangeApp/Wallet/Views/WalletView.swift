//
//  WalletView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import SwiftUI

struct WalletView: View {
    @EnvironmentObject private var viewModel: AuthViewModel
    @StateObject private var currencyViewModel = CurrencyViewModel()
    @State private var showSheet = false
    @State private var amount: String = ""
    @Environment(\.dismiss) private var dismiss
    @State private var showAllAssets = false
    @State private var showProfile = false
    @State private var selectedFilter: TransactionFilter = .all
    
    enum TransactionFilter {
        case all
        case exchanges
        case deposits
    }
    
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
                .onAppear {
                    currencyViewModel.fetchCurrencyRates()
                }
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
        if let transactions = viewModel.currentUser?.transactionHistory {
            let filteredTransactions = transactions.filter { transaction in
                switch selectedFilter {
                case .all:
                    return true
                case .exchanges:
                    return transaction.type == .buy || transaction.type == .sell
                case .deposits:
                    return transaction.type == .topUp
                }
            }
            
            if !filteredTransactions.isEmpty {
                List {
                    ForEach(filteredTransactions, id: \.date) { transaction in
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
                ContentUnavailableView("No transactions found", systemImage: "clock")
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
                selectedFilter = .all
            } label: {
                Label("Show All", systemImage: "tray.full")
            }
            Button {
                selectedFilter = .exchanges
            } label: {
                Label("Show Exchanges", systemImage: "arrow.left.arrow.right")
            }
            Button {
                selectedFilter = .deposits
            } label: {
                Label("Show Deposits", systemImage: "arrow.down.to.line.alt")
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
                if let rate = currencyViewModel.rates.first(where: { $0.code == currency }) {
                    HStack {
                        Text("\(currency)")
                            .iconStyle(font: .caption)
                        VStack(alignment: .leading) {
                            Text("\(rate.currency.capitalized)")
                                .font(.title3)
                                .fontWeight(.medium)
                            HStack(spacing: 0) {
                                Text(String(format: "%.4f", rate.mid ?? "N/A"))
                                Text("zł")
                            }
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                        }
                        Spacer()
                        Text(String(format: "%.1f", viewModel.currentUser?.balance[currency] ?? 0.0))
                            .fontWeight(.semibold)
                    }
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
