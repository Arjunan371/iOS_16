//
//  InAppPurchase.swift
//  iOS_16
//
//  Created by Arjunan on 02/09/25.
//

import SwiftUI
import StoreKit

struct InAppPurchaseView: View {
    @StateObject private var store = StoreManager()
    @StateObject private var subscription = SubscriptionManager()
    
    var body: some View {
        NavigationStack {
            List {
                VStack(spacing: 30) {
                    
                    // MARK: - Subscriptions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Your Plan")
                            .font(.title2).bold()
                        
                        ForEach(subscription.products, id: \.id) { product in
                            Button {
                                Task { await subscription.purchase(product) }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(product.displayName)
                                            .font(.headline)
                                        Text(product.displayPrice)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        if subscription.isSubscribed {
                            Text("✅ You are subscribed!")
                                .foregroundColor(.green)
                        } else {
                            Text("❌ Not subscribed")
                                .foregroundColor(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    
                    // MARK: - One-time Purchases
                    VStack(alignment: .leading, spacing: 16) {
                        Text("One-Time Purchases")
                            .font(.title2).bold()
                        
                        ForEach(store.products) { product in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(product.displayName)
                                    Text(product.displayPrice)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Button("Buy") {
                                    Task { await store.purchase(product) }
                                }
                            }
                        }
                        
                        Button("Restore Purchases") {
                            Task { await store.restorePurchases() }
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .list
                .padding(.vertical, 10)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .listRowBackground(Color.clear)
            .navigationTitle("Store")
            .task {
                await store.fetchProducts()
                await subscription.fetchProducts()
                await subscription.checkSubscriptionStatus()
            }
        }
    }
}

#Preview {
    InAppPurchaseView()
}

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedIDs: Set<String> = []

    func fetchProducts() async {
        do {
            // Replace with your product IDs
            let ids = ["com.yourapp.premium", "com.yourapp.coins100"]
            products = try await Product.products(for: ids)
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    purchasedIDs.insert(transaction.productID)
                    await transaction.finish()
                }
            case .userCancelled, .pending:
                break
            default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedIDs.insert(transaction.productID)
            }
        }
    }
}

@MainActor
class SubscriptionManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isSubscribed = false
    
    // Your product IDs from App Store Connect
    private let productIDs = [
        "com.yourapp.monthly",
        "com.yourapp.yearly"
    ]
    
    init() {
        Task {
            await fetchProducts()
            await checkSubscriptionStatus()
        }
    }
    
    /// Fetch products from App Store Connect
    func fetchProducts() async {
        do {
            products = try await Product.products(for: productIDs)
            print("✅ Products fetched: \(products.map { $0.displayName })")
        } catch {
            print("❌ Failed to fetch products: \(error)")
        }
    }
    
    /// Purchase a subscription
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    print("✅ Subscribed to \(transaction.productID)")
                    await transaction.finish()
                    await checkSubscriptionStatus()
                }
            case .userCancelled:
                print("❌ User cancelled")
            default:
                break
            }
        } catch {
            print("❌ Purchase failed: \(error)")
        }
    }
    
    /// Check current subscription status
    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .autoRenewable {
                    isSubscribed = true
                    print("✅ Active subscription: \(transaction.productID)")
                    return
                }
            }
        }
        isSubscribed = false
    }
}
