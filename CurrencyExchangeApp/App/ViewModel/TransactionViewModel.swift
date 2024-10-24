//
//  TransactionViewModel.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import Foundation
import Combine

class CurrencyViewModel: ObservableObject {
    @Published var rates: [Rate] = [] // Published variable for SwiftUI to observe
    @Published var errorMessage: String? = nil
    
    private var cancellable: AnyCancellable?
    
    init() {
        fetchCurrencyRates()
    }
    
    // Fetch currency rates from the API
    func fetchCurrencyRates() {
        let urlString = "https://api.nbp.pl/api/exchangerates/tables/A?format=json"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [CurrencyRates].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Failed to fetch data: \(error)"
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] currencyRates in
                self?.rates = currencyRates.first?.rates ?? []
            })
    }
}

