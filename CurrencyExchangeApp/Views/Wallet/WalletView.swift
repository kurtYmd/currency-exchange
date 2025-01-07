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
                    Section {
//                        NavigationLink(destination: transactionHistory) {
                        transactionHistory
//                        }
                    } header : {
                        Text("Recent Transactions")
                    }
                    .headerProminence(.increased)
                }
                .navigationTitle("Wallet")
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
            ForEach(showAllTransactions ? transactions : Array(transactions.prefix(5)), id: \.date) { transaction in
                transactionRow(transaction: transaction)
            }
            if let transactionCount = viewModel.currentUser?.transactionHistory.count, transactionCount > 5 {
                Button {
                    showAllTransactions.toggle()
                } label: {
                    HStack {
                        Image(systemName: showAllTransactions ? "eye.slash" : "eye")
                            .contentTransition(.symbolEffect(.replace))
                            .iconStyle(font: .title2)
                        Text(showAllTransactions ? "Show Less" : "Show More")
                            .foregroundStyle(Color(.black))
                            .bold()
                    }
                }
            }
        } else {
            Text("No recent transactions")
                .foregroundColor(.secondary)
                .font(.body.italic())
        }
    }
    
    @ViewBuilder
    fileprivate func transactionRow(transaction: Transaction) -> some View {
        if transaction.type == .buy || transaction.type == .sell {
            HStack {
                Image(systemName: "polishzlotysign.arrow.circlepath")
                    .modifier(IconModifier())
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(transaction.currencyFrom ?? "N/A")")
                            .bold()
                        Image(systemName: "arrow.left.arrow.right")
                        Text("\(transaction.currencyTo ?? "N/A")")
                            .bold()
                    }
                    // TODO: Format date
                    Text("\(transaction.date.displayFormat )")
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("Received")
                    HStack {
                        Text(String(format: "%.2f", transaction.amount) + " \(transaction.currencyTo ?? "N/A")")
                    }
                }
            }
        } else if transaction.type == .topUp {
            HStack {
                Image(systemName: "arrow.down.to.line.alt")
                    .iconStyle()
                VStack(alignment: .leading) {
                    HStack {
                        Text("Deposit in")
                        Text("\(transaction.currencyTo ?? "N/A")")
                            .bold()
                    }
                    Text("\(transaction.date.displayFormat)")
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("Received")
                    HStack {
                        Text(String(format: "%.2f", transaction.amount) + " \(transaction.currencyTo ?? "N/A")")
                    }
                    .foregroundStyle(Color(.systemGreen))
                }
            }
        }
    }
    
    //TODO: Hide all recent transaction
    fileprivate var toolbar: some View {
        Menu {
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
    
    fileprivate var listOfUserCurrency: some View {
        ForEach(Array((viewModel.currentUser?.balance.keys)!), id: \.self) { currency in
            if viewModel.currentUser?.balance[currency] != 0.0 {
                HStack {
                    Text("\(currency)")
                        .iconStyle(font: .caption)
                    VStack(alignment: .leading) {
                        Text("\(currency)")
                        Text(String(format: "%.1f", viewModel.currentUser?.balance[currency] ?? 0.0))
                    }
                }
            }
        }
    }
}

//TODO: Make extension 
struct IconModifier: ViewModifier {
    var font: Font? = .title
    var shape: AnyShape = AnyShape(Circle())
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(Color(.white))
            .fontWeight(.semibold)
            .frame(width: 40, height: 40)
            .background(Color(.systemGray3))
            .clipShape(shape)
            .padding(2)
    }
}

extension View {
    func iconStyle(font: Font? = .title, shape: AnyShape = AnyShape(Circle())) -> some View {
        modifier(IconModifier(font: font, shape: shape))
    }
}

extension Date {
    var displayFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d 'at' h:mm"
        return formatter.string(from: self)
    }
}




#Preview {
    WalletView()
}
