//
//  MakeRefund.swift
//  NeotubeKaraoke
//
//  Created by 안병욱 on 2023/07/27.
//

import SwiftUI
import StoreKit

struct MakeRefund: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var recentTransactions: [StoreKit.Transaction] = []
    @State private var selectedTransactionID: UInt64?
    @State private var refundSheetIsPresented = false
    @State var products: [Product] = []
    
    private let refund: LocalizedStringKey = "Request a refund"
    private let selProduct: LocalizedStringKey = "Select a purchase to refund"
    
    var body: some View {
        VStack{
            Text("😥...")
                .font(.largeTitle)
                .bold()
                .padding()
            List(recentTransactions, selection: $selectedTransactionID) { transaction in
                TransactionRowView(transaction: transaction, products: self.products)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Text(self.selProduct)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                    Button {
                        refundSheetIsPresented = true
                    } label: {
                        Text(self.refund)
                            .bold()
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding([.horizontal, .bottom])
                    .disabled(selectedTransactionID == nil)
                }
            }
            .task { @MainActor in
                for await transaction in StoreKit.Transaction.all {
                    // Ignore the already refunded transactions.
                    if transaction.unsafePayloadValue.revocationDate != nil {
                        continue
                    }
                    recentTransactions.append(transaction.unsafePayloadValue)
                    if recentTransactions.count >= 10 {
                        break
                    }
                }
            }
            .refundRequestSheet(
                for: selectedTransactionID ?? 0,
                isPresented: $refundSheetIsPresented
            ) { result in
                if case .success(.success) = result {
                    dismiss()
                }
            }
        }
    }
}

struct TransactionRowView: View {
    let transaction: StoreKit.Transaction
    @State var products: [Product] = []
    var title = ""
    
    private let subtitle: LocalizedStringKey = "Purchased "
    
    init(transaction: StoreKit.Transaction, title: String = "", products: [Product] = []) {
        self.transaction = transaction
        for product in products {
            if transaction.productID == product.id {
                self.title = product.displayName
            }
        }
        if self.title.isEmpty {
            self.title = transaction.productID
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .bold()
            HStack{
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(transaction.purchaseDate.formatted(date: .long, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
}
