//
//  WalletView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 21/10/2024.
//

import SwiftUI

struct WalletView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showSheet = false
    @State private var textFieldText = ""
    
    var body: some View {
        if let user = viewModel.currentUser {
            Text("Wallet")
            Text("\(user.balance)")
                .font(.largeTitle)
                .bold()
            VStack {
                Button {
                    showSheet.toggle()
//                    viewModel.topUp()
                } label : {
                    Text("Top Up")
                        .font(.title)
                        .bold()
                }
                .frame(width: 100, height: 50)
            }
            .sheet(isPresented: $showSheet, content: {
                VStack {
                    // Top up functionality
                    TextField("Enter amount", text: $textFieldText)
                        .padding(.top, 24)
                    Button {
                        
                    } label: {
                        HStack {
                            Text("Top Up")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(Color(.white))
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    }
                    .background(Color(.systemBlue))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 24)
                }
                .presentationDetents([.height(200)])
            })
            .padding()
        }
    }
}


#Preview {
    WalletView()
}
