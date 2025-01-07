//
//  TopUpSheetView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 25/10/2024.
//

import SwiftUI

struct TopUpSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var viewModel: AuthViewModel
    @Binding var amount: String
    @State private var isPresented = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var topUpTask: Task<Void, Never>?
    @FocusState var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
//                Text("You deposit to your wallet")
//                    .font(.title2)
//                    .foregroundStyle(Color(.secondaryLabel))
//                    .padding(.top)
                Image(systemName: "polishzlotysign.bank.building")
                    .foregroundStyle(Color(.secondaryLabel))
                    .font(.system(size: 100))
                
                VStack {
                   TextField("0", text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($isTextFieldFocused)
                        //.textFieldStyle(PlainTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .font(.system(size: 50))
                        .bold()
                        .padding(.horizontal)
                }
                if Int(amount) ?? 0 < 5 {
                    Text("Minimum Amount 5 PLN")
                        .foregroundStyle(Color.secondary)
                        .font(.caption)
                } else {
                    Text("")
                        .foregroundStyle(Color.secondary)
                        .font(.caption)
                }

                Spacer()
                
            }
            .navigationTitle("Deposit to Your Wallet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if amount.isEmpty {
                            dismiss()
                            amount = ""
                        } else {
                            isPresented = true
                        }
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: topUp) {
                        Text("Add")
                    }
                    .disabled((Int(amount) ?? 0) < 5)
                }
            }
        }
        .onAppear() {
            self.isTextFieldFocused = true
        }
//        .presentationDetents([.height(200)])
        .confirmationDialog("Alert", isPresented: $isPresented) {
            Button ("Cancel Top-Up", role: .destructive) {
                amount = ""
                dismiss()
            }
            Button("Continue", role: .cancel) { }
        } message: {
            Text("Are you sure you want to cancel the top-up?")
        }
    }
    
    func topUp() {
        guard let topUpAmount = Double(amount), topUpAmount >= 5 else { return }
        
        isLoading = true
        Task {
            do {
                try await viewModel.topUp(amount: topUpAmount)
                amount = ""
                isLoading = false
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                isLoading = false
            }
        }
    }
}

#Preview {
    TopUpSheetView(amount: .constant(""))
                .environmentObject(AuthViewModel())
}
