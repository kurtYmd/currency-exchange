//
//  RegistrationView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 14/10/2024.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var fullName: String = ""
    @State private var errorMessage: String?
    @State private var confirmPassword: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Currency Exchange")
                    .bold()
                    .frame (width: 300, height: 150)
                VStack (spacing: 10) {
                    InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .autocapitalization(.none)
                    
                    InputView(text: $fullName, title: "Full Name", placeholder: "Enter your name")
                    
                    InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                        .autocapitalization(.none)
                    
                    InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm your password", isSecureField: true)
                        .autocapitalization(.none)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .contentTransition(.identity)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    Button {
                        Task {
                            do {
                                try await viewModel.createUser(withEmail: email, password: password, fullname: fullName)
                                withAnimation {
                                    errorMessage = nil
                                }
                            } catch let authError as AuthError {
                                errorMessage = nil
                                withAnimation(.bouncy) {
                                    errorMessage = authError.localizedDescription
                                }
                            } catch {
                                errorMessage = "An unexpected error occurred."
                            }
                        }
                    } label: {
                        HStack {
                            Text("SIGN UP")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(Color(.white))
                        .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    }
                    .background(Color(.systemBlue))
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 24)

                }
                .padding(.horizontal)
                
                Spacer()
                
                NavigationLink {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                        Text("Sign In")
                            .bold()
                    }
                }
            }
        }
    }
}

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count >= 8
        && confirmPassword == password
        && !fullName.isEmpty
    }
}


#Preview {
    RegistrationView()
}
