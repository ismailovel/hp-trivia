//
//  Store.swift
//  HP Trivia
//
//  Created by Ismailov on 6.05.2025.
//

import Foundation
import StoreKit

enum BookStatus {
    case active
    case inactive
    case locked
}

@MainActor
class Store: ObservableObject {
    @Published var books: [BookStatus] = [.active, .active, .inactive, .locked, .locked, .locked, .locked]
    @Published var products: [Product] = []
    @Published var purchasedIDs = Set<String>()
    
    private var productsIDs = ["hp4", "hp5", "hp6", "hp7"]
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = watchForUpdates()
    }
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productsIDs)
            products.sort {
                $0.displayName < $1.displayName
            }
        } catch {
            print("Couldn't fetch those products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
                
            //Purchase successful, but now we have to verify receipt
            case .success(let verificationResult):
                switch verificationResult {
                    
                case .unverified(let signedType, let verificationError):
                    print("Error on \(signedType): \(verificationError)")
                    
                case .verified(let signedType):
                    purchasedIDs.insert(signedType.productID)
                }
                
            // User cancelled or parent disapproved child's purchase request
            case .userCancelled:
                break
                
            // Waiting for approval
            case .pending:
                break
                
            @unknown default:
                break
            }
        } catch {
            print("Couldn't purchase that product: \(error)")
        }
    }
    
    private func checkPurchased() async {
        for product in products {
            guard let state = await product.currentEntitlement else { return }
            
            switch state {
            case .unverified(let signedType, let verificationError):
                print("Error on \(signedType): \(verificationError)")
                
            case .verified(let signedType):
                if signedType.revocationDate == nil {
                    purchasedIDs.insert(signedType.productID)
                } else {
                    purchasedIDs.remove(signedType.productID)
                }
            }
        }
    }
    
    private func watchForUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                await checkPurchased()
            }
        }
    }
}
