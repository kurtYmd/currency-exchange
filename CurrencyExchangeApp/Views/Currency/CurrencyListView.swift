//
//  CurrencyListView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import SwiftUI

struct CurrencyListView: View {
    @StateObject private var viewModel = CurrencyViewModel()
    @EnvironmentObject private var userViewModel: AuthViewModel
    @State private var selectedRate: Rate? = nil
    @State private var selectedWatchlist: Watchlist?
    
    var body: some View {
        NavigationStack {
            //header
            HStack {
                //Searchbar
                
            }
            Menu {
                Picker("Select Watchlist", selection: $selectedWatchlist) {
                    if selectedWatchlist?.rates.isEmpty == true {
                        Text("No Currencies in Watchlist")
                            .font(.largeTitle)
                    } else {
                        ForEach(userViewModel.currentUser?.watchlists ?? []) { watchlist in
                            Text(watchlist.name).tag(watchlist as Watchlist?)
                        }
                    }
                }

            } label: {
                Text("My Currencies")
            }

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
            .listStyle(.plain)
            .navigationTitle("Currencies")
            .toolbar(content: {
                MenuView()
            })
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

fileprivate struct MenuView: View {
    var body: some View {
        Menu {
            Button {
                
            } label: {
                HStack {
                    Text("Show Currency")
                    Image(systemName: "polishzlotysign")
                }
            }
            Menu {
                // Picker with sorting tags
                Button {
                    
                } label: {
                    Text("Manual")
                }
                Button {
                    
                } label: {
                    Text("Favorites First")
                }
                Button {
                    
                } label: {
                    Text("Name")
                }
            } label: {
                HStack {
                    Text("Sort Watchlist By")
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
        }
    }
}

#Preview {
    CurrencyListView()
}
