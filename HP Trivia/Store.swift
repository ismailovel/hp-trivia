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
    
    private var productsIDs = ["hp4", "hp5", "hp6", "hp7"]
    
    func loadProducts() async {
        do {
            products = try await Product.products(for: productsIDs)
        } catch {
            print("Couldn't fetch those products: \(error)")
        }
    }
}
