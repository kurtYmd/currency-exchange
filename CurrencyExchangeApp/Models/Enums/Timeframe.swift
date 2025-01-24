//
//  Timeframe.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 23/01/2025.
//

import Foundation

enum Timeframe: CaseIterable, Identifiable {
    case day
    case week
    case month
    case quarter
    case halfYear
    case yearToDate
    case year
    case twoYears
    case fiveYears
    case tenYears
    case allTime
    
    var id: String { abbreviation }
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        
        switch self {
        case .day:
            return dateFormatter.string(from: calendar.date(byAdding: .day, value: -1, to: Date())!)
        case .week:
            return dateFormatter.string(from: calendar.date(byAdding: .day, value: -7, to: Date())!)
        case .month:
            return dateFormatter.string(from: calendar.date(byAdding: .month, value: -1, to: Date())!)
        case .quarter:
            return dateFormatter.string(from: calendar.date(byAdding: .month, value: -3, to: Date())!)
        case .halfYear:
            return dateFormatter.string(from: calendar.date(byAdding: .month, value: -6, to: Date())!)
        case .yearToDate:
            return dateFormatter.string(from: calendar.date(from: calendar.dateComponents([.year], from: Date()))!)
        case .year:
            return dateFormatter.string(from: calendar.date(byAdding: .year, value: -1, to: Date())!)
        case .twoYears:
            return dateFormatter.string(from: calendar.date(byAdding: .year, value: -2, to: Date())!)
        case .fiveYears:
            return dateFormatter.string(from: calendar.date(byAdding: .year, value: -5, to: Date())!)
        case .tenYears:
            return dateFormatter.string(from: calendar.date(byAdding: .year, value: -10, to: Date())!)
        case .allTime:
            return "2002-02-01"
        }
    }
    
    var abbreviation: String {
        switch self {
        case .day: return "1D"
        case .week: return "1W"
        case .month: return "1M"
        case .quarter: return "3M"
        case .halfYear: return "6M"
        case .yearToDate: return "YTD"
        case .year: return "1Y"
        case .twoYears: return "2Y"
        case .fiveYears: return "5Y"
        case .tenYears: return "10Y"
        case .allTime: return "ALL"
        }
    }
    
    var description: String {
        switch self {
        case .day: return "At Close"
        case .week: return "Past Week"
        case .month: return "Past Montrh"
        case .quarter: return "Past 3 Montrh"
        case .halfYear: return "Past 6 Months"
        case .yearToDate: return "Year To Date"
        case .year: return "Past Year"
        case .twoYears: return "Past 2 Years"
        case .fiveYears: return "Past 5 Years"
        case .tenYears: return "Past 10 Years"
        case .allTime: return "All Time"
        }
    }
}
