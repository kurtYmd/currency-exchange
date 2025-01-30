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
    @EnvironmentObject private var userViewModel: AuthViewModel
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
    
    private var minMid: Double {
            currencyViewModel.rateHistory.map { $0.mid }.min() ?? 0.0
        }
        
    private var maxMid: Double {
        currencyViewModel.rateHistory.map { $0.mid }.max() ?? 0.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: -5) {
                    Text(rate.currency.capitalized)
                        .font(.title)
                        .bold()
                    Text(String(format: "%.2f \(rate.code)", userViewModel.currentUser?.balance[rate.code] ?? 0.0))
                        .font(.title3)
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
            
            exchangeButton
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    annotation
                }.padding(.bottom, 5)
                Text("\(rate.currency.capitalized) • \(rate.code)")
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            
            VStack {
                chart
                    .frame(height: 250)
                timeframePicker
            }
        }
        .onAppear {
            currencyViewModel.fetchCurrencyRatesHistory(code: rate.code, timeframe: selectedTimeframe)
        }
        .padding()
        .sheet(isPresented: $isPresented) {
            ExchangeSheetView(rate: rate)
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
                indicator
                ForEach(currencyViewModel.rateHistory) {
                    LineMark(
                        x: .value("Date", $0.effectiveDate),
                        y: .value("Rate", $0.mid)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(lineColor)
                    AreaMark(
                        x: .value("Date", $0.effectiveDate),
                        yStart: .value("Min", currencyViewModel.rateHistory.map { $0.mid }.min() ?? 0.0),
                        yEnd: .value("Max", $0.mid)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [lineColor.opacity(0.4), .clear]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .onChange(of: selectedDate) {
                print("DEBUG DATE: \(selectedExchangeRate?.effectiveDate)")
                print("DEBUG RATE: \(selectedExchangeRate?.mid)")
            }
            .frame(height: 250)
            .chartXSelection(value: $selectedDate)
            .chartYScale(domain: (minMid)...(maxMid))
            .chartXAxis(.hidden)
        } else {
            ProgressView()
                .frame(height: 250)
        }
    }
    
    @ChartContentBuilder
    private var indicator: some ChartContent {
        if let selectedExchangeRate {
            RuleMark(x: .value("Selected Date", selectedExchangeRate.effectiveDate))
                .lineStyle(StrokeStyle(lineWidth: 0.5))
                .foregroundStyle(Color.gray.opacity(0.7))
            PointMark(
                x: .value("Selected Date", selectedExchangeRate.effectiveDate),
                y: .value("Selected Rate", selectedExchangeRate.mid)
            )
            .foregroundStyle(lineColor)
            .symbolSize(40)
        }
    }
    
    @ViewBuilder
    private var annotation: some View {
        if let selectedExchangeRate {
            Text(String(format: "%.4f", selectedExchangeRate.mid))
                .fontWeight(.bold)
            Text(selectedExchangeRate.effectiveDate.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.secondaryLabel))
        } else {
            Text(String(format: "%.4f", rate.mid ?? 0.0))
                .fontWeight(.bold)
            Text(selectedTimeframe.description)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.secondaryLabel))
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
    
    @ViewBuilder
    private var exchangeButton: some View {
        HStack(spacing: 15) {
            Button {
                presentExchangeSheet(for: .buy)
            } label: {
                VStack {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .symbolEffect(.wiggle.byLayer, options: .repeat(.periodic(delay: 1.0)))
                        .font(.title2)
                    Text("Exchange")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}
