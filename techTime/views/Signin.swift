//
//  Signin.swift
//  techtime
//
//  Created by Marshall on 4/21/21.
//

import SwiftUI
import Firebase

struct Signin: View {
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let helper = Helper()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword = false
    @State private var isLoading = false
    
    var body: some View {
        LoadingView(isShowing: $isLoading) {
            ZStack {
                Color("colorPrimary")
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    Image("techtimeName").resizable().frame(width: UIScreen.main.bounds.width*0.6, height:55).aspectRatio(contentMode: .fit)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Image("email").resizable().frame(width: 30, height: 30).aspectRatio(contentMode: .fit)
                            TextField("Email", text: $email).keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }.padding()
                        .background(Color.white)
                        .frame(height: 50)
                        .cornerRadius(25)
                        
                        Spacer().frame(height: 20)
                        
                        HStack {
                            Image("lock").resizable().frame(width: 30, height: 30).aspectRatio(contentMode: .fit)
                                
                            if showPassword {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            
                            Button(action: { self.showPassword.toggle()}) {
                                Image("eye").resizable().frame(width: 30, height: 30).aspectRatio(contentMode: .fit)
                            }
                        }.padding()
                        .background(Color.white)
                        .frame(height: 50)
                        .cornerRadius(25)
                        
                        Spacer().frame(height: 20)
                        
                        Button(action: { self.signinEmailPassword()}) {
                            Text("Log in").frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color.white)
                        }.padding()
                        .background(Color("colorButtonBack"))
                        .frame(height: 50)
                        .cornerRadius(25)
                        
                        Spacer().frame(height: 20)
                        
                        HStack {
                            Text("Don't have account?").foregroundColor(Color.white)
                            
                            Button(action: { self.gotoSignup()}) {
                                Text("Create Account").foregroundColor(Color("colorButtonBack"))
                            }
                        }
                    }.padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
                    
                    Spacer()
                }
            }
        }.onAppear(perform: {
            checkIsSignin()
        })
    }
    
    func checkIsSignin() {
//        if self.data.isSigned {
            self.pageIndex = 0
//        }
    }
    
    func signinEmailPassword() {
        hideKeyboard()
                
        if email == "" {
            self.data.showMessage = "Please input the email"
            self.data.showingPopup = true
            return
        }
        
        if password == "" {
            self.data.showMessage = "Please input the password"
            self.data.showingPopup = true
            return
        }
        
        if !isValidEmail(email) {
            self.data.showMessage = "Invalid email address"
            self.data.showingPopup = true
            return
        }
        
        if password.count < 8 {
            self.data.showMessage = "Your password must be at least 8 characters"
            self.data.showingPopup = true
            return
        }
        
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false
            
            if error != nil {
                self.data.showMessage = error!.localizedDescription
                self.data.showingPopup = true
                return
            }
            
//            self.data.isSigned = true
            helper.setVariable(data: self.data)
            
            pageIndex = 0
        }
    }
    
    func gotoSignup() {
        pageIndex = 15
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

#if DEBUG
struct SigninView_Previews: PreviewProvider {
    @State static var data1 : VariableModel = .init(selected: 0, showingPopup: false, showMessage: "", orderByIndex: "0", is_alert: false, currentPeriod: PeriodModel(start_date: "", end_date: "",cancel_date : "" , order_list: []), isEnd: false, archievePeriod: PeriodModel(start_date: "", end_date: "", cancel_date: "" , order_list: []), laborRates: LaborRatesModel(body_rate: "", mechanical_rate: "", internal_rate: "", warranty_rate: "", refinish_rate: "", glass_rate: "", frame_rate: "", aluminum_rate: "", other_rate: ""), order: OrderModel(order_id: "", writer: "", customer: "", insurance_co: "", make: "", model: "", year: "", mileage: "", vin: "", color: "", license: "", notes: "", created_date: "", payroll_match: "", labors: []), histories: [], isFull: true, isTrial: true, isInternet: true, currentUser: PersonModel(device_id: "", status: false, is_full: false, start_date: "", user_id: "", email: ""), fromVc: "", selectedHours: "", selectedPrice: "" ,selectedType : "", previousContent: 0, previousPageOfOrderView: 0)
    @State static var pageIndex1: Int = 14
    
    static var previews: some View {
        Signin(data: $data1, pageIndex: $pageIndex1)
    }
}
#endif
