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
    case twoWeeks
    case month
    case quarter
    case halfYear
    case nineMonths
    case yearToDate
    case year
    
    var id: String { abbreviation }
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let calendar = Calendar.current
        
        switch self {
        case .day:
            return dateFormatter.string(from: calendar.date(byAdding: .day, value: -2, to: Date())!)
        case .week:
            return dateFormatter.string(from: calendar.date(byAdding: .day, value: -7, to: Date())!)
        case .twoWeeks:
            return dateFormatter.string(from: calendar.date(byAdding: .day, value: -14, to: Date())!)
        case .month:
            return dateFormatter.string(from: calendar.date(byAdding: .day, value: -30, to: Date())!)
        case .quarter:
            return dateFormatter.string(from: calendar.date(byAdding: .month, value: -3, to: Date())!)
        case .halfYear:
            return dateFormatter.string(from: calendar.date(byAdding: .month, value: -6, to: Date())!)
        case .nineMonths:
            return dateFormatter.string(from: calendar.date(byAdding: .month, value: -9, to: Date())!)
        case .yearToDate:
            return dateFormatter.string(from: calendar.date(from: calendar.dateComponents([.year], from: Date()))!)
        case .year:
            return dateFormatter.string(from: calendar.date(byAdding: .year, value: -1, to: Date())!)
        }
    }
    
    var abbreviation: String {
        switch self {
        case .day: return "1D"
        case .week: return "1W"
        case .twoWeeks: return "2W"
        case .month: return "1M"
        case .quarter: return "3M"
        case .halfYear: return "6M"
        case .nineMonths: return "9M"
        case .yearToDate: return "YTD"
        case .year: return "1Y"
        }
    }
    
    var description: String {
        switch self {
        case .day: return "At Close"
        case .week: return "Past Week"
        case .twoWeeks: return "Past 2 Weeks"
        case .month: return "Past Montrh"
        case .quarter: return "Past 3 Montrh"
        case .halfYear: return "Past 6 Months"
        case .nineMonths: return "Past 9 Months"
        case .yearToDate: return "Year To Date"
        case .year: return "Past Year"
        }
    }
}
