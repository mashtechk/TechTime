//  MainPage.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/4.

import SwiftUI
import Firebase
import SwiftyStoreKit
import StoreKit

struct MainPage : View {
    
    @State var index = 1
    @State var offset : CGFloat = 0
    var width = UIScreen.main.bounds.width
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    
    let productId = "com.techtimeapp.techtime.full"
    let sharedKey = "bdf62b8709c34cd4b27bc1f5cf1a6d5b"
    
    let helper = Helper()
    let iaphelper = IAPHelper()
    
    @State private var is_unscribe = false
    
    func getData() {
        do {
            let UUID = UIDevice.current.identifierForVendor?.uuidString
            let db = Firestore.firestore()
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "MMM dd, yyyy"
            if data.currentUser.email != "" {
                db.collection("users")
                    .document(data.currentUser.email)
                    .getDocument{(document, error) in
                        
                        if (error != nil) {
                            data.isInternet = false
                            helper.setVariable(data: data)
                        } else {
                            data.isInternet = true
                        }
                        if let document = document, document.exists {
                            let dataDescription = document.data()
                            let start_date = dataDescription!["start_date"] as? String ?? ""
                            let dd = formatter1.date(from: start_date)!
                            
                            data.isTrial = helper.is5minsOver(fromDate: dd)
                            helper.setVariable(data: data)
                            if !data.isTrial {
                                checkPayment()
                            }
                        } else {
                            let uid = data.currentUser.user_id
                            let data: [String : Any] = [
                                "user_id": uid,
                                "device_id": UUID!,
                                "status": true,
                                "is_full": false,
                                "start_date": formatter1.string(from: Date())

                            ]
                            db.collection("users").document(self.data.currentUser.email).setData(data)
                        }
                    }
            }
        }
    }
    
