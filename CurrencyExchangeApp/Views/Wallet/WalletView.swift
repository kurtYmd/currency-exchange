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
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Total balance")
                            .font(.title3)
                            .foregroundStyle(Color(.secondaryLabel))
                        
                        Text(String(format: "%.2f PLN", viewModel.currentUser?.balance["PLN"] ?? 0.0))
                            .contentTransition(.numericText())
                            .font(.system(size: 44, weight: .bold))
                    }
                    .padding(.top, 40)
                    HStack {
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
                    List(Array((viewModel.currentUser?.balance.keys)!), id: \.self) { currency in
                        HStack {
                            Text("\(currency)")
                            Text(String(format: "%.2f", viewModel.currentUser?.balance[currency] ?? 0.0))
                        }
                    }
                }.listStyle(.plain)
                
                if viewModel.currentUser?.transactionHistory.isEmpty == true {
                    ContentUnavailableView("No recent transactions", systemImage: "clock.fill")
                } else {
                    ForEach(viewModel.currentUser?.transactionHistory ?? [], id: \.date) { transaction in
                        HStack {
                            Text("\(transaction.currencyFrom)")
                            Text("\(transaction.currencyTo)")
                            Text("\(transaction.amount)")
                        }
                    }
                }
            }
            .navigationTitle("Wallet")
            .sheet(isPresented: $showSheet) {
                TopUpSheetView(amount: $amount)
            }
        }
    }
}




#Preview {
    WalletView()
}
