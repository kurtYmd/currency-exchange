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
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var topUpTask: Task<Void, Never>?
        
    
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
                
                Button(action: topUp) {
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
                .opacity(!amount.isEmpty ? 1.0 : 0.5)
                
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
    
    func topUp() {
        guard let topUpAmount = Double(amount) else { return }
        isLoading = true

        topUpTask?.cancel()
        
        topUpTask = Task { @MainActor in
            do {
                try await viewModel.topUp(amount: topUpAmount)
                if !Task.isCancelled {
                    amount = ""
                    isLoading = false
                    dismiss()
                }
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
            topUpTask = nil
        }
    }
}

#Preview {
    TopUpSheetView(amount: .constant(""))
                .environmentObject(AuthViewModel())
}
