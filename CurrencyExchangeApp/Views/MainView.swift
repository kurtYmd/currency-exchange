//
//  MainView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 14/10/2024.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                TabView {
                    Tab("Profile", systemImage: "person.circle.fill") {
                        ProfileView()
                    }
                    Tab("Exchange", systemImage: "polishzlotysign.arrow.trianglehead.counterclockwise.rotate.90") {
                        CurrencyListView()
                    }
                    Tab("Wallet", systemImage: "wallet.bifold.fill") {
                        WalletView()
                    }
                }
                .tint(Color(.systemBlue))
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
}
