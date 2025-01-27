//
//  AuthViewModel.swift
//  CurrencyExchangeApp
//
//  Created by Bohdan Dmytruk on 15/10/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        print("DEBUG: AuthViewModel initialized")
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    private let userRef = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userRef.document(userId)
    }
    
    func getCurrentUserUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: User balance functionality
    
    func topUp(amount: Double) async throws {
        guard let uid = getCurrentUserUID() else { return }
        
        currentUser?.balance["PLN"] = (currentUser?.balance["PLN"] ?? 0.0) + amount
        
        // Save the updated balance to Firestore
        try await updateFirestoreUser(field: "balance", value: currentUser?.balance ?? [:])
        
        let transaction = Transaction(currencyFrom: nil, currencyTo: "PLN", amount: amount, type: .topUp, date: Date())
        let transactionData = transaction.toDictionary()
        
        // Add transaction to Firebase
        try await userDocument(userId: uid).collection("transactionHistory").addDocument(data: transactionData)
        currentUser?.transactionHistory.append(transaction)
        
        // Convert transactionHistory to an array of dictionaries before saving it to Firestore
        let transactionHistoryData = currentUser?.transactionHistory.map { $0.toDictionary() } ?? []
       
        // Save the updated transaction history to Firestore
        try await updateFirestoreUser(field: "transactionHistory", value: transactionHistoryData)
    }
    
    func buyCurrency(amount: Double, currencyCode: String, rate: Double) async throws {
        guard let uid = getCurrentUserUID() else { return }
        
        guard currentUser?.balance["PLN"] ?? 0 >= amount else { return }
        
        let convertedValue = amount * rate
        currentUser?.balance["PLN"]! -= convertedValue
        currentUser?.balance[currencyCode, default: 0] += amount
        
        try await userDocument(userId: uid).setData(["balance": currentUser?.balance ?? [:]], merge: true)
        
        let transaction = Transaction(currencyFrom: "PLN", currencyTo: currencyCode, amount: amount, type: .buy, date: Date())
        let transactionData = transaction.toDictionary()
        
        try await userDocument(userId: uid).collection("transactionHistory").addDocument(data: transactionData)
        currentUser?.transactionHistory.append(transaction)
        
        let transactionHistoryData = currentUser?.transactionHistory.map { $0.toDictionary() } ?? []
        try await updateFirestoreUser(field: "transactionHistory", value: transactionHistoryData)
    }
    
    func sellCurrency(amount: Double, currencyCode: String, rate: Double) async throws {
        guard let uid = getCurrentUserUID() else { return }
        
        guard currentUser?.balance[currencyCode] ?? 0 >= amount else { return }
        
        let convertedAmount = amount * rate
        currentUser?.balance[currencyCode]! -= amount
        currentUser?.balance["PLN"]! += convertedAmount
        
        try await userDocument(userId: uid).setData(["balance": currentUser?.balance ?? [:]], merge: true)
        
        let transaction = Transaction(currencyFrom: currencyCode, currencyTo: "PLN", amount: amount, type: .sell, date: Date())
        let transactionData = transaction.toDictionary()
        
        try await userDocument(userId: uid).collection("transactionHistory").addDocument(data: transactionData)
        currentUser?.transactionHistory.append(transaction)
        
        let transactionHistoryData = currentUser?.transactionHistory.map { $0.toDictionary() } ?? []
        try await updateFirestoreUser(field: "transactionHistory", value: transactionHistoryData)
    }
    
    //MARK: User Auth
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await MainActor.run {
                self.userSession = result.user
            }
            await fetchUser()
        } catch let error as NSError {
            print("Error code: \(error.code)")
            if let authError = AuthErrorCode(rawValue: error.code) {
                switch authError {
                case .invalidEmail:
                    throw AuthError.invalidEmail
                case .wrongPassword:
                    throw AuthError.wrongPassword
                case .userDisabled:
                    throw AuthError.userDisabled
                case .operationNotAllowed:
                    throw AuthError.operationNotAllowed
                case .userNotFound:
                    throw AuthError.userNotFound
                default:
                    throw AuthError.unknownError
                }
            } else {
                throw AuthError.unknownError
            }
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            await MainActor.run {
                self.userSession = result.user
            }
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch let error as NSError {
            print(error.code)
            if let authError = AuthErrorCode(rawValue: error.code) {
                switch authError {
                case .emailAlreadyInUse:
                    throw AuthError.emailAlreadyInUse
                default:
                    throw AuthError.unknownError
                }
            } else {
                throw AuthError.unknownError
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch let error as NSError {
            print(error.code)
        }
    }
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else { return }

        do {
            try await user.delete()
            await MainActor.run {
                self.userSession = nil
                self.currentUser = nil
            }
            await fetchUser()
        } catch let error as NSError {
            print("Deletion Error Code: \(error.code)")
            if let authError = AuthErrorCode(rawValue: error.code) {
                switch authError {
                case .requiresRecentLogin:
                    throw AuthError.requiresRecentLogin
                default:
                    throw AuthError.unknownError
                }
            } else {
                throw AuthError.unknownError
            }
        }
    }
    
    // MARK: Watchlist
    
    func createWatchlist(name: String) async throws -> Watchlist {
        let watchlist = Watchlist(name: name)
        
        currentUser?.watchlists.append(watchlist)
        
        let watchlistsData = currentUser?.watchlists.map { $0.toDictionary() } ?? []
        try await updateFirestoreUser(field: "watchlists", value: watchlistsData)
        
        return watchlist
    }
    
    func deleteWatchlist(_ watchlist: Watchlist) async throws {
        guard let index = currentUser?.watchlists.firstIndex(where: { $0.name == watchlist.name }) else {
            print("Watchlist '\(watchlist.name)' not found.")
            return
        }
           
        currentUser?.watchlists.remove(at: index)
           
        let watchlistsData = currentUser?.watchlists.map { $0.toDictionary() } ?? []
        try await updateFirestoreUser(
            field: "watchlists",
            value: watchlistsData
        )
           
        print("Watchlist '\(watchlist.name)' deleted successfully.")
    }
    
    func editWatchlist(watchlist: Watchlist, newName: String) async throws -> Watchlist? {
        guard let index = currentUser?.watchlists.firstIndex(where: { $0.name == watchlist.name }) else {
            print("Watchlist '\(watchlist.name)' not found.")
            return nil
        }
        
        currentUser?.watchlists[index].name = newName
        
        let watchlistsData = currentUser?.watchlists.map { $0.toDictionary() } ?? []
        try await updateFirestoreUser(field: "watchlists", value: watchlistsData)
        
        print("Watchlist renamed to '\(newName)' successfully.")
        
        return currentUser?.watchlists[index]
    }
    
    func addToWatchlist(watchlist: Watchlist, rate: Rate) async throws {
        if let index = currentUser?.watchlists.firstIndex(where: { $0.name == watchlist.name }) {
            currentUser?.watchlists[index].rates.append(rate)
            
            let watchlistsData = currentUser?.watchlists.map { $0.toDictionary() } ?? []
            
            try await updateFirestoreUser(field: "watchlists", value: watchlistsData)
            
            // Reassign to trigger @Published
            if var updatedUser = currentUser {
                updatedUser.watchlists = currentUser?.watchlists ?? []
                self.currentUser = updatedUser
            }
        }
    }

    func removeFromWatchlist(watchlist: Watchlist, rate: Rate) async throws {
        if let watchlistIndex = currentUser?.watchlists.firstIndex(where: { $0.name == watchlist.name }) {
            if let rateIndex = currentUser?.watchlists[watchlistIndex].rates.firstIndex(of: rate) {
                currentUser?.watchlists[watchlistIndex].rates.remove(at: rateIndex)
            }
        }
        
        let watchlistsData = currentUser?.watchlists.map { $0.toDictionary() } ?? []
        
        try await updateFirestoreUser(field: "watchlists", value: watchlistsData)
        
        // Reassign to trigger @Published
        if var updatedUser = currentUser {
            updatedUser.watchlists = currentUser?.watchlists ?? []
            self.currentUser = updatedUser
        }
    }
    
    // MARK: Firebase configuration
    
    private func updateFirestoreUser(field: String, value: Any) async throws {
        guard let uid = getCurrentUserUID() else { return }
        
        do {
            try await userDocument(userId: uid).setData([field: value], merge: true)
            print("\(field) updated successfully!")
        } catch {
            print("Failed to update \(field) with error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchUser() async {
        guard let uid = getCurrentUserUID() else { return }
        guard let snapshot = try? await userDocument(userId: uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("DEBUG: Current user is \(String(describing: self.currentUser))")
    }
}
