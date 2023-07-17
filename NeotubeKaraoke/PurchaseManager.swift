//
//  PurchaseManager.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/07/17.
//

import Foundation
import StoreKit

class PurchaseManager: ObservableObject {
    
    let productIds = ["com.NeotubeKaraoke.adRemoval", "adRemoval"]
    @Published var purchasedProductIDs = Set<String>()
    @Published var products: [Product] = []
    private var updates: Task<Void, Never>? = nil
    private var productsLoaded = false
    var hasUnlockedPro: Bool {
        return !self.purchasedProductIDs.isEmpty
    }
    
    init() {
        updates = observeTransactionUpdates()
    }
    
    deinit {
        updates?.cancel()
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
    
    public func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }
    
    public func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            await transaction.finish()
            await self.updatePurchasedProducts()
        case let .success(.unverified(_ , error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            print("jailBreak?", error)
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or approval from Ask to Buy
            break
        case .userCancelled:
            break
        @unknown default:
            break
        }
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate == nil {
                self.purchasedProductIDs.insert(transaction.productID)
            } else {
                self.purchasedProductIDs.remove(transaction.productID)
            }
            
        }
    }
}
