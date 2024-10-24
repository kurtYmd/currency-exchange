//
//  CurrencyListView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import SwiftUI

struct CurrencyListView: View {
    @StateObject private var viewModel = CurrencyViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.rates, id: \.code) { rate in
                HStack {
                    VStack(alignment: .leading) {
                        Text(rate.code)
                            .font(.title2)
                            .bold()
                        Text(rate.currency.capitalized)
                            .foregroundStyle(Color(.secondaryLabel))
                            .font(.caption)
                    }
                    Spacer()
                    VStack {
                        Text(String(format: "%.4f", rate.mid) + "zł")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Currencies")
            .onAppear {
                viewModel.fetchCurrencyRates()
            }
        }
    }
}

#Preview {
    CurrencyListView()
}
