//
//  BuyView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 25/10/2024.
//

import SwiftUI

struct BuyView: View {
    let rate: Rate
    
    var body: some View {
        VStack {
            Text("Buy \(rate.code)")
        }
        .padding()
    }
}

#Preview {
    BuyView(rate: Rate(currency: "US Dollar", code: "USD", mid: 0.0))
}
