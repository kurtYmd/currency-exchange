//
//  CurrencyExchangeAppApp.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 14/10/2024.
//

import SwiftUI
import Firebase

@main
struct CurrencyExchangeApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var currencyViewModel = CurrencyViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(authViewModel)
                .environmentObject(currencyViewModel)
        }
    }
}
