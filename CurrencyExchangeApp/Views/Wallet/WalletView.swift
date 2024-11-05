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
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Total balance")
                        .font(.title3)
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    Text(String(format: "%.2f PLN", viewModel.currentUser?.balance ?? 0.0))
                        .contentTransition(.numericText())
                        .font(.system(size: 44, weight: .bold))
                }
                .padding(.top, 40)
                
                if viewModel.currentUser?.transactionHistory.isEmpty == true {
                    ContentUnavailableView("No recent transactions", systemImage: "clock.fill")
                } else {
                    
                }
                
                Button {
                    showSheet.toggle()
                } label: {
                    Text("Add money")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                        .background(Color(.systemBlue))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.bottom, 30)
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
