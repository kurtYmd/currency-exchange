//
//  AuthError.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 11/01/2025.
//

import Foundation

enum AuthError: Error {
    case invalidEmail
    case wrongPassword
    case userDisabled
    case operationNotAllowed
    case emailAlreadyInUse
    case userNotFound
    case requiresRecentLogin
    case unknownError

    var localizedDescription: String {
        switch self {
        case .invalidEmail:
            return "The email address is invalid. Please enter a valid email address."
        case .wrongPassword:
            return "The password is incorrect. Please try again."
        case .userDisabled:
            return "This account has been disabled. Contact support for help."
        case .operationNotAllowed:
            return "Sign-in with email and password is not enabled. Please contact support."
        case .emailAlreadyInUse:
            return "An account with this email address already exists."
        case .userNotFound:
            return "User with this email address not found"
        case .requiresRecentLogin:
            return "To delete your must sign in again"
        case .unknownError:
            return "An unknown error occurred. Please try again later."
        }
    }
}
