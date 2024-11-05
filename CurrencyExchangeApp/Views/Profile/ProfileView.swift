//
//  ProfileView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 15/10/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
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
                        viewModel.signOut()
                    } label : {
                        Text("Sign Out")
                    }
                        .foregroundStyle(Color(.systemRed))
                    
                    Button {
                        Task {
                            try await viewModel.deleteUser()
                        }
                    } label: {
                        Text("Delete Account")
                    }
                    .foregroundStyle(Color(.systemRed))
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
