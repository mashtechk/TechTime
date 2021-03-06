import SwiftUI
import StoreKit
import SwiftyStoreKit
import AuthenticationServices
import CryptoKit
import Firebase
import UIKit

struct PayContent: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    
    @State var is_alert = false
    @State var is_expired = false
    @State var is_loading = false
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @State private var total_hours = "0.0"
    @State private var total_orders = "0"
    @State private var total_gross = "$ 0.00"
    
    @Environment(\.window) var window: UIWindow?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.scenePhase) var scenePhase
    
    @State var signInHandler: SignInWithAppleCoordinator?
    
    @State private var order_lists : Array<OrderModel> = []
    
    let helper = Helper()
    
    private var dateProxy:Binding<Date> {
        Binding<Date>(get: {self.endDate }, set: {
            self.endDate = $0
            print("----- this is the end date data -----")
            print($0)
            self.data.is_selected_endDate = true
        })
    }
    
    var body: some View {
        VStack{
            //order data list
            if self.data.currentPeriod.start_date == "" {
                new_period_content
            } else {
                order_list
            }
            //when there is no pay period data
        }.onAppear(perform: {
            modify_data()
        }).onChange(of: scenePhase, perform: { value in
            switch value {
            case .background:
                print("Background")
            case .active:
                active_view()
            case .inactive:
                print("Inactive")
            @unknown default:
                print("Default")
            }
        })
    }
    
    func active_view() {
        if data.currentUser.email != "" {
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "MMM dd, yyyy"
            
            var start_date = ""
            if data.startDate == "" {
                start_date = formatter1.string(from: Date())
            } else {
                start_date = data.startDate
            }
            
            let dd = formatter1.date(from: start_date)!
            
            if data.currentUser.email == "55gwsp2y7j@privaterelay.appleid.com" {
                data.isTrial = helper.is1DayOver(fromDate: dd)
            } else {
                data.isTrial = helper.is3MonthOver(fromDate: dd)
            }
            
            if !data.isPaid && !data.isTrial {
                data.isFull = false
                
                if data.currentPeriod.cancel_date != "" {
                    data.currentPeriod.cancel_date = helper.getDate(st: Date().dayBefore)
                    data.histories.append(data.currentPeriod)
                    data.isEnd = true
                    data.currentPeriod = PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: [])
                    
                    helper.savePeriodsToFirebase(data: self.data)
                    
                    startDate = Date()
                    endDate = Date()
                    
                    total_hours = "0.0"
                    total_orders = "0"
                    total_gross = "$ 0.00"
                    
                    order_lists = self.data.currentPeriod.order_list
                }
            } else {
                //check if difference between two dates is 1
                if data.currentPeriod.cancel_date != "" && helper.daysBetweenDates(startDate:data.currentPeriod.cancel_date, endDate: helper.getDate(st: Date())) == true {
                    data.currentPeriod.cancel_date = data.currentPeriod.end_date//self.getDate(st: Date())
                    data.histories.append(data.currentPeriod)
                    data.isEnd = true
                    data.currentPeriod = PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: [])
                    
                    helper.savePeriodsToFirebase(data: self.data)
                    
                    startDate = Date()
                    endDate = Date()
                    
                    total_hours = "0.0"
                    total_orders = "0"
                    total_gross = "$ 0.00"
                    
                    order_lists = self.data.currentPeriod.order_list
                }
            }
        }
    }
    
    func modify_data() {
        total_orders = String(data.currentPeriod.order_list.count)
        if data.currentPeriod.order_list.count > 0 {
            var hours = 0.0
            var gross = 0.00
            for order in data.currentPeriod.order_list {
                for labor in order.labors {
                    if labor.hours != "" {
                        hours+=Double(labor.hours) ?? 0.00
                        gross+=Double(labor.hours)! * Double(labor.price)!
                    }
                }
            }
            total_hours = helper.formatHours(h: hours)
            total_gross = helper.formatPrice(p: gross)
            
        }
        order_lists = self.data.currentPeriod.order_list
        
        if data.orderByIndex == "1" {
            order_lists = order_lists.sorted { Int($0.order_id)! < Int($1.order_id)! }
        }
        if data.orderByIndex == "2" {
            order_lists = order_lists.sorted { Int($0.order_id)! > Int($1.order_id)! }
        }
        if data.orderByIndex == "3" {
            order_lists = order_lists.sorted{ $0.created_date > $1.created_date }
            order_lists = order_lists.reversed()
        }
    }
    
    var order_list: some View {
        return VStack{
            VStack{
                HStack{
                    HStack{
                        Text(total_hours).font(.system(size: 15)).foregroundColor(Color("colorLetter2")).fontWeight(.semibold)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.width/3)
                    HStack{
                        Text(total_orders).font(.system(size: 15)).foregroundColor(Color("colorLetter2")).fontWeight(.semibold)
                    }.frame(width: UIScreen.main.bounds.width/3)
                    HStack{
                        Spacer()
                        Text(order_lists.count == 0 ? "$0.00" : total_gross).font(.system(size: 15)).foregroundColor(order_lists.count == 0 ? Color("colorLetter2") : total_gross.contains("-") ? Color("colorGrossNegative") : Color("colorGrossPossitive")).fontWeight(.semibold)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }.frame(width: UIScreen.main.bounds.width/3)
                }.padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                HStack{
                    HStack{
                        Text("TOTAL HOURS").font(.system(size: 10)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        Spacer()
                    }.frame(width:UIScreen.main.bounds.width/3)
                    HStack{
                        Text("REPAIR ORDERS").font(.system(size: 10)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                    }.frame(width:UIScreen.main.bounds.width/3)
                    HStack{
                        Spacer()
                        Text("TOTAL GROSS").font(.system(size: 10)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }.frame(width:UIScreen.main.bounds.width/3)
                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 3, trailing: 10))
                Divider().frame(height:2).background(Color("colorDivider"))

            }.alert(isPresented: $is_alert) {
                Alert(
                    title: Text(""),
                    message: Text("Delete this pay period?"),
                    primaryButton: .destructive(Text("Delete")) {
                        //delte the current archive data
                        data.isEnd = false
                        data.histories = []
                        data.currentPeriod = PeriodModel(start_date: "", end_date: "", cancel_date : "", order_list: [])
                        helper.setVariable(data: data)
                        helper.savePeriodsToFirebase(data: self.data)
                    },
                    secondaryButton: .cancel()
                )
            }
            
            Spacer().frame(height:0)
            
            ScrollView(.vertical) {
                Spacer().frame(height: 10)
                if order_lists.count > 0 {
                    ForEach(0..<order_lists.count) { i in
                        OrderSummery(order: order_lists[i], data: $data, pageIndex: self.$pageIndex, isFromSearch: false)
                    }
                }
                Spacer().frame(height: 10)
            }
            
            Spacer().frame(height:0)
            
            //action button
            //there is NEW ORDER BUTTON
            VStack{
                Divider().frame(height:2).background(Color("colorDivider"))
                Button(action: {
                    self.data.order = OrderModel(order_id: "", writer: "", customer: "", insurance_co: "", make: "", model: "", year: "", mileage: "", vin: "", color: "", license: "", notes: "", created_date: "", payroll_match: "", labors: [])
                    self.data.fromVc = "Add Order"
                    addOrder()
                }) {
                    Text("ADD REPAIR ORDER")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(Font.custom("CooperBlack", size: 20, relativeTo: .body))
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .accentColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color("colorButtonLight"), Color("colorPrimaryDark")]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(25)
                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                .alert(isPresented: $is_expired) {
                    Alert(
                        title: Text(""),
                        message: Text("Your free one month trial has ended. To continue using techtime please subscribe."),
                        primaryButton: .destructive(Text("Subscribe")) {
                            pageIndex = 11
                            
//                            SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
//                                if let product = result.retrievedProducts.first {
//                                    SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
//                                        switch result {
//                                        case .success(let purchase):
//                                            print("Purchase Success: \(purchase.productId)")
//                                            data.isFull = true
//                                            data.isPaid = true
//                                        case .error(let error):
//                                            data.isFull = false
//                                            data.isPaid = false
//                                            switch error.code {
//                                            case .unknown: print("Unknown error. Please contact support")
//                                            case .clientInvalid: print("Not allowed to make the payment")
//                                            case .paymentCancelled: break
//                                            case .paymentInvalid: print("The purchase identifier was invalid")
//                                            case .paymentNotAllowed: print("The device is not allowed to make the payment")
//                                            case .storeProductNotAvailable: print("The product is not available in the current storefront")
//                                            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
//                                            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
//                                            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
//                                            default: print((error as NSError).localizedDescription)
//
//                                            }
//                                        }
//                                    }
//                                    if data.isFull && data.isEnd {
//                                        data.currentPeriod = PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: [])
//                                    }
//                                    helper.setVariable(data: data)
//                                }
//                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                Spacer().frame(height:5)
            }
        }.background(.white)
    }
    
    var new_period_content: some View{
        return VStack{
            VStack{
                HStack{
                    HStack{
                        Text("0.0")
                            .font(.system(size: 13))
                            .foregroundColor(Color("colorLetter2"))
                            .fontWeight(.semibold)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        Spacer()
                    }.frame(width:UIScreen.main.bounds.width/3)
                    HStack{
                        Text("0")
                            .font(.system(size: 13))
                            .foregroundColor(Color("colorLetter2"))
                            .fontWeight(.semibold)
                    }.frame(width:UIScreen.main.bounds.width/3)
                    HStack{
                        Spacer()
                        Text("$0.00")
                            .font(.system(size: 13))
                            .foregroundColor(Color("colorLetter2"))
                            .fontWeight(.semibold)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }.frame(width:UIScreen.main.bounds.width/3)
                }.padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                HStack{
                    HStack{
                        Text("TOTAL HOURS").font(.system(size: 10)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        Spacer()
                    }.frame(width:UIScreen.main.bounds.width/3)
                    HStack{
                        Text("REPAIR ORDERS").font(.system(size: 10)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                    }.frame(width:UIScreen.main.bounds.width/3)
                    HStack{
                        Spacer()
                        Text("TOTAL GROSS").font(.system(size: 10)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }.frame(width:UIScreen.main.bounds.width/3)
                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 3, trailing: 10))
                Divider().frame(height:2).background(Color("colorDivider"))
            }
            VStack{
                Spacer().frame(height: 40)
                Text("NO ACTIVE PAY PERIOD")
                    .font(.system(size: 17))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("ColorBlue"))
                Spacer().frame(height:10)
                Text("Get started by adding the start and end date of your pay period")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .frame(alignment:.center)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                Spacer().frame(height:15)
                HStack{
                    Text("START DATE")
                        .font(.system(size: 15))
                        .foregroundColor(Color("ColorBlue"))
                    Spacer()
                    Text("END DATE")
                        .font(.system(size: 15))
                        .foregroundColor(Color("ColorBlue"))
                }.padding(EdgeInsets(top: 10, leading: 37, bottom: 0, trailing: 42))
                HStack{
                    Text(helper.getDate(st: startDate))
                        .frame(width:120, height: 40)
                        .overlay(DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .frame(width: 120, height:40)
                                    .labelsHidden()
                                    .accentColor(Color("colorPicker"))
                                    .border(Color("colorPrimary"), width: 3)
                                    .cornerRadius(4), alignment: .center)
//                    DatePicker("", selection: $startDate, displayedComponents: .date)
//                        .frame(width: 120, height:40)
//                        .labelsHidden()
//                        .accentColor(.black)
//                        .border(Color("colorPrimary"), width: 3)
//                        .cornerRadius(4)
//                        .animation(nil)
//                        .transformEffect(.init(scaleX: 0.8, y: 1))
                    
                    Spacer()
                    Text(self.data.is_selected_endDate ? helper.getDate(st: endDate) : "")
                        .frame(width:120, height: 40)
                        .overlay(DatePicker("", selection: dateProxy, in: Date()..., displayedComponents: .date)
                                    .frame(width: 120, height:40)
                                    .labelsHidden()
                                    .accentColor(Color("colorPicker"))
                                    .border(Color("colorPrimary"), width: 3)
                                    .cornerRadius(4), alignment: .center)
                    
//                        .transformEffect(.init(scaleX: 0.8, y: 1))
                }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
            
            Spacer()
            
            // action button
            // there is no period data
            VStack{
                Divider().frame(height:2).background(Color("colorDivider"))
                Button(action: {
                    startPayPeriod()
                    
                }){
                    Text("START PAY PERIOD").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .font(Font.custom("CooperBlack", size: 20, relativeTo: .body))
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .foregroundColor(.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color("colorButtonLight"), Color("colorPrimaryDark")]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(25)
                }.padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                .alert(isPresented: $is_expired) {
                    Alert(
                        title: Text(""),
                        message: Text("Your free one month trial has ended. To continue using techtime please subscribe."),
                        primaryButton: .destructive(Text("Subscribe")) {
                            pageIndex = 11
                            
//                            SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
//                                if let product = result.retrievedProducts.first {
//                                    SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
//                                        switch result {
//                                        case .success(let purchase):
//                                            print("Purchase Success: \(purchase.productId)")
//                                            data.isFull = true
//                                            data.isPaid = true
//                                        case .error(let error):
//                                            data.isFull = false
//                                            data.isPaid = false
//                                            switch error.code {
//                                            case .unknown: print("Unknown error. Please contact support")
//                                            case .clientInvalid: print("Not allowed to make the payment")
//                                            case .paymentCancelled: break
//                                            case .paymentInvalid: print("The purchase identifier was invalid")
//                                            case .paymentNotAllowed: print("The device is not allowed to make the payment")
//                                            case .storeProductNotAvailable: print("The product is not available in the current storefront")
//                                            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
//                                            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
//                                            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
//                                            default: print((error as NSError).localizedDescription)
//                                            }
//                                        }
//                                    }
//                                    if data.isFull && data.isEnd {
//                                        data.currentPeriod = PeriodModel(start_date: "", end_date: "",cancel_date : ""  ,order_list: [])
//                                    }
//                                    helper.setVariable(data: data)
//                                }
//                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                Spacer().frame(height:5)
            }
        }
    }
    
    func showDatePicker() {
        weak var datePicker: UIDatePicker!
        datePicker.preferredDatePickerStyle = .inline
    }
    
    func startPayPeriod(){
        if is_loading {
            self.data.showMessage = "Please wait a moment."
            self.data.showingPopup = true
            return
        }
        
        if data.currentUser.email == "" {
            is_loading = true
            check_login()
            return
        }

        if(!data.isPaid && !data.isFull) {
            is_expired = true
            return
        }
        
        //save period data
        if self.data.is_selected_endDate {
            if self.startDate > Date() {
                self.data.showMessage = "START DATE cannot be later than today's date"
                self.data.showingPopup = true
                return
            }
            
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "MMM dd, yyyy"

            if self.data.histories.count > 0 && helper.isBiggerDate(oneDate: self.data.histories.last?.cancel_date ?? "", twoDate: formatter1.string(from: self.startDate))  == true {
                self.data.showMessage = "START DATE interferes with previous PAY PERIOD"
                self.data.showingPopup = true
                return
            }
            self.data.currentPeriod = PeriodModel(start_date: formatter1.string(from: self.startDate), end_date: formatter1.string(from: self.endDate), cancel_date: helper.getDate(st: self.endDate), order_list: [])
            self.data.isEnd = false
            self.total_hours = "0.0"
            self.total_orders = "0"
            self.total_gross = "$ 0.0"
            self.order_lists = []
            helper.setVariable(data: self.data)
            self.data.showMessage = "New pay period started!"
            self.data.showingPopup = true
        } else {
            self.data.showMessage = "Please select the end date"
            self.data.showingPopup = true
        }
    }
    
    //add repair order
    func addOrder() {
        print("----- check the laborrates setting ------")
        if data.isInternet {
            if data.isFull {
                var isSelected = false
                
                for item in data.laborRates {
                    if item.rate != "" {
                        isSelected = true
                        break
                    }
                }
                
                if !isSelected {
                    self.data.showMessage = "Please set your labor rates"
                    self.data.showingPopup = true
                } else {
                    self.pageIndex = 6
                }
            } else {
                is_expired = true
            }
        } else {
            self.data.showMessage = "Warning! Please connect to network"
            self.data.showingPopup = true
        }
    }
    
    func check_login() {
        signInHandler = SignInWithAppleCoordinator(window: self.window)
        signInHandler?.signIn { (user) in
            data.currentUser.user_id = user.uid
            data.currentUser.email = user.email!
            helper.setVariable(data: self.data)
            getDataFromFirebase()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func getDataFromFirebase() {
        let UUID = UIDevice.current.identifierForVendor?.uuidString
        let db = Firestore.firestore()
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MMM dd, yyyy"

        db.collection("users")
            .document(data.currentUser.email)
            .getDocument{(document, error) in
                if (error != nil) {
                    is_loading = false

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

                        data.startDate = start_date
                        
                        if data.currentUser.email == "55gwsp2y7j@privaterelay.appleid.com" {
                            data.isTrial = helper.is1DayOver(fromDate: dd)
                        } else {
                            data.isTrial = helper.is3MonthOver(fromDate: dd)
                        }
                        
                        if !data.isTrial {
                            data.isFull = false
                        }
                        helper.setVariable(data: data)

                        is_loading = false
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
                            if err != nil {
                                is_loading = false

                                self.data.showMessage = "Please check your connection."
                                self.data.showingPopup = true
                            } else {
                                self.data.isTrial = true
                                self.data.startDate = formatter1.string(from: Date())
                                helper.setVariable(data: self.data)

                                is_loading = false
                            }
                        }
                    }
                }
            }
    }
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

