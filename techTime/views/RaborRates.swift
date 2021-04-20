//  RaborRates.swift
//  techTime
//  Created by 图娜福尔 on 2020/10/30.

import SwiftUI

struct LaborRates: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let helper = Helper()

    var body: some View {
        VStack{
            //topbar widget
            HStack{
                HStack{
                    Button(action: {
                        backPage()
                    }){
                        Image("back").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                    }
                    
                    Spacer().frame(width: 20)
                    
                    Text("Labor Rates").font(.system(size: 20)).fontWeight(.semibold).foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        saveData()
                    }){
                        Image("check").renderingMode(.template).resizable().frame(width: 20, height: 15).aspectRatio(contentMode: .fit).foregroundColor(.white)
                    }
                }.padding()
                
            }.padding(.top, (UIApplication.shared.windows.last?.safeAreaInsets.top)!)
            .background(Color("colorPrimary"))
            
            //body widget
            ScrollView{
                VStack{
                    HStack{
                        Text("Labor Type")
                            .font(.system(size: 17))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("ColorBlue"))
                        Spacer()
                    }
                    Spacer().frame(height:10)
                    Text("Simply enter the amount you earn per flagged hour. When you are all done, tap the check mark to save.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer().frame(height:20)

                    //body
                    VStack{
                        TextFieldWidget(text_name: self.$data.laborRates.body_rate, field_name: "Body")
                        TextFieldWidget(text_name: self.$data.laborRates.mechanical_rate, field_name: "Mechanical")
                        TextFieldWidget(text_name: self.$data.laborRates.internal_rate, field_name: "Internal")
                        TextFieldWidget(text_name: self.$data.laborRates.warranty_rate, field_name: "Warranty")
                        TextFieldWidget(text_name: self.$data.laborRates.refinish_rate, field_name: "Refinish")
                        TextFieldWidget(text_name: self.$data.laborRates.glass_rate, field_name: "Glass")
                        TextFieldWidget(text_name: self.$data.laborRates.frame_rate, field_name: "Frame")
                        TextFieldWidget(text_name: self.$data.laborRates.aluminum_rate, field_name: "Aluminum")
                        TextFieldWidget(text_name: self.$data.laborRates.other_rate, field_name: "Other")
                    }
                    
                }.padding()
            }.navigationBarHidden(true)
            Spacer()
        }
    }
    
    func saveData() {
        self.hideKeyboard()
        var isSelected = false
        if data.laborRates.body_rate != "" || data.laborRates.mechanical_rate != "" || data.laborRates.internal_rate != "" || data.laborRates.warranty_rate != "" || data.laborRates.refinish_rate != "" {
            isSelected = true
        }
        if data.laborRates.glass_rate != "" || data.laborRates.frame_rate != "" || data.laborRates.aluminum_rate != "" || data.laborRates.other_rate != "" || isSelected {
            isSelected = true
            data.laborRates.body_rate = helper.stringToDoubleToString(st: data.laborRates.body_rate)
            data.laborRates.mechanical_rate = helper.stringToDoubleToString(st: data.laborRates.mechanical_rate)
            data.laborRates.internal_rate = helper.stringToDoubleToString(st: data.laborRates.internal_rate)
            data.laborRates.warranty_rate = helper.stringToDoubleToString(st: data.laborRates.warranty_rate)
            data.laborRates.refinish_rate = helper.stringToDoubleToString(st: data.laborRates.refinish_rate)
            data.laborRates.glass_rate = helper.stringToDoubleToString(st: data.laborRates.glass_rate)
            data.laborRates.frame_rate = helper.stringToDoubleToString(st: data.laborRates.frame_rate)
            data.laborRates.aluminum_rate = helper.stringToDoubleToString(st: data.laborRates.aluminum_rate)
            data.laborRates.other_rate = helper.stringToDoubleToString(st: data.laborRates.other_rate)
        }
        if isSelected {
            // save data code
            // save rates data in device
            helper.setVariable(data: self.data)
//            if let encoded = try? JSONEncoder().encode(self.data.laborRates) {
//                    UserDefaults.standard.set(encoded, forKey: "labor_rates")
//            }
            self.data.showMessage = "Labor rates saved"
            self.data.showingPopup = true
            self.pageIndex = 0
           
            
        } else {
            self.data.showMessage = "Please set your labor rates"
            self.data.showingPopup = true
            return
        }
    }
    
    func backPage() {
        if !self.data.laborRates.isSetLaborRate() {
            if let encoded = try? JSONEncoder().encode(self.data.laborRates) {
                    UserDefaults.standard.set(encoded, forKey: "labor_rates")
            }
        }
        self.hideKeyboard()
        self.pageIndex = 0
        
    }
}

struct TextFieldWidget: View {
    
    @Binding var text_name: String
    @State var isActive = false
    var field_name: String

    var body: some View {
        HStack{
            Text(field_name).font(.system(size: 15)).fontWeight(.semibold).foregroundColor(.gray)
            Spacer()
            Text("Rate  $").font(.system(size: 15)).fontWeight(text_name == "" ? .none : .semibold).foregroundColor(text_name == "" ? .gray : Color("ColorBlue"))
            TextField(text_name, text: $text_name, onEditingChanged: {
                self.isActive = $0
                })
                .frame(width:70)
                .keyboardType(.decimalPad)
                .overlay(VStack{Divider().frame(height: 1).background(isActive ? Color("ColorBlue") : Color(.gray)).offset(x: 0, y: 10)})
            
        }.padding(.bottom, 8)
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
