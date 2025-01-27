//
//  ProfileView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 15/10/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isPresented: Bool = false
    @State private var signOutIsPressed: Bool = false
    @State private var deleteAccountIsPresented: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert: Bool = false
    
    var body: some View {
        if let user = viewModel.currentUser {
            NavigationStack {
                List {
                    Section {
                        HStack {
                            Text(user.intials)
                                .font(.title)
                                .foregroundStyle(Color(.white))
                                .fontWeight(.semibold)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())
                                .padding(5)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(user.fullname)
                                    .padding(.top, 4)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    Section {
                        Button {
                            signOutIsPressed = true
                            isPresented = true
                        } label : {
                            Text("Sign Out")
                        }
                        .foregroundStyle(Color(.systemRed))
                        
                        Button {
                            deleteAccountIsPresented = true
                            isPresented = true
                        } label: {
                            Text("Delete Account")
                        }
                        .foregroundStyle(Color(.systemRed))
                    }
                }
                .navigationTitle("Account")
                .navigationBarTitleDisplayMode(.inline)
            }
            .alert("Delete Account", isPresented: $showErrorAlert, actions: {
                Button("Sign Out", role: .destructive) {
                    viewModel.signOut()
                }
            }, message: {
                if let subtitle = errorMessage {
                    Text(subtitle)
                }
            })
            .confirmationDialog("Profile Action", isPresented: $isPresented) {
                if signOutIsPressed {
                    Button("Sign Out", role: .destructive) {
                        viewModel.signOut()
                    }
                    Button("Cancel", role: .cancel) {
                        signOutIsPressed = false
                    }
                } else {
                    Button("Delete Account", role: .destructive) {
                        Task {
                            do {
                                try await viewModel.deleteUser()
                            } catch let authError as AuthError {
                                showErrorAlert = true
                                errorMessage = authError.localizedDescription
                            }
                        }
                    }
                }
            } message: {
                if signOutIsPressed {
                    Text("Are you sure you want to sign out?")
                } else {
                    Text("Are you sure you want to delete your account?")
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
