//
//  ItemSheetView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 25/10/2024.
//

import SwiftUI
import Charts

struct ItemSheetView: View {
    let rate: Rate
    @Environment(\.dismiss) private var dismiss
    @StateObject private var currencyViewModel = CurrencyViewModel()
    @State private var isPresented = false
    @State private var transactionType: TransactionType = .buy
    @State private var selectedTimeframe: Timeframe = .week
    @State private var selectedDate: Date?
    
    private var selectedExchangeRate: RateHistory? {
        guard let selectedDate else { return nil }
        return currencyViewModel.rateHistory.first(where: {
            Calendar.current.isDate($0.effectiveDate, inSameDayAs: selectedDate)
        })
    }
    
    private var lineColor: Color {
        if selectedDate != nil {
            return Color.cyan
        } else {
            return currencyViewModel.getLineColor()
        }
    }
    
//    private var gradientColor: Color {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: -5) {
                    Text(rate.code)
                        .font(.largeTitle)
                        .bold()
                    Text(rate.currency.capitalized)
                        .foregroundStyle(Color(.secondaryLabel))
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(.top)
            
            Divider()
            
            VStack(alignment: .leading) {
                VStack {
                    Text(String(format: "%.2f", rate.mid ?? "N/A"))
                        .fontWeight(.bold)
                    Text(selectedTimeframe.description)
                        .animation(.easeInOut)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.secondaryLabel))
                }.padding(.bottom, 5)
                Text("\(rate.currency.capitalized) • \(rate.code)")
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            Divider()
            
            VStack {
                timeframePicker
                chart
                    .frame(height: 250)
            }
            
            HStack(spacing: 15) {
                Button {
                    presentExchangeSheet(for: .buy)
                } label: {
                    Text("Buy")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemGreen))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    presentExchangeSheet(for: .sell)
                } label: {
                    Text("Sell")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemRed))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.top, 10)
        }
        .onAppear() {
            currencyViewModel.fetchCurrencyRatesHistory(code: rate.code, timeframe: selectedTimeframe)
            print(currencyViewModel.rateHistory)
        }
        .padding()
        .sheet(isPresented: $isPresented) {
            ExchangeSheetView(rate: rate, transactionType: transactionType, amount: "")
                .presentationDetents([.height(200)])
        }
    }
    
    
    private func presentExchangeSheet(for type: TransactionType) {
        transactionType = type
        isPresented = true
    }
    
    @ViewBuilder
    private var chart: some View {
        if !currencyViewModel.rateHistory.isEmpty {
            Chart {
                if let selectedExchangeRate {
                    RuleMark(x: .value("Selected Date", selectedExchangeRate.effectiveDate))
                        .foregroundStyle(lineColor.opacity(0.7))
                        .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                            VStack {
                                Text(String(format: "%.4f", selectedExchangeRate.mid))
                                    .bold()
                                Text(selectedExchangeRate.effectiveDate.formatted(date: .abbreviated, time: .omitted))
                            }
                            .font(.caption2)
                            .foregroundStyle(Color.white)
                            .padding()
                            .frame(width: 100)
                            .background(RoundedRectangle(cornerRadius: 10).fill(lineColor.gradient))
                        }
                }
                ForEach(currencyViewModel.rateHistory) {
                    LineMark(
                        x: .value("Date", $0.effectiveDate),
                        y: .value("Rate", $0.mid)
                    )
                    .foregroundStyle(lineColor)
                    AreaMark(
                        x: .value("Date", $0.effectiveDate),
                        yStart: .value("Min", currencyViewModel.rateHistory.map { $0.mid }.min() ?? 0.0),
                        yEnd: .value("Max", $0.mid)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors : [lineColor.opacity(0.4), .clear]),
                            startPoint: .top,
                            endPoint: .bottom)
                    )
                }
            }
            .chartXSelection(value: $selectedDate)
            //.animation(.easeInOut)
            .frame(height: 250)
            .chartYScale(domain: (currencyViewModel.rateHistory.map { $0.mid}.min() ?? 0.0)...(currencyViewModel.rateHistory.map { $0.mid}.max() ?? 0.0))
        } else {
            ProgressView()
                .frame(height: 250)
        }
    }
    
    @ViewBuilder
    private var timeframePicker: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Button {
                        selectedTimeframe = timeframe
                        currencyViewModel.fetchCurrencyRatesHistory(code: rate.code, timeframe: timeframe)
                        //(timeframe.abbreviation, timeframe.dateString)
                    } label: {
                        Text(timeframe.abbreviation)
                            .font(.footnote)
                            .fontWeight(timeframe == selectedTimeframe ? .bold : .semibold)
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .background {
                        if timeframe == selectedTimeframe {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

}
