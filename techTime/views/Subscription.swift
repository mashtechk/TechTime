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
                    HStack{
                        Button(action: {
                            backPage()
                        }){
                            Image("back").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                        }
                        
                        Spacer()
                    }.padding()
                    
                    Spacer().frame(height: 40)
                    
                    Image("techtimeName").resizable().frame(width: UIScreen.main.bounds.width*0.6, height:UIScreen.main.bounds.width*0.6*0.2).aspectRatio(contentMode: .fit)

                    Text("Subscription").foregroundColor(Color("colorDarkBlue")).font(.custom("Cooper Black", size: 24)).fontWeight(.bold)
                    
                    VStack {
                        Spacer()
                        
                        VStack {
                            Text("Start with a 1 month free trial.").foregroundColor(Color.white).font(.system(size: 24))

                            Rectangle().foregroundColor(Color("colorDarkBlue")).frame(height: 5).padding(EdgeInsets(top: -3, leading: 0, bottom: 0, trailing: 0))

                            Text("Select from one of the options below.").foregroundColor(Color.black).font(.system(size: 16))
                        }

                        Spacer()

                        Button(action: { self.checkPayment(helper.subOneMonth) }) {
                            Text("$1.99 / month").frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color.white)
                                .font(.custom("Cooper Black", size: 24))
                        }.padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color("colorButtonLight"), Color("colorPrimaryDark")]), startPoint: .top, endPoint: .bottom))
                        .frame(height: UIScreen.main.bounds.height * 0.07)
                        .cornerRadius(30)

                        Spacer().frame(height: UIScreen.main.bounds.height * 0.06)

                        Button(action: { self.checkPayment(helper.subSixMonths) }) {
                            Text("$9.99 / 6 months").frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color.white)
                                .font(.custom("Cooper Black", size: 24))
                        }.padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color("colorButtonLight"), Color("colorPrimaryDark")]), startPoint: .top, endPoint: .bottom))
                        .frame(height: UIScreen.main.bounds.height * 0.07)
                        .cornerRadius(30)

                        Spacer().frame(height: UIScreen.main.bounds.height * 0.06)

                        Button(action: { self.checkPayment(helper.subOneYear) }) {
                            Text("$19.99 / year").frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color.white)
                                .font(.custom("Cooper Black", size: 24))
                        }.padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color("colorButtonLight"), Color("colorPrimaryDark")]), startPoint: .top, endPoint: .bottom))
                        .frame(height: UIScreen.main.bounds.height * 0.07)
                        .cornerRadius(30)
                        
                        Spacer()
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    
                    Text("Auto Renewal Subscription").foregroundColor(Color("colorText3")).font(.system(size: 16))

                    Spacer().frame(height: 10)

                    HStack {
                        Text("Terms and Conditions").foregroundColor(Color("colorText3")).font(.system(size: 16))

                        Spacer()

                        Text("Privacy Policy").foregroundColor(Color("colorText3")).font(.system(size: 16))
                    }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                }
            }
        }
    }
    
    func backPage() {
        self.pageIndex = 0
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
                case .purchased(let expiryDate, _):
                    data.isFull = true
                    data.isPaid = true
                    print("Product is valid until \(expiryDate)")
                case .expired(let expiryDate, _):
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
