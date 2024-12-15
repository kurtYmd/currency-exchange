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
    
    var body: some View {
        if viewModel.currentUser != nil {
            NavigationStack {
                List {
                    Section {
                        listOfUserCurrency
                    } header: {
                        VStack(spacing: 8) {
                            userTotalBalance
                            addMoneyButton
                        }
                        .background(Color.clear)
                        .padding(.vertical)
                        .textCase(nil)
                    }
                    Section {
                        NavigationLink(destination: transactionHistory) {
                            transactionHistoryLabel
                        }
                    }
                }
                .buttonStyle(BorderlessButtonStyle())
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Wallet")
                .sheet(isPresented: $showSheet) {
                    TopUpSheetView(amount: $amount)
                }
            }
        }
    }
    
    @ViewBuilder
    fileprivate var transactionHistory: some View {
        if viewModel.currentUser?.transactionHistory.isEmpty == true {
            ContentUnavailableView("No recent transactions", systemImage: "clock.fill")
        } else {
            ScrollView {
                ForEach(viewModel.currentUser?.transactionHistory ?? [], id: \.date) { transaction in
                    transactionRow(transaction: transaction)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    fileprivate var transactionHistoryLabel: some View {
        HStack {
            Image(systemName: "list.star")
                .modifier(IconModifier(shape: AnyShape(RoundedRectangle(cornerRadius: 10))))
            Text("Transaction history")
                .foregroundStyle(Color(.secondaryLabel))
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
                    .modifier(IconModifier())
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
    
    fileprivate var addMoneyButton: some View {
        Button {
            showSheet.toggle()
        } label: {
            Text("Add Money")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.white)
                .frame(width: 120, height: 40)
                .background(Color(.systemBlue))
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    fileprivate var userTotalBalance: some View {
        VStack {
            Text("Total balance")
                .font(.title3)
                .foregroundStyle(Color(.secondaryLabel))
            Text(String(format: "%.2f PLN", viewModel.currentUser?.balance["PLN"] ?? 0.0))
                .contentTransition(.numericText())
                .font(.system(size: 44, weight: .bold))
        }
    }
    
    fileprivate var listOfUserCurrency: some View {
        ForEach(Array((viewModel.currentUser?.balance.keys)!), id: \.self) { currency in
            if viewModel.currentUser?.balance[currency] != 0.0 {
                HStack {
                    Text("\(currency)")
                        .modifier(IconModifier(font: .caption))
                    VStack(alignment: .leading) {
                        Text("\(currency)")
                        Text(String(format: "%.1f", viewModel.currentUser?.balance[currency] ?? 0.0))
                    }
                }
            }
        }
    }
}

struct IconModifier: ViewModifier {
    var font: Font = .title
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
