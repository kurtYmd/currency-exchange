//
//  SellView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 25/10/2024.
//

import SwiftUI

struct SellView: View {
    let rate: Rate
    
    var body: some View {
        VStack {
            Text("Sell \(rate.code)")
            // Add your sell view content here
        }
        .padding()
    }
}

#Preview {
    SellView(rate: Rate(currency: "US Dollar", code: "USD", mid: 0.0))
}
