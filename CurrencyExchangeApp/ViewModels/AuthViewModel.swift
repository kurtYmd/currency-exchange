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
        } catch {
            print("Failed to log in with error \(error.localizedDescription)")
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
        } catch {
            print("DEBUG: Failed to create a user with error \(error.localizedDescription)")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            print("Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else { return }
        
        let userId = user.uid
        do {
            try await userDocument(userId: userId).delete()
        } catch {
            print("DEBUG: Failed to delete user document with error: \(error.localizedDescription)")
        }
        
        do {
            try await user.delete()
            await MainActor.run {
                self.userSession = nil
                self.currentUser = nil
            }
            await fetchUser()
        } catch {
            print("DEBUG: Failed to delete user with error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Watchlist
    
    func createWatchlist(name: String) async throws -> Watchlist {
//        guard let uid = getCurrentUserUID() else {
//            throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
//        }

        let watchlist = Watchlist(name: name)
        
        currentUser?.watchlists.append(watchlist)
        
        let watchlistsData = currentUser?.watchlists.map { $0.toDictionary() } ?? []
        try await updateFirestoreUser(field: "watchlists", value: watchlistsData)
        
        return watchlist
    }

    func removeFromWatchlist(watchlist: Watchlist, rate: Rate) async throws {
        if let watchlistIndex = currentUser?.watchlists.firstIndex(where: { $0.name == watchlist.name }) {
            if let rateIndex = currentUser?.watchlists[watchlistIndex].rates.firstIndex(of: rate) {
                currentUser?.watchlists[watchlistIndex].rates.remove(at: rateIndex)
            }
        }
        
        self.currentUser = self.currentUser
        
        let watchlistsData = currentUser?.watchlists.map { $0.toDictionary() } ?? []
        
        try await updateFirestoreUser(field: "watchlists", value: watchlistsData)
    }
    
    func addToWatchlist(watchlist: Watchlist, rate: Rate) async throws {
        if let index = currentUser?.watchlists.firstIndex(where: { $0.name == watchlist.name }) {
            currentUser?.watchlists[index].rates.append(rate)
            
            let watchlistsData = currentUser?.watchlists.map { $0.toDictionary() } ?? []
            
            try await updateFirestoreUser(field: "watchlists", value: watchlistsData)
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
