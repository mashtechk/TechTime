//
//  ContentView.swift
//  techTime
//  Created by 图娜福尔 on 2020/10/30.

// For the period data management
// use the UserDefaults
// current period variable "current_period" : model data period model
// history period variable "history_period" : array
// labor rate variable "labor_rate" : model data of labor rate model

import SwiftUI
import PopupView
import Firebase
import AuthenticationServices
import CryptoKit
import SwiftyStoreKit
import StoreKit

struct ContentView: View {
    
    @State private var showModal = false
    @Environment(\.window) var window: UIWindow?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var signInHandler: SignInWithAppleCoordinator?
    
    @State var data : VariableModel = .init(selected: 0, showingPopup: false, showMessage: "", orderByIndex: "0", is_alert: false, currentPeriod: PeriodModel(start_date: "", end_date: "",cancel_date : "" , order_list: []), isEnd: false, archievePeriod: PeriodModel(start_date: "", end_date: "", cancel_date: "" , order_list: []), laborRates: LaborRatesModel(body_rate: "", mechanical_rate: "", internal_rate: "", warranty_rate: "", refinish_rate: "", glass_rate: "", frame_rate: "", aluminum_rate: "", other_rate: ""), order: OrderModel(order_id: "", writer: "", customer: "", insurance_co: "", make: "", model: "", year: "", mileage: "", vin: "", color: "", license: "", notes: "", created_date: "", payroll_match: "", labors: []), histories: [], isFull: true, isTrial: true, isInternet: true, currentUser: PersonModel(device_id: "", status: false, is_full: false, start_date: "", user_id: "", email: ""), fromVc: "", selectedHours: "", selectedPrice: "" ,selectedType : "")
    
    @State private var pageIndex = 0
    
    @State var helper = Helper()
    @State var iaphelper = IAPHelper()

    init() {
        UIScrollView.appearance().bounces = false
        let d = helper.getVariable()
        _data = State(initialValue: d)
        
    }
   
    var body: some View {
        ZStack{
            switch pageIndex {
                case 0: // main page
                    MainPage(data: $data, pageIndex: $pageIndex)
                   
                case 1: // labor rates input page
                    LaborRates(data: $data, pageIndex: $pageIndex)
                case 2: // search page
                    SearchView(data: $data, pageIndex: $pageIndex)
                case 3: // edit pay period dates page
                    EditPeriodView(data: $data, pageIndex: $pageIndex)
                case 4: // order by
                    OrderbyView(data: $data, pageIndex: $pageIndex) { (String) in
                        data.orderByIndex
                    }
                case 5: // email pay page
                    EmailPayView(data: $data, pageIndex: $pageIndex){ (String) in
                        "1"
                    }
                case 6: // add repair order page
                    AddOrderView(data: $data, pageIndex: $pageIndex)
                case 7: // add order detail page
                    Orderview(data: $data, pageIndex: $pageIndex)
                case 8: // edit current order detail page
                    EditOrderView(data: $data, pageIndex: $pageIndex)
                case 9: // archieve period page
                    ArchivePayView(data: $data, pageIndex: $pageIndex)
                case 10: // add archive order detail page
                    ArchiveOrderView(data: $data, pageIndex: $pageIndex)
                case 11: // main page
                    MainInstead(data: $data, pageIndex: $pageIndex)
                case 12: // Archive
                    ArchiveContent(data: $data, pageIndex: $pageIndex)
                case 13: // Pay Content
                     PayContent(data: $data, pageIndex: $pageIndex)
                default:
                    MainPage(data: $data, pageIndex: $pageIndex)
            }
        }.edgesIgnoringSafeArea(.top)
        .popup(isPresented: $data.showingPopup, type: .floater(verticalPadding: 120), position: .bottom, autohideIn: 2) {
            HStack {
                Text(data.showMessage)
                    .font(.system(size: 14))
                    .padding()
            }
            .frame(width: 250)
            .background(Color("colorToast"))
            .cornerRadius(20.0)
        }
    }
}

//#if DEBUG
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
//#endif

