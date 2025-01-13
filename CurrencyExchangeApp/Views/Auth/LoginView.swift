//
//  LoginView.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 14/10/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isSecured: Bool = false
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusField: FocusedField?
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Currency Exchange")
                    .bold()
                    .frame (width: 300, height: 150)
                
                VStack (spacing: 10) {
                    InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .focused($focusField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit {
                            focusField = .password
                        }
                        .autocapitalization(.none)
                    ZStack(alignment: .trailingLastTextBaseline) {
                        InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: isSecured)
                            .focused($focusField, equals: .password)
                            .submitLabel(.done)
                            .onSubmit {
                                dismiss()
                            }
                            .autocapitalization(.none)
                    }
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .contentTransition(.identity)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    Button {
                        Task {
                            do {
                                try await viewModel.signIn(withEmail: email, password: password)
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
                        Text("SIGN IN")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(.white)) 
                    }
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                    .background(Color(.systemBlue))
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.top, 24)

                }
                .padding(.horizontal)
                
//                if focusField == nil {
//                        Spacer()
//                }
                
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 4) {
                        Text("Dont have an account?")
                        Text("Sign Up")
                            .bold()
                    }
                }
            }
        }
    }
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count >= 8
    }
}

enum FocusedField {
    case email
    case password
}

#Preview {
    LoginView()
}
