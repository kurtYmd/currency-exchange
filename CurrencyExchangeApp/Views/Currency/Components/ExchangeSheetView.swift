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
    @Binding var amount: String
    
    var body: some View {
        VStack {
            Text("\(transactionType) \(rate.code)")
            VStack {
                TextField("0", text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                // Real time conversion 
            }
        }
        .padding()
    }
}

#Preview {
    ExchangeSheetView(rate: Rate(currency: "US Dollar", code: "USD", mid: 0.0), transactionType: "Buy", amount: .constant("0"))

}
