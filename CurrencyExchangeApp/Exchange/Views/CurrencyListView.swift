//
//  CurrencyListView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import SwiftUI
import Charts

struct CurrencyListView: View {
    @StateObject private var currencyViewModel = CurrencyViewModel()
    @EnvironmentObject private var userViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRate: Rate? = nil
    @State private var isAlertShown: Bool = false
    @State private var watchlistText: String = ""
    @State private var isManageWatchlistShown: Bool = false
    
    // Bind to userViewModel's watchlists
    @State private var selectedWatchlistID: String?

    var selectedWatchlist: Watchlist? {
        userViewModel.currentUser?.watchlists.first { $0.id == selectedWatchlistID }
    }

    var body: some View {
        if userViewModel.currentUser != nil {
            NavigationStack {
                List {
                    watchlistMenu
                        .listRowSeparator(.hidden)
                    if let watchlist = selectedWatchlist, !watchlist.rates.isEmpty {
                        currentWatchlist
                    } else {
                        VStack {
                            Spacer()
                            ContentUnavailableView(
                                "No Currencies",
                                systemImage: "dollarsign",
                                description: Text("Add a currency to your watchlist to see exchange rate.")
                            )
                                .multilineTextAlignment(.center)
                                .padding(.top, 100)
                        }
                        .frame(maxHeight: .infinity)
                        .listRowSeparator(.hidden)
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
                .refreshable {
                    currencyViewModel.fetchCurrencyRates()
                }
                .sheet(item: $selectedRate) { rate in
                    ItemSheetView(rate: rate)
                        .presentationDetents([.height(550)])
                }
                .alert("New Watchlist", isPresented: $isAlertShown, actions: {
                    createWatchlistAlert
                }, message: {
                    Text("Enter a name for this watchlist.")
                })
                .onAppear {
                    currencyViewModel.fetchCurrencyRates()
                    if selectedWatchlistID == nil, let firstWatchlist = userViewModel.currentUser?.watchlists.first {
                        selectedWatchlistID = firstWatchlist.id
                    }
                }
                .onChange(of: userViewModel.currentUser?.watchlists) {
                    // Ensure selectedWatchlistID is valid
                    if let watchlists = userViewModel.currentUser?.watchlists, !watchlists.contains(where: { $0.id == selectedWatchlistID }) {
                        selectedWatchlistID = watchlists.first?.id
                    }
                }
            } 
        } else {
            // Handle not logged in state
            ContentUnavailableView("Please log in to view your watchlists.", systemImage: "person.crop.circle.badge.xmark")
        }
    }
    
    @ViewBuilder
    fileprivate var searchCurrencyList: some View {
        if currencyViewModel.filterCurrency.isEmpty {
            watchlistMenu
                .listRowSeparator(.hidden)
            ContentUnavailableView("Not Found", systemImage: "exclamationmark.magnifyingglass", description: Text("No results for " + "\"\(currencyViewModel.searchText)\""))
            
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
                                    // Remove
                                }
                        } else {
                            Image(systemName: "plus.circle")
                                .onTapGesture {
                                    Task {
                                        do {
                                            try await userViewModel.addToWatchlist(watchlist: currentWatchlist, rate: rate)
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
                        Text(String(format: "%.4f", rate.mid ?? "N/A") + "zł")
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
                    miniChart
                    VStack {
                        if let currentRate = currencyViewModel.rates.first(where: { $0.code == rate.code }) {
                            Text(String(format: "%.4f", currentRate.mid ?? "N/A") + "zł")
                                .foregroundStyle(Color.primary)
                                .font(.headline)
                        } else {
                            Text("N/A")
                                .foregroundStyle(Color.secondary)
                                .font(.headline)
                        }
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
                    selectedWatchlistID = watchlist.id
                } label: {
                    Text(watchlist.name)
                }
            }
            Divider()
            Button {
                isManageWatchlistShown.toggle()
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
    fileprivate var miniChart: some View {
        Chart {
            ForEach(currencyViewModel.rateHistory) {
                LineMark(
                    x: .value("Date", $0.effectiveDate),
                    y: .value("Rate", $0.mid)
                )
                .interpolationMethod(.cardinal)
                .foregroundStyle(currencyViewModel.getLineColor())
                AreaMark(
                    x: .value("Date", $0.effectiveDate),
                    yStart: .value("Min", currencyViewModel.rateHistory.map { $0.mid }.min() ?? 0.0),
                    yEnd: .value("Max", $0.mid)
                )
                .interpolationMethod(.cardinal)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [currencyViewModel.getLineColor().opacity(0.4), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .frame(width: 50,height: 20)
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
                selectedWatchlistID = newWatchlist.id
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

