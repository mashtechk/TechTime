//  EmailPayView.swift
//  techTime
//  Created by 图娜福尔 on 2020/10/30.

import SwiftUI
import MessageUI

struct EmailPayView: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var selectedId = "1"
    @State var text_name = ""
    let callback: (String) -> ()
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    @StateObject private var keyboardHandler = KeyboardHandler()
    
    func saveData() {
        if data.previousContent == 0 {
            self.pageIndex = 0
        } else {
            self.pageIndex = 9
        }
    }
    
    func backPage() {
        if data.previousContent == 0 {
            self.pageIndex = 0
        } else {
            self.pageIndex = 9
        }
    }
    
    func radioGroupCallback(id: String) {
        selectedId = id
        callback(id)
    }
    
    func sendEmail() {
        self.hideKeyboard()
        if text_name == "" {
            data.showMessage = "Please input the Name or Number"
            data.showingPopup = true
        } else {
            let d = data.currentPeriod.order_list.filter() { $0.payroll_match == "3" }
            
            if selectedId=="2" && d.count==0 {
                data.showMessage = "No incorrect repair orders are currently marked"
                data.showingPopup = true
            } else {
                if  MFMailComposeViewController.canSendMail() {
                    
                    self.isShowingMailView.toggle()
                } else {
                    data.showMessage = "This Phone is not support to send email now"
                    data.showingPopup = true
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            //topbar widget
            HStack{
                HStack{
                    Button(action: {
                        backPage()
                    }){
                        Image("back").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                    }
                    
                    Spacer().frame(width: 20)
                    Text("Email Pay Period").font(.system(size: 20)).fontWeight(.semibold).foregroundColor(.white)
                    
                    Spacer()
                    
                }.padding()
                
            }.padding(.top, (UIApplication.shared.windows.last?.safeAreaInsets.top)!)
            .background(Color("colorPrimary"))
            
            //body widget
            ScrollView(.vertical) {
                VStack{
                    TextField("Enter Name or Employee Number", text: $text_name)
                        .overlay(VStack{Divider().offset(x: 0, y: 15)}.foregroundColor(Color("colorPrimary")))
                        .padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
                    com_list
                    HStack{
                        Text("Email payroll your complete pay period list")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Spacer()
                    }.padding(EdgeInsets(top: -5, leading: 40, bottom: 5, trailing: 0))
                    incor_list
                    HStack{
                        Text("Email payroll the repair orders where the hours do not match your pay period list")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Spacer()
                    }.padding(EdgeInsets(top: -5, leading: 40, bottom: 25, trailing: 0))
                    Divider().frame(height:1).background(Color.gray)
                    VStack{
                        HStack{
                            Text("To mark a repair order as incorrect, return to the pay period list and tap the hours placed in the circle twice")
                                .font(.system(size: 10)).italic()
                                .foregroundColor(.gray)
                        }
                    }
                    Divider().frame(height:1).background(Color.gray)
                    
                    Button(action: {
                        sendEmail()
                    }){
                        Text("COMPOSE EMAIL").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .font(Font.custom("CooperBlack", size: 20, relativeTo: .body))
                            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                            .foregroundColor(.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color("colorButtonLight"), Color("colorPrimaryDark")]), startPoint: .top, endPoint: .bottom))
                            .cornerRadius(25)
                    }.padding(EdgeInsets(top: 30, leading: 0, bottom: 5, trailing: 0))
                    .sheet(isPresented: $isShowingMailView) {
                        MailView(result: self.$result, data:self.$data, selectedId: self.$selectedId, title: $text_name)
                    }
                }.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
            }
            
            Spacer()
        }.frame(maxHeight: .infinity)
        .padding(.bottom, keyboardHandler.keyboardHeight)
    }
    
    var com_list: some View{
        RadioButtonField(
            id: "1",
            label: "Complete List",
            isMarked: self.selectedId == "1" ? true : false,
            callback: radioGroupCallback
        )
    }
    
    var incor_list: some View{
        RadioButtonField(
            id: "2",
            label: "Incorrect Hours List",
            isMarked: self.selectedId == "2" ? true : false,
            callback: radioGroupCallback
        )
    }
}

//#if canImport(UIKit)
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//#endif
