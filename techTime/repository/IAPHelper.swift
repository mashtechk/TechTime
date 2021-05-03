//  IAPHelper.swift
//  techtime
//  Created by FTF on 2020/11/14.

import SwiftUI
import Firebase
import StoreKit
import SwiftyStoreKit

class IAPHelper {
    
    let productId = "com.techtimeapp.techtime.sub"
    let sharedKey = "bdf62b8709c34cd4b27bc1f5cf1a6d5b"

     func getStoreKitData() {
        //retrive products info
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            
            }
            else {
                print("Error: \(result.error)")
            }
        }
    }

    //get the purchase product
    func getPurchaseProduct() -> Bool {
        var return_value = true
        // purchase a product (skproduct)
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            print("*****  this is teh product sk getting ****")
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    print("************* this is the purshase product ***********")
                    switch result {
                    case .success(let purchase):
                        print("Purchase Success: \(purchase.productId)")
                    case .error(let error):
                        return_value = false
                        switch error.code {
                        case .unknown: print("Unknown error. Please contact support")
                        case .clientInvalid: print("Not allowed to make the payment")
                        case .paymentCancelled: break
                        case .paymentInvalid: print("The purchase identifier was invalid")
                        case .paymentNotAllowed: print("The device is not allowed to make the payment")
                        case .storeProductNotAvailable: print("The product is not available in the current storefront")
                        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                        default: print((error as NSError).localizedDescription)
                        }
                    }
                }
            }
        }
        return return_value
    }
    
    //get purchasing and verifying a subscrption
    func getVerifying()-> Bool{
        var return_value = false
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.sharedKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            
            if case .success(let receipt) = result {
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: self.productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems):
                    return_value = true
                    print("Product is valid until \(expiryDate)")
                case .expired(let expiryDate, let receiptItems):
                    print("Product is expired since \(expiryDate)")
                case .notPurchased:
                    print("This product has never been purchased")
                }

            } else {
                // receipt verification error
                print("***** this is the receipt verification error *****")
            }
        }
        return return_value
    }
    
    // cancel subscription
    func cancelSubscription() -> Bool {
        UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!)
        return false
    }
}

