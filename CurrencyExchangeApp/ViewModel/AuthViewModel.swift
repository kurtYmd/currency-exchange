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
    
    func topUp(amount: Double) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        currentUser?.balance["PLN"] = (currentUser?.balance["PLN"] ?? 0.0) + amount
        
        // Save the updated balance to Firestore
        try await userRef.setData(["balance": currentUser?.balance ?? [:]], merge: true)
        print("Balance in PLN updated successfully!")
        
        let transaction = Transaction(currencyFrom: nil, currencyTo: "PLN", amount: amount, type: .topUp, date: Date())
        let transactionData = transaction.toDictionary()
        
        // Add transaction to Firebase
        try await userRef.collection("transactionHistory").addDocument(data: transactionData)
        currentUser?.transactionHistory.append(transaction)
        
        // Convert transactionHistory to an array of dictionaries before saving it to Firestore
        let transactionHistoryData = currentUser?.transactionHistory.map { $0.toDictionary() } ?? []
       
        // Save the updated transaction history to Firestore
        try await userRef.setData(["transactionHistory": transactionHistoryData], merge: true)
    }
    
    func buyCurrency(amount: Double, currencyCode: String, rate: Double) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        guard currentUser?.balance["PLN"] ?? 0 >= amount else { return }
        
        let convertedValue = amount * rate
        currentUser?.balance["PLN"]! -= convertedValue
        currentUser?.balance[currencyCode, default: 0] += amount
        
        try await userRef.setData(["balance": currentUser?.balance ?? [:]], merge: true)
        
        let transaction = Transaction(currencyFrom: "PLN", currencyTo: currencyCode, amount: amount, type: .buy, date: Date())
        let transactionData = transaction.toDictionary()
        
        try await userRef.collection("transactionHistory").addDocument(data: transactionData)
        currentUser?.transactionHistory.append(transaction)
        
        let transactionHistoryData = currentUser?.transactionHistory.map { $0.toDictionary() } ?? []
        try await userRef.setData(["transactionHistory": transactionHistoryData], merge: true)
    }
    
    func sellCurrency(amount: Double, currencyCode: String, rate: Double) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        guard currentUser?.balance[currencyCode] ?? 0 >= amount else { return }
        
        let convertedAmount = amount * rate
        currentUser?.balance[currencyCode]! -= amount
        currentUser?.balance["PLN"]! += convertedAmount
        
        try await userRef.setData(["balance": currentUser?.balance ?? [:]], merge: true)
        
        let transaction = Transaction(currencyFrom: currencyCode, currencyTo: "PLN", amount: amount, type: .sell, date: Date())
        let transactionData = transaction.toDictionary()
        
        try await userRef.collection("transactionHistory").addDocument(data: transactionData)
        currentUser?.transactionHistory.append(transaction)
        
        let transactionHistoryData = currentUser?.transactionHistory.map { $0.toDictionary() } ?? []
        try await userRef.setData(["transactionHistory": transactionHistoryData], merge: true)
    }
    
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
            try await Firestore.firestore().collection("users").document(userId).delete()
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
    
    private func updateFirestoreUser(field: String, value: Any) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        userRef.setData([field: value], merge: true) { error in
                if let error = error {
                    print("Failed to update \(field) with error: \(error.localizedDescription)")
                } else {
                    print("\(field) updated successfully!")
                }
            }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
        print("DEBUG: Current user is \(String(describing: self.currentUser))")
    }
}
