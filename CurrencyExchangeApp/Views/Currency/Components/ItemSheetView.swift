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
    @State private var sheetType: SheetType? = nil
    
    enum SheetType: Identifiable {
        case buy, sell
        
        var id: Int {
            switch self {
            case .buy: return 0
            case .sell: return 1
            }
        }
    }
    
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
                    sheetType = .buy
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
                    sheetType = .sell
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
        .sheet(item: $sheetType) { type in
            NavigationStack {
                Group {
                    switch type {
                    case .buy:
                        ExchangeSheetView(rate: rate, transactionType: "Buy", amount: "")
                    case .sell:
                        ExchangeSheetView(rate: rate, transactionType: "Sell", amount: "")
                    }
                }
                .navigationTitle(type == .buy ? "Buy \(rate.code)" : "Sell \(rate.code)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            sheetType = nil
                        } label : {
                            Image(systemName: "xmark.circle.fill")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            .presentationDetents([.height(200)])
        }
    }
}

#Preview {
    ItemSheetView(rate: Rate(currency: "US Dollar", code: "USD", mid: 0.0))
}
