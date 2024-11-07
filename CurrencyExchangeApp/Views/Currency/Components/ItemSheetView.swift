//
//  ItemSheetView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 25/10/2024.
//

import SwiftUI

struct ItemSheetView: View {
    let rate: Rate
    @Environment(\.dismiss) private var dismiss
    @State private var isPresented = false
    @State private var transactionType: TransactionType = .buy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: -5) {
                    Text(rate.code)
                        .font(.largeTitle)
                        .bold()
                    Text(rate.currency.capitalized)
                        .foregroundStyle(Color(.secondaryLabel))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(.top)
            
            Divider()
            
            VStack(alignment: .leading) {
                Text(String(format: "%.2f", rate.mid))
                    .fontWeight(.semibold)
                Text("\(rate.currency.capitalized) • \(rate.code)")
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 15) {
                Button {
                    presentExchangeSheet(for: .buy)
                } label: {
                    Text("Buy")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemGreen))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    presentExchangeSheet(for: .sell)
                } label: {
                    Text("Sell")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemRed))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .sheet(isPresented: $isPresented) {
            ExchangeSheetView(rate: rate, transactionType: transactionType, amount: "")
                .presentationDetents([.height(200)])
        }
    }
    private func presentExchangeSheet(for type: TransactionType) {
        transactionType = type
        isPresented = true
    }
}

#Preview {
    ItemSheetView(rate: Rate(currency: "US Dollar", code: "USD", mid: 0.0))
}
