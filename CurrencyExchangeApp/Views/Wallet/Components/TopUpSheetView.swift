//
//  TopUpSheetView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 25/10/2024.
//

import SwiftUI

struct TopUpSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var amount: String
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("You deposit to your wallet")
                    .font(.title2)
                    .foregroundStyle(Color(.secondaryLabel))
                    .padding(.top)
                VStack {
                    TextField("0", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(PlainTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                }
                
                Button {
                    if Double(amount) != nil {
                        viewModel.topUp(amount: Double(amount) ?? 0.0)
                        dismiss()
                    }
                } label: {
                    Text("Confirm")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .background(Color(.systemBlue))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .disabled(amount.isEmpty)
                
                Spacer()
            }
            .navigationTitle("Top Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
        }
        .presentationDetents([.height(250)])
    }
}

#Preview {
    TopUpSheetView(amount: .constant("0"))
                .environmentObject(AuthViewModel())
}
