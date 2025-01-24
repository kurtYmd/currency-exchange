//
//  TransactionViewModel.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import Foundation
import Combine
import SwiftUI

class CurrencyViewModel: ObservableObject {
    @Published var rates: [Rate] = []
    @Published var rateHistory: [RateHistory] = []
    @Published var errorMessage: String? = nil
    @Published var effectiveDate: String? = nil
    @Published var searchText: String = ""
    
    private var cancellable: AnyCancellable?
    
    init() {
        fetchCurrencyRates()
    }
    
   var filterCurrency: [Rate] {
        guard !searchText.isEmpty else { return rates }
        
        return rates.filter { rate in
            rate.code.lowercased().contains(searchText.lowercased()) || rate.currency.lowercased().contains(searchText.lowercased())
        }
    }
    
    func fetchCurrencyRatesHistory(code: String, timeframe: Timeframe) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let currentDateString = dateFormatter.string(from: Date())
        
        let urlString = "https://api.nbp.pl/api/exchangerates/rates/a/\(code)/\(timeframe.dateString)/\(currentDateString)/?format=json"
        
        print("Fetching URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
            }
            return
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .map { $0.data }
            .decode(type: RateHistoryResponse.self, decoder: decoder)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.errorMessage = "Failed to fetch rate history: \(error.localizedDescription)"
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] rateHistoryResponse in
                DispatchQueue.main.async {
                    self?.rateHistory = rateHistoryResponse.rates
                    self?.errorMessage = nil
                }
            })
    }
    
    func getLineColor() -> Color {
            guard let firstRate = rateHistory.first?.mid,
                  let lastRate = rateHistory.last?.mid else {
                return .indigo
            }
            if lastRate > firstRate {
                return .green
            } else if lastRate < firstRate {
                return .red
            } else {
                return .indigo
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
