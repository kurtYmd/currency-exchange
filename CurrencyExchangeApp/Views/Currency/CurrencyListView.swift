//
//  CurrencyListView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import SwiftUI

struct CurrencyListView: View {
    @StateObject private var viewModel = CurrencyViewModel()
    @State private var selectedRate: Rate? = nil
    
    var body: some View {
        NavigationStack {
            List(viewModel.rates, id: \.code) { rate in
                Button {
                    selectedRate = rate
                    print("Selected Rate: \(String(describing: selectedRate))")
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(rate.code)
                                .foregroundStyle(Color.primary)
                                .font(.title2)
                                .bold()
                            Text(rate.currency.capitalized)
                                .foregroundStyle(Color(.secondaryLabel))
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            Text(String(format: "%.4f", rate.mid) + "zł")
                                .foregroundStyle(Color.primary)
                                .font(.headline)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Currencies")
            .sheet(item: $selectedRate) { rate in
                ItemSheetView(rate: rate)
                    .presentationDetents([.height(250)])
            }
            .refreshable {
                viewModel.fetchCurrencyRates()
            }
            .onAppear {
                viewModel.fetchCurrencyRates()
            }
        }
    }
}

#Preview {
    CurrencyListView()
}
