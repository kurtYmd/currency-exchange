//
//  CurrencyListView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import SwiftUI

struct CurrencyListView: View {
    @StateObject private var currencyViewModel = CurrencyViewModel()
    @EnvironmentObject private var userViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRate: Rate? = nil
    @State private var selectedWatchlist: Watchlist?
    @State private var isAlertShown: Bool = false
    @State private var watchlistText: String = ""
    
    var body: some View {
        if userViewModel.currentUser != nil {
            NavigationStack {
                List {
                    watchlistMenu
                        .listRowSeparator(.hidden)
                    //MARK: Default Watchlist
                    if ((selectedWatchlist?.rates.isEmpty) != nil) {
                        currentWatchlist
                    } else {
                        ContentUnavailableView("No rates added to watchlist", systemImage: "xmark")
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Currencies")
                .searchable(text: $currencyViewModel.searchText, prompt: "Search Currency") {
                    if !currencyViewModel.searchText.isEmpty {
                        searchCurrencyList
                    }
                }
                .toolbar(content: {
                    toolbarMenu
                })
                .sheet(item: $selectedRate) { rate in
                    ItemSheetView(rate: rate)
                        .presentationDetents([.height(250)])
                }
                .alert("New Watchlist", isPresented: $isAlertShown, actions: {
                    createWatchlistAlert
                }, message: {
                    Text("Enter a name for this watchlist.")
                })
                .onAppear {
                    currencyViewModel.fetchCurrencyRates()
                    if selectedWatchlist == nil {
                        selectedWatchlist = userViewModel.currentUser?.watchlists[0]
                    } else {
                        selectedWatchlist = selectedWatchlist
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    fileprivate var searchCurrencyList: some View {
        if currencyViewModel.filterCurrency.isEmpty {
            watchlistMenu
                .listRowSeparator(.hidden)
            ContentUnavailableView("No results for " + "\"\(currencyViewModel.searchText)\"", systemImage: "xmark")
                .padding(.top, 100)
                .listRowSeparator(.hidden)
        } else {
            watchlistMenu
                .listRowSeparator(.hidden)
            ForEach(currencyViewModel.filterCurrency) { rate in
                HStack {
                    if let currentWatchlist = selectedWatchlist {
                        if currentWatchlist.rates.contains(where: { $0.id == rate.id }) {
                            Image(systemName: "checkmark.circle.fill")
                                .onTapGesture {
                                    // Remove from watchlist
                                }
                        } else {
                            Image(systemName: "plus.circle")
                                .onTapGesture {
                                    Task {
                                        do {
                                            print("\(rate) is added to Firestore")
                                            try await userViewModel.addToWatchlist(watchlist: currentWatchlist, rate: rate)
                                            selectedWatchlist = currentWatchlist
                                            print("Selected watchlist:\(String(describing: selectedWatchlist))")
                                            print("Watchlist to replace with: \(currentWatchlist)")
                                        } catch {
                                            print("Failed to add rate to watchlist: \(error)")
                                        }
                                    }
                                }
                        }
                    }
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
            }
        }
    }
    
    @ViewBuilder
    fileprivate var currentWatchlist: some View {
        if let selectedWatchlist = selectedWatchlist {
            ForEach(selectedWatchlist.rates) { rate in
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
                .onTapGesture {
                    selectedRate = rate
                    print("Selected Rate: \(String(describing: selectedRate))")
                }
                .swipeActions {
                    Button {
                        Task {
                            try await userViewModel.removeFromWatchlist(watchlist: selectedWatchlist, rate: rate)
                        }
                    } label : {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
            }
        }
    }
     
    // MARK: Menu
    
    fileprivate var watchlistMenu: some View {
        Menu {
            ForEach(userViewModel.currentUser?.watchlists ?? []) { watchlist in
                Button {
                    selectedWatchlist = watchlist
                } label: {
                    Text(watchlist.name)
                }
            }
            Divider()
            Button {
                
            } label: {
                HStack {
                    Text("Manage Watchlists")
                    Image(systemName: "slider.horizontal.3")
                }
            }
            Button {
                isAlertShown.toggle()
            } label: {
                HStack {
                    Text("New Watchlist")
                    Image(systemName: "plus")
                }
            }
        } label: {
            // Current Watchlist
            
                HStack {
                    // Watchlist name
                    Text(selectedWatchlist?.name ?? "N/A")
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                }
                .bold()
            
        }
    }
    
    @ViewBuilder
    fileprivate var createWatchlistAlert: some View {
        TextField("New Watchlist", text: $watchlistText)
        Button("Cancel") {
            dismiss()
        }
        Button("Save") {
            Task {
               let newWatchlist = try await userViewModel.createWatchlist(name: watchlistText)
                selectedWatchlist = newWatchlist
                dismiss()
            }
        }
        .disabled(watchlistText.isEmpty)
    }
    
    fileprivate var toolbarMenu: some View {
        Menu {
            Button {
                
            } label: {
                HStack {
                    Text("Show Currency")
                    Image(systemName: "polishzlotysign")
                }
            }
            Divider()
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
            Image(systemName: "ellipsis.circle")
        }
    }
}

