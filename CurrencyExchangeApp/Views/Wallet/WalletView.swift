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
                    NavigationLink(destination: transactionHistory) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .iconStyle(font: .title, shape: AnyShape(RoundedRectangle(cornerRadius: 10)))
                            Text("Transaction History")
                        }
                    }
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
            List {
                ForEach(transactions, id: \.date) { transaction in
                    transactionRow(transaction: transaction)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
        } else {
            ContentUnavailableView("No recent transactions", systemImage: "clock")
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
                    Text("\(transaction.date.displayFormat)")
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

//TODO: Make extension 
struct IconModifier: ViewModifier {
    var font: Font = .title
    var shape: AnyShape = AnyShape(Circle())
    var fontColor: Color = .white
    var backgroundColor: UIColor = .systemGray3
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(fontColor)
            .fontWeight(.semibold)
            .frame(width: 40, height: 40)
            .background(Color(backgroundColor))
            .clipShape(shape)
            .padding(2)
    }
}

extension View {
    func iconStyle(font: Font = .title,shape: AnyShape = AnyShape(Circle()),fontColor: Color = .white, backgroundColor: UIColor = .systemGray3) -> some View {
        modifier(IconModifier(font: font, shape: shape, fontColor: fontColor, backgroundColor: backgroundColor))
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
