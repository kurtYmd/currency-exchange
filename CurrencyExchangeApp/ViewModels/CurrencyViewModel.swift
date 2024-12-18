//
//  TransactionViewModel.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import Foundation
import Combine

class CurrencyViewModel: ObservableObject {
    @Published var rates: [Rate] = []
    @Published var errorMessage: String? = nil
    @Published var effectiveDate: String? = nil
    @Published var searchText: String = ""
    
    private var cancellable: AnyCancellable?
    
    init() {
        fetchCurrencyRates()
    }
    
//    func filterWatchlist(rates: [Rate]) -> [Rate] {
//        return rates.filter { rates.contains($0) }
//    }
    
    var filterCurrency: [Rate] {
        guard !searchText.isEmpty else { return rates }
        
        return rates.filter { rate in
            rate.code.lowercased().contains(searchText.lowercased()) || rate.currency.lowercased().contains(searchText.lowercased())
        }
    }
    
    func fetchCurrencyRates() {
        let urlString = "https://api.nbp.pl/api/exchangerates/tables/A?format=json"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .map { $0.data }
            .decode(type: [CurrencyRates].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch data: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] currencyRates in
                self?.rates = currencyRates.first?.rates ?? []
                self?.effectiveDate = currencyRates.first?.effectiveDate
            })
    }
}

