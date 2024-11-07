//
//  ProfileView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 15/10/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isPresented: Bool = false
    @State private var signOutIsPressed: Bool = false
    @State private var deleteAccountIsPresented: Bool = false
    
    var body: some View {
        if let user = viewModel.currentUser {
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
                
                Spacer()
                
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
                            try await viewModel.deleteUser()
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        deleteAccountIsPresented = false
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
