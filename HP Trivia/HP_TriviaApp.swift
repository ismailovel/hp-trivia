//
//  HP_TriviaApp.swift
//  HP Trivia
//
//  Created by Elchin Ismailov on 25.04.2025.
//

import SwiftUI

@main
struct HP_TriviaApp: App {
    @StateObject private var store = Store()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .task {
                    await store.loadProducts()
                }
        }
    }
}
