//
//  Subscription.swift
//  techtime
//
//  Created by mac on 7/7/21.
//

import SwiftUI
import StoreKit
import SwiftyStoreKit
import Firebase

enum SubscriptionState: String {
    case trial
    case sign
    case month
    case six
    case year
}

struct Subscription: View {
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.window) var window: UIWindow?
    
    let helper = Helper()
    
    @State private var isLoading = false
    @State var signInHandler: SignInWithAppleCoordinator?
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            ZStack {
                Image("background").resizable().ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Spacer()
                    
                    Image("techtimeName").resizable().frame(width: UIScreen.main.bounds.width*0.7, height:60).aspectRatio(contentMode: .fit)
                    
                    Text("Subscription").foregroundColor(Color("colorDarkBlue")).font(.custom("Cooper Black", size: 24)).fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack {
                        VStack {
                            Button(action: { self.subscribe(state: .trial) }) {
                                Text("Start with a 1 month free trial.").foregroundColor(Color.white).font(.system(size: 24))
                            }
                            
                            Rectangle().foregroundColor(Color("colorDarkBlue")).frame(height: 5).padding(EdgeInsets(top: -3, leading: 0, bottom: 0, trailing: 0))
                            
                            Text("Select from one of the options below.").foregroundColor(Color.black).font(.system(size: 16))
                        }
                        
                        Spacer().frame(height: 60)
                        
                        HStack {
                            Text("Already Subscribed?").foregroundColor(Color("colorText1")).font(.system(size: 20))
                            
                            Button(action: { self.subscribe(state: .sign) }) {
                                Text("Sign in.").foregroundColor(Color("colorText2")).font(.system(size: 20))
                            }
                        }
                        
                        Spacer().frame(height: 40)
                        
                        Button(action: { self.subscribe(state: .month) }) {
                            Text("$1.99 / month").frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color.white)
                                .font(.custom("Cooper Black", size: 24))
                        }.padding()
                        .background(Color("colorButtonLight"))
                        .frame(height: 60)
                        .cornerRadius(30)
                        
                        Spacer().frame(height: 40)
                        
                        Button(action: { self.subscribe(state: .six) }) {
                            Text("$9.99 / 6 months").frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color.white)
                                .font(.custom("Cooper Black", size: 24))
                        }.padding()
                        .background(Color("colorButtonLight"))
                        .frame(height: 60)
                        .cornerRadius(30)
                        
                        Spacer().frame(height: 40)
                        
                        Button(action: { self.subscribe(state: .year) }) {
                            Text("$19.99 / year").frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color.white)
                                .font(.custom("Cooper Black", size: 24))
                        }.padding()
                        .background(Color("colorButtonLight"))
                        .frame(height: 60)
                        .cornerRadius(30)
                        
                        
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    
                    Spacer()
                    
                    Text("Auto Renewal Subscription").foregroundColor(Color("colorText3")).font(.system(size: 16))
                    
                    Spacer().frame(height: 20)
                    
                    HStack {
                        Text("Terms and Conditions").foregroundColor(Color("colorText3")).font(.system(size: 16))
                        
                        Spacer()
                        
                        Text("Privacy Policy").foregroundColor(Color("colorText3")).font(.system(size: 16))
                    }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
            }
        }.onAppear(perform: {
            checkIsStarted()
        })
    }
    
    func checkIsStarted() {
        if data.currentUser.email != "" {
            pageIndex = 0
        }
    }
    
    func subscribe(state: SubscriptionState) {
        isLoading = true
        
//        if data.currentUser.user_id == "" {
//            data.currentUser.user_id = "Ou0PMJ9b5AOyoCwnDfVkBgeTvYq1"
//            data.currentUser.email = "elliothaker1@gmail.com"
//            helper.setVariable(data: self.data)
//            getDataFromFirebase(state)
//        } else {
//            getDataFromFirebase(state)
//        }
        
        if data.currentUser.user_id == "" {
            do {
                signInHandler = SignInWithAppleCoordinator(window: self.window)
                signInHandler?.signIn { (user) in
                    data.currentUser.user_id = user.uid
                    data.currentUser.email = user.email!
                    helper.setVariable(data: self.data)
                    getDataFromFirebase(state)
                }
            } catch {
                isLoading = false
                
                self.data.showMessage = "Please check your connection."
                self.data.showingPopup = true
            }
        } else {
            getDataFromFirebase(state)
        }
    }
    
    func getDataFromFirebase(_ state: SubscriptionState) {
        let UUID = UIDevice.current.identifierForVendor?.uuidString
        let db = Firestore.firestore()
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MMM dd, yyyy"

        db.collection("users")
            .document(data.currentUser.email)
            .getDocument{(document, error) in
                if (error != nil) {
                    isLoading = false
                    
                    self.data.showMessage = "Please check your connection."
                    self.data.showingPopup = true
                } else {
                    if let document = document, document.exists {
                        let dataDescription = document.data()
                        let start_date = dataDescription!["start_date"] as? String ?? ""
                        let dd = formatter1.date(from: start_date)!
                        data.orderByIndex = dataDescription!["order_by"] as? String ?? "3"
                        let arrayLabors = dataDescription!["laborRates"] as? [Any] ?? []
                        let arrayPeriods = dataDescription!["period"] as? [Any] ?? []

                        if arrayLabors.count > 0 {
                            data.laborRates = []

                            for item_labor in arrayLabors {
                                let labor = item_labor as? [String:Any] ?? [:]
                                let type = labor["type"] as? String ?? ""
                                let rate = labor["rate"] as? String ?? ""
                                data.laborRates.append(LaborModel(type: type, rate: rate, hours: ""))
                            }
                        }

                        if arrayPeriods.count > 0 {
                            data.histories = []

                            for item_period in arrayPeriods {
                                let period = item_period as? [String:Any] ?? [:]
                                let startDate = period["start_date"] as? String ?? ""
                                let endDate = period["end_date"] as? String ?? ""
                                let cancelDate = period["cancel_date"] as? String ?? ""
                                let arrayOrder = period["order_list"] as? [Any] ?? []
                                var list_order: Array<OrderModel> = []

                                for item_order in arrayOrder {
                                    let order = item_order as? [String:Any] ?? [:]
                                    let order_id = order["order_id"] as? String ?? ""
                                    let writer = order["writer"] as? String ?? ""
                                    let customer = order["customer"] as? String ?? ""
                                    let insurance_co = order["insurance_co"] as? String ?? ""
                                    let make = order["make"] as? String ?? ""
                                    let model = order["model"] as? String ?? ""
                                    let year = order["year"] as? String ?? ""
                                    let mileage = order["mileage"] as? String ?? ""
                                    let vin = order["vin"] as? String ?? ""
                                    let color = order["color"] as? String ?? ""
                                    let license = order["license"] as? String ?? ""
                                    let notes = order["notes"] as? String ?? ""
                                    let created_date = order["created_date"] as? String ?? ""
                                    let payroll_match = order["payroll_match"] as? String ?? ""
                                    let array_labors = order["labors"] as? [Any] ?? []
                                    var list_labors: Array<LaborTypeModel> = []

                                    for item_labor in array_labors {
                                        let labor = item_labor as? [String:Any] ?? [:]
                                        let type = labor["type"] as? String ?? ""
                                        let price = labor["price"] as? String ?? ""
                                        let hours = labor["hours"] as? String ?? ""

                                        list_labors.append(LaborTypeModel(type: type, hours: hours, price: price))
                                    }

                                    list_order.append(OrderModel(order_id: order_id, writer: writer, customer: customer, insurance_co: insurance_co, make: make, model: model, year: year, mileage: mileage, vin: vin, color: color, license: license, notes: notes, created_date: created_date, payroll_match: payroll_match, labors: list_labors))
                                }

                                if helper.daysBetweenDates(startDate: cancelDate, endDate: helper.getDate(st: Date())) == true {
                                    data.histories.append(PeriodModel(start_date: startDate, end_date: endDate, cancel_date: cancelDate, order_list: list_order))
                                } else {
                                    data.currentPeriod = PeriodModel(start_date: startDate, end_date: endDate, cancel_date: cancelDate, order_list: list_order)
                                }
                            }
                        }

                        if state == .trial {
                            document.setValue("start_date", forKey: formatter1.string(from: Date()))
                            self.data.startDate = formatter1.string(from: Date())
                        } else {
                            data.startDate = start_date
                        }
                        
                        helper.setVariable(data: data)
                        
                        switch state {
                        case .trial:
                            self.data.isTrial = true
                            isLoading = false
                            pageIndex = 0
                            
                            break
                        case .sign:
                            data.isTrial = helper.is3MonthOver(fromDate: dd)
                            if !data.isTrial {
                                data.isFull = false
                            }
                            
                            isLoading = false
                            pageIndex = 0
                            
                            break
                        case .month:
                            checkPayment(helper.subOneMonth)
                            break
                        case .six:
                            checkPayment(helper.subSixMonths)
                            break
                        case .year:
                            checkPayment(helper.subOneYear)
                            break
                        }
                    } else {
                        let uid = data.currentUser.user_id
                        let data: [String : Any] = [
                            "user_id" : uid,
                            "device_id": UUID!,
                            "status": true,
                            "is_full": false,
                            "start_date": formatter1.string(from: Date())
                        ]

                        db.collection("users").document(self.data.currentUser.email).setData(data) { err in
                            if let err = err {
                                isLoading = false
                                
                                self.data.showMessage = "Please check your connection."
                                self.data.showingPopup = true
                            } else {
                                helper.setVariable(data: self.data)
                                
                                switch state {
                                case .trial:
                                    self.data.isTrial = true
                                    self.data.startDate = formatter1.string(from: Date())
                                    
                                    isLoading = false
                                    pageIndex = 0
                                    
                                    break
                                case .sign:
                                    self.data.isTrial = true
                                    self.data.startDate = formatter1.string(from: Date())
                                    
                                    isLoading = false
                                    pageIndex = 0
                                    
                                    break
                                case .month:
                                    checkPayment(helper.subOneMonth)
                                    break
                                case .six:
                                    checkPayment(helper.subSixMonths)
                                    break
                                case .year:
                                    checkPayment(helper.subOneYear)
                                    break
                                }
                            }
                        }
                    }
                }
            }
    }
    
    func checkPayment(_ productId: String) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: helper.sharedKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            if case .success(let receipt) = result {
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)

                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems):
                    data.isFull = true
                    data.isPaid = true
                    print("Product is valid until \(expiryDate)")
                case .expired(let expiryDate, let receiptItems):
                    data.isFull = false
                    data.isPaid = false
                    print("Product is expired since \(expiryDate)")
                case .notPurchased:
                    data.isFull = false
                    data.isPaid = false
                    print("This product has never been purchased")
                }
            } else {
                // receipt verification error
                print("*****&&&&& this is the receipt verification error *****")
                data.isFull = false
                data.isPaid = false
            }

            isLoading = false
            helper.setVariable(data: data)
            pageIndex = 0
        }
    }
}

#if DEBUG
struct Subscription_Previews: PreviewProvider {
    @State static var data1 : VariableModel = .init(selected: 0, showingPopup: false, showMessage: "", orderByIndex: "0", is_alert: false, currentPeriod: PeriodModel(start_date: "", end_date: "",cancel_date : "" , order_list: []), isEnd: false, archievePeriod: PeriodModel(start_date: "", end_date: "", cancel_date: "" , order_list: []), laborRates: [], order: OrderModel(order_id: "", writer: "", customer: "", insurance_co: "", make: "", model: "", year: "", mileage: "", vin: "", color: "", license: "", notes: "", created_date: "", payroll_match: "", labors: []), histories: [], isFull: true, isTrial: true, isPaid: false, isInternet: true, currentUser: PersonModel(device_id: "", status: false, is_full: false, start_date: "", user_id: "", email: ""), fromVc: "", selectedHours: "", selectedPrice: "" ,selectedType : "", startDate: "", previousContent: 0, previousPageOfOrderView: 0, is_selected_endDate: false)
    @State static var pageIndex1: Int = 14
    
    static var previews: some View {
        Subscription(data: $data1, pageIndex: $pageIndex1)
    }
}
#endif