    func checkPayment() {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            if case .success(let receipt) = result {
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems):
                    data.isFull = true
                    print("Product is valid until \(expiryDate)")
                case .expired(let expiryDate, let receiptItems):
                    data.isFull = false
                    print("Product is expired since \(expiryDate)")
                case .notPurchased:
                    data.isFull = false
                    print("This product has never been purchased")
                }
            } else {
                //receipt verification error
                print("*****&&&&& this is the receipt verification error *****")
                data.isFull = false
            }
            helper.setVariable(data: data)
            
        }
    }

    var body: some View {
        
        VStack(spacing: 0) {
            AppBar(index: self.$index, offset: self.$offset, pageIndex: $pageIndex, data: $data)

            GeometryReader{g in
                
                HStack(spacing: 0){
                    PayContent(data: $data, pageIndex: $pageIndex)
                        .frame(width: g.frame(in : .global).width)
                    
                    ArchiveContent(data: $data, pageIndex: $pageIndex)
                        .frame(width: g.frame(in : .global).width)
                }
                .offset(x: self.offset)
                .highPriorityGesture(DragGesture()
                .onEnded({ (value) in
                    if value.translation.width > 50 {// minimum drag...
                        print("right")
                        self.changeView(left: false)
                    }
                    if -value.translation.width > 50 {
                        print("left")
                        self.changeView(left: true)
                     }
                }))
            }
        }
        .animation(.default)
        .edgesIgnoringSafeArea(.all)
    }
    
    func changeView(left : Bool){
        
        print("index is \(index)")
        if left {
            //when it is not 3 works fine
            if self.index != 3{
                self.index += 1
            }
            data.selected = 1
            
        }  else {
            
            
            if self.index == 2 {
                self.offset = 0
                
            } else {
                self.index -= 1
            }
            data.selected = 0
            
        }
        
        if self.index == 1{
            self.offset = self.width
        }
        else
        
        if self.index == 2 {
            if left != true {
                self.offset = 0
            } else {
                self.offset = -self.width
            }
        }
        else{
            
            self.offset = -self.width
        }
        //change the width based on the size of the tabs...
    }
    
    func getPurchaseProduct(){
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    switch result {
                    case .success(let purchase):
                        print("Purchase Success: \(purchase.productId)")
                        data.isFull = true
                    case .error(let error):
                        data.isFull = false
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
                if data.isFull && data.isEnd {
                    data.currentPeriod = PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: [])
                }
                helper.setVariable(data: data)
                
            }
        }
    }
   
    struct AppBar : View {
        @Binding var index : Int
        @Binding var offset : CGFloat
        var width = UIScreen.main.bounds.width
        @Binding var pageIndex: Int
        @Binding var data: VariableModel
        @State private var is_unscribe = false
        let helper = Helper()
        let iaphelper = IAPHelper()
        
        var body: some View {
            
            VStack(alignment: .leading, content: {
                HStack {
                    Image("techtimeName").resizable().frame(width: UIScreen.main.bounds.width*0.4, height:35).aspectRatio(contentMode: .fit)
                    Spacer()

                    Button(action: {
                        pageIndex = 2 //go to the search page
                        
                    }){
                        Image("search").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                        }.padding(.top, 5)
                    
                    if data.selected == 0 {
                        if (data.isEnd || data.currentPeriod.start_date == "") {
                            Menu {
                                Button(action: {
                                    pageIndex = 1
                                }){
                                    Text("Labor Rates")
                                        .font(.system(size: 10))
                                }
                                
                                Text("Edit Pay Period Dates").font(.system(size: 10))
                                
                                Text("Order By").font(.system(size: 10))
                                
                                Text("Email Payroll")
                                
                                Text("End Pay Period").font(.system(size: 10))
                                
                                !data.isTrial && data.isFull ?
                                    Button(action: {
                                        is_unscribe = true
                                        data.is_alert = true
                                    }){
                                        Text("Unsubscribe")
                                            .font(.system(size: 10))
                                    }
                                :
                                    nil
                                
                                Button(action: {
                                    pageIndex = 14
                                    
                                    self.data.isSigned = false
                                    helper.setVariable(data: self.data)
                                }){
                                    Text("Log out")
                                        .font(.system(size: 10))
                                }
                            } label: {
                                Button(action: {}){
                                    Image("more")
                                        .renderingMode(.template)
                                        .resizable().frame(width: 25, height: 25)
                                        .aspectRatio(contentMode: .fit).foregroundColor(.white)
                                    }
                                .padding(.top, 5)
                                }
                        } else {
                            Menu {
                                Button(action: {
                                    pageIndex = 1
                                }){
                                    Text("Labor Rates")
                                        .font(.system(size: 10))
                                }
                                
                                Button(action: {
                                    pageIndex = 3
                                }){
                                    Text("Edit Pay Period Dates").font(.system(size: 10))
                                }
                                Button(action: {
                                    pageIndex = 4
                                }){
                                    Text("Order By").font(.system(size: 10))
                                }
                                
                                if self.data.currentPeriod.order_list.count == 0 {
                                    Text("Email Payroll")
                                } else {
                                    Button(action: {
                                        self.pageIndex = 5
                                    }){
                                        Text("Email Payroll")
                                    }.font(.system(size: 10)).foregroundColor(.gray)
                                }
                                
                                Button(action: {
                                    is_unscribe = false
                                    data.is_alert = true
                                }){
                                    Text("End Pay Period").font(.system(size: 10))
                                }
                                
                                !data.isTrial && data.isFull ?
                                    Button(action: {
                                        is_unscribe = true
                                        data.is_alert = false
                                    }){
                                        Text("Unsubscribe")
                                            .font(.system(size: 10))
                                    }
                                :
                                    nil
                                
                                Button(action: {
                                    pageIndex = 14
                                    
                                    self.data.isSigned = false
                                    helper.setVariable(data: self.data)
                                }){
                                    Text("Log out")
                                        .font(.system(size: 10))
                                }
                            } label: {
                                Button(action: {}){
                                    Image("more")
                                        .renderingMode(.template)
                                        .resizable().frame(width: 25, height: 25)
                                        .aspectRatio(contentMode: .fit).foregroundColor(.white)
                                    }
                                .padding(.top, 5)
                                }
                        }
                    }
                }.padding(EdgeInsets(top: 15, leading: 20, bottom: 5, trailing: 20))
                .alert(isPresented: self.$data.is_alert) {
                    is_unscribe ?
                                Alert(
                                    title: Text(""),
                                    message: Text("Are you sure you want to unsubscribe?"),
                                    primaryButton: .destructive(Text("Unsubscribe")) {
                                        data.isFull = iaphelper.cancelSubscription()
                                        helper.setVariable(data: data)
                                    },
                                    secondaryButton: .cancel()
                                )
                    : Alert(
                        title: Text("END PAY PERIOD").foregroundColor(Color("colorPrimary")),
                        message: Text("Pay period will end automatically, or choose to end now"),
                        primaryButton: .destructive(Text("End Now")) {
                            data.isEnd = true
                            data.currentPeriod.cancel_date = helper.getDate(st: Date())
                            data.histories.append(data.currentPeriod)
                            data.currentPeriod = PeriodModel(start_date: "", end_date: "", cancel_date : "" ,  order_list: [])
                            pageIndex = 11
                            helper.setVariable(data: data)
                        },
                        secondaryButton: .cancel()
                    )
                }
                Divider().frame(height: 2).background(Color("colorPrimaryDark"))

                HStack {
                    Button(action: {
                        self.index = 2
                        self.offset = 0
                        data.selected = 0
                        
                    }) {
                        VStack(spacing: 8){
                            HStack(spacing: 12){
                                Text("PAY PERIOD").font(.system(size: 14)).fontWeight(.semibold).foregroundColor(self.offset == 0 ? .white : Color("colorLetter1"))
                            }
                            Capsule()
                                .fill(self.offset == 0 ? Color("colorLetter1") : Color.clear)
                                .frame(height: 4)
                        }
                    }

                    Button(action: {
                        self.index = 3
                        self.offset = -self.width
                        data.selected = 1

                    }) {
                        VStack(spacing: 8){
                            HStack(spacing: 12){
                                Text("ARCHIVE").font(.system(size: 14)).fontWeight(.semibold).foregroundColor(self.offset < 0 ? .white : Color("colorLetter1"))
                            }
                            Capsule()
                                .fill(self.offset < 0 ? Color("colorLetter1") : Color.clear)
                                .frame(height: 4)
                        }
                    }
                }
            })
            .padding(.top, (UIApplication.shared.windows.last?.safeAreaInsets.top)!)
                .background(Color("colorPrimary"))
        }
    }
}
