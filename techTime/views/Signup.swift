//
//  Signup.swift
//  techtime
//
//  Created by Marshall on 4/22/21.
//

import SwiftUI
import Firebase

struct Signup: View {
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
                        
                        Button(action: { self.signupEmailPassword()}) {
                            Text("Create Account").frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color.white)
                        }.padding()
                        .background(Color("colorButtonBack"))
                        .frame(height: 50)
                        .cornerRadius(25)
                        
                        Spacer().frame(height: 20)
                        
                        HStack {
                            Text("Have account?").foregroundColor(Color.white)
                            
                            Button(action: { self.gotoSignin()}) {
                                Text("Log in").foregroundColor(Color("colorButtonBack"))
                            }
                        }
                    }.padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
                    
                    Spacer()
                }
            }
        }
    }
    
    func signupEmailPassword() {
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
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
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
    
    func gotoSignin() {
        pageIndex = 14
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
//                    .blur(radius: self.isShowing ? 3 : 0)

                VStack {
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                    Text("Loading...")
                }
                .frame(width: geometry.size.width / 3,
                       height: geometry.size.height / 6)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)

            }
        }
    }
}

#if DEBUG
struct SignupView_Previews: PreviewProvider {
    @State static var data1 : VariableModel = .init(selected: 0, showingPopup: false, showMessage: "", orderByIndex: "0", is_alert: false, currentPeriod: PeriodModel(start_date: "", end_date: "",cancel_date : "" , order_list: []), isEnd: false, archievePeriod: PeriodModel(start_date: "", end_date: "", cancel_date: "" , order_list: []), laborRates: [], order: OrderModel(order_id: "", writer: "", customer: "", insurance_co: "", make: "", model: "", year: "", mileage: "", vin: "", color: "", license: "", notes: "", created_date: "", payroll_match: "", labors: []), histories: [], isFull: true, isTrial: true, isPaid: false, isInternet: true, currentUser: PersonModel(device_id: "", status: false, is_full: false, start_date: "", user_id: "", email: ""), fromVc: "", selectedHours: "", selectedPrice: "" ,selectedType : "", startDate: "", previousContent: 0, previousPageOfOrderView: 0, is_selected_endDate: false)
    @State static var pageIndex1: Int = 14
    
    static var previews: some View {
        Signup(data: $data1, pageIndex: $pageIndex1)
    }
}
#endif
