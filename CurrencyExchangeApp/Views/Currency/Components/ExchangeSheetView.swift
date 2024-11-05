//
//  ExchangeSheetView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 29/10/2024.
//

import SwiftUI

struct ExchangeSheetView: View {
    let rate: Rate
    var transactionType: String
    @State var amount: String
    
    var body: some View {
        VStack {
            //Text("\(transactionType) \(rate.code)")
            VStack {
                TextField("0", text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                // Real time conversion
                Button {
                    // Handle conversion
                } label: {
                    //create Extension to handle label logic
                        Text(amount.isEmpty || amount == "0" ? "\(transactionType) \(rate.code)": "\(transactionType) \(amount) \(rate.code)")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                }
                .background(Color(.systemBlue))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .disabled(amount.isEmpty)
                .opacity(!amount.isEmpty ? 1.0 : 0.5)
            }
        }
        .padding()
    }
}

#Preview {
    ExchangeSheetView(rate: Rate(id: UUID(), currency: "US Dollar", code: "USD", mid: 0.0), transactionType: "Buy", amount: "")
}
