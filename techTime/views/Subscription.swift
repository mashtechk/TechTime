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
                    }.padding(.top, (UIApplication.shared.windows.last?.safeAreaInsets.top)!)
                    .padding(.leading, 20)
                    
                    Spacer().frame(height: 30)
                    
                    Image("techtimeName").resizable().frame(width: UIScreen.main.bounds.width*0.6, height:UIScreen.main.bounds.width*0.6*0.2).aspectRatio(contentMode: .fit)

                    Text("Subscription").foregroundColor(Color("colorDarkBlue")).font(.custom("Cooper Black", size: 24)).fontWeight(.bold)
                    
                    VStack {
                        Spacer()
                        
                        VStack {
                            Text("1 month free trial has ended").foregroundColor(Color.white).font(.system(size: 24))

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
                        Button(action: { self.gotoTermsConditions() }) {
                            Text("Terms and Conditions").foregroundColor(Color("colorText3")).font(.system(size: 16))
                        }

                        Spacer()

                        Button(action: { self.gotoPrivacyPolicy() }) {
                            Text("Privacy Policy").foregroundColor(Color("colorText3")).font(.system(size: 16))
                        }
                    }.padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                }
            }
        }
    }
    
    func backPage() {
        self.pageIndex = 0
    }
    
    func checkPayment(_ productId: String) {
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            if let product = result.retrievedProducts.first {
                SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                    var errMsg = ""
                    
                    switch result {
                    case .success(let purchase):
                        print("Purchase Success: \(purchase.productId)")
                        data.isFull = true
                        data.isPaid = true
                    case .error(let error):
                        data.isFull = false
                        data.isPaid = false
                        
                        switch error.code {
                        case .unknown: errMsg = "Unknown error. Please contact support"
                        case .clientInvalid: errMsg = "Not allowed to make the payment"
                        case .paymentCancelled: break
                        case .paymentInvalid: errMsg = "The purchase identifier was invalid"
                        case .paymentNotAllowed: errMsg = "The device is not allowed to make the payment"
                        case .storeProductNotAvailable: errMsg = "The product is not available in the current storefront"
                        case .cloudServicePermissionDenied: errMsg = "Access to cloud service information is not allowed"
                        case .cloudServiceNetworkConnectionFailed: errMsg = "Could not connect to the network"
                        case .cloudServiceRevoked: errMsg = "User has revoked permission to use this cloud service"
                        default: errMsg = (error as NSError).localizedDescription
                        }
                    }
                    
                    if data.isFull && data.isEnd {
                        data.currentPeriod = PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: [])
                        
                        isLoading = false
                        helper.setVariable(data: data)
                        pageIndex = 0
                    } else {
                        isLoading = false
                        helper.setVariable(data: data)
                        
                        self.data.showMessage = errMsg
                        self.data.showingPopup = true
                    }
                }
            }
        }
    }
    
    func gotoTermsConditions() {
        UIApplication.shared.open(URL(string: "https://techtimeapp.com/terms-and-conditions")!)
    }
    
    func gotoPrivacyPolicy() {
        UIApplication.shared.open(URL(string: "https://techtimeapp.com/privacy-policy")!)
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
