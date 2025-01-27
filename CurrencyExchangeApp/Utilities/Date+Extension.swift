//
//  Date+Extension.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 27/01/2025.
//

import Foundation

extension Date {
    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(self)
    }
}

extension Date {
    var displayFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d 'at' h:mm"
        return formatter.string(from: self)
    }
}
