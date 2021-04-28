//  AddOrderView.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/2.

import SwiftUI

struct AddOrderView: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    @Environment(\.presentationMode) var presentation

    let helper = Helper()
   @State var body_rate = ""
   @State var mechanical_rate = ""
   @State var internal_rate = ""
   @State var warranty_rate = ""
   @State var refinish_rate = ""
   @State var glass_rate = ""
   @State var frame_rate = ""
   @State var aluminum_rate = ""
   @State var other_rate = ""
    
    @State var test_value = ""
    @State var selected_field = ""
    
    @State var menus : Array<String> = ["Add Labor"]
    @State var selectedMenus : Array<String> = []
    @StateObject private var keyboardHandler = KeyboardHandler()
    
    func modify() {
        
        if data.laborRates.body_rate != "" {
            menus.append("Body")
        }
        if data.laborRates.mechanical_rate != "" {
            menus.append("Mechanical")
        }
        if data.laborRates.internal_rate != "" {
            menus.append("Internal")
        }
        if data.laborRates.warranty_rate != "" {
            menus.append("Warranty")
        }
        if data.laborRates.refinish_rate != "" {
            menus.append("Refinish")
        }
        if data.laborRates.glass_rate != "" {
            menus.append("Glass")
        }
        if data.laborRates.frame_rate != "" {
            menus.append("Frame")
        }
        if data.laborRates.aluminum_rate != "" {
            menus.append("Aluminum")
        }
        if data.laborRates.other_rate != "" {
            menus.append("Other")
        }
        menus = menus.reversed()
    }
    
    func saveData() {
        
        self.hideKeyboard()
        var isSelected = true
        if data.fromVc == "Recreate" {
            if self.data.order.labors.count > 0 {
                self.data.order.labors.removeAll()
            }
        }
        
        if data.order.order_id == "" {
            isSelected = false
        }
        if data.order.order_id.contains(".") {
            self.data.showMessage = "Please input the number in Repair Order"
            self.data.showingPopup = true
            return
        }
        if data.order.writer == "" {
            isSelected = false
        }
        if selectedMenus.contains("Body") && body_rate == "" {
            self.data.showMessage = "Labor Type 'Body' Is Missing Hours Performed"
            self.data.showingPopup = true
            return
        }
        if selectedMenus.contains("Mechanical") && mechanical_rate == "" {
            self.data.showMessage = "Labor Type 'Mechanical' Is Missing Hours Performed"
            self.data.showingPopup = true
            return
        }
        if selectedMenus.contains("Internal") && internal_rate == "" {
            self.data.showMessage = "Labor Type 'Internal' Is Missing Hours Performed"
            self.data.showingPopup = true
            return
        }
        if selectedMenus.contains("Warranty") && warranty_rate == "" {
            self.data.showMessage = "Labor Type 'Warranty' Is Missing Hours Performed"
            self.data.showingPopup = true
            return
        }
        if selectedMenus.contains("Refinish") && refinish_rate == "" {
            self.data.showMessage = "Labor Type 'Refinish' Is Missing Hours Performed"
            self.data.showingPopup = true
            return
        }
        if selectedMenus.contains("Glass") && glass_rate == "" {
            self.data.showMessage = "Labor Type 'Glass' Is Missing Hours Performed"
            self.data.showingPopup = true
            return
        }
        if selectedMenus.contains("Frame") && frame_rate == "" {
            self.data.showMessage = "Labor Type 'Frame' Is Missing Hours Performed"
            self.data.showingPopup = true
            return
        }
        if selectedMenus.contains("Aluminum") && aluminum_rate == "" {
            self.data.showMessage = "Labor Type 'Aluminum' Is Missing Hours Performed"
            self.data.showingPopup = true
            return
        }
        if selectedMenus.contains("Other") && other_rate == "" {
            self.data.showMessage = "Labor Type 'Other' Is Missing Hours Performed"
            self.data.showingPopup = true
            return
        }
        if body_rate == "" && mechanical_rate == "" && internal_rate == "" && warranty_rate == "" && refinish_rate == "" && glass_rate == "" && frame_rate == "" && aluminum_rate == "" && other_rate == "" {
            isSelected = false
        }
        if isSelected {
            if body_rate != "" {
                if !helper.isNumber(st: body_rate) {
                    self.data.showMessage = "Labor Type 'Body' Sould be Number"
                    self.data.showingPopup = true
                    return
                }
                
                let order_type = LaborTypeModel(type: "Body", hours: helper.stringToDoubleToString(st: body_rate), price: data.laborRates.body_rate)
                self.data.order.labors.append(order_type)
                
            }
            
            if mechanical_rate != "" {
                if !helper.isNumber(st: mechanical_rate) {
                    self.data.showMessage = "Labor Type 'Mechanical' Sould be Number"
                    self.data.showingPopup = true
                    return
                }
                let order_type = LaborTypeModel(type: "Mechanical", hours: helper.stringToDoubleToString(st: mechanical_rate), price: data.laborRates.mechanical_rate)
                self.data.order.labors.append(order_type)
            }
            if internal_rate != "" {
                if !helper.isNumber(st: internal_rate) {
                    self.data.showMessage = "Labor Type 'Internal' Sould be Number"
                    self.data.showingPopup = true
                    return
                }
                let order_type = LaborTypeModel(type: "Internal", hours: helper.stringToDoubleToString(st: internal_rate), price: data.laborRates.internal_rate)
                self.data.order.labors.append(order_type)
            }
            if warranty_rate != "" {
                if !helper.isNumber(st: warranty_rate) {
                    self.data.showMessage = "Labor Type 'Warranty' Sould be Number"
                    self.data.showingPopup = true
                    return
                }
                let order_type = LaborTypeModel(type: "Warranty", hours: helper.stringToDoubleToString(st: warranty_rate), price: data.laborRates.warranty_rate)
                self.data.order.labors.append(order_type)
            }
            if refinish_rate != "" {
                if !helper.isNumber(st: refinish_rate) {
                    self.data.showMessage = "Labor Type 'Refinish' Sould be Number"
                    self.data.showingPopup = true
                    return
                }
                let order_type = LaborTypeModel(type: "Refinish", hours: helper.stringToDoubleToString(st: refinish_rate), price: data.laborRates.refinish_rate)
                self.data.order.labors.append(order_type)
            }
            if glass_rate != "" {
                if !helper.isNumber(st: glass_rate) {
                    self.data.showMessage = "Labor Type 'Glass' Sould be Number"
                    self.data.showingPopup = true
                    return
                }
                let order_type = LaborTypeModel(type: "Glass", hours: helper.stringToDoubleToString(st: glass_rate), price: data.laborRates.glass_rate)
                self.data.order.labors.append(order_type)
            }
            if frame_rate != "" {
                if !helper.isNumber(st: frame_rate) {
                    self.data.showMessage = "Labor Type 'Frame' Sould be Number"
                    self.data.showingPopup = true
                    return
                }
                let order_type = LaborTypeModel(type: "Frame", hours: helper.stringToDoubleToString(st: frame_rate), price: data.laborRates.frame_rate)
                self.data.order.labors.append(order_type)
            }
            if aluminum_rate != "" {
                if !helper.isNumber(st: aluminum_rate) {
                    self.data.showMessage = "Labor Type 'Aluminum' Sould be Number"
                    self.data.showingPopup = true
                    return
                }
                let order_type = LaborTypeModel(type: "Aluminum", hours: helper.stringToDoubleToString(st: aluminum_rate), price: data.laborRates.aluminum_rate)
                self.data.order.labors.append(order_type)
            }
            if other_rate != "" {
                if !helper.isNumber(st: other_rate) {
                    self.data.showMessage = "Labor Type 'Other' Sould be Number"
                    self.data.showingPopup = true
                    return
                }
                
                let order_type = LaborTypeModel(type: "Other", hours: helper.stringToDoubleToString(st: other_rate), price: data.laborRates.other_rate)
                self.data.order.labors.append(order_type)
                
            }
            
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "MMM dd, yyyy"
            let date = Date()
            self.data.order.created_date = formatter1.string(from: date)
            self.data.order.payroll_match = "1"
            
            print("order value is \(self.data.currentPeriod.order_list)")
            //if condition of Recreate feature only
           
            self.data.currentPeriod.order_list.insert(self.data.order, at: 0)
            helper.setVariable(data: self.data)
            self.data.showMessage = "New Repair " + data.order.order_id + " Order added"
            self.data.showingPopup = true
            
            if data.previousContent == 0 {
                self.pageIndex = 0
            } else {
                self.pageIndex = 10
            }
        } else {
            self.data.showMessage = "Please input the required fields"
            self.data.showingPopup = true
            return
        }
    }
    
    func backPage() {
        self.hideKeyboard()
        
        if data.previousContent == 0 {
            self.pageIndex = 0
        } else {
            self.pageIndex = 10
        }
    }

    
    var body: some View {
        VStack{
            HStack{
                HStack{
                    Button(action: {
                        backPage()
                    }) {
                        Image("back").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                    }
                    
                    Spacer().frame(width: 20)
                    Text("Add Repair Order").font(.system(size: 20)).fontWeight(.semibold).foregroundColor(.white)
                    Spacer()
                    
                    Button(action: {
                        saveData()
                    }){
                        Image("check").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                    }
                }.padding()
                
            }.padding(.top, (UIApplication.shared.windows.last?.safeAreaInsets.top)!)
            .background(Color("colorPrimary"))
            
            // body widget
            ScrollView(.vertical) {
                VStack{
                    Text("Only the fields in blue are required")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer().frame(height:20)
                    // body
                    VStack{
                        // first input fields
                        VStack{
                            OrderTextFieldWidget(text_name: self.$data.order.order_id, field_name: "Repair Order # ", is_required: true, is_number: true)
                            OrderTextFieldWidget(text_name: self.$data.order.writer, field_name: "Writer : ", is_required: true, is_number: false)
                            OrderTextFieldWidget(text_name: self.$data.order.customer, field_name: "Customer : ", is_required: false, is_number: false)
                            OrderTextFieldWidget(text_name: self.$data.order.insurance_co, field_name: "Insurance Co : ", is_required: false, is_number: false)
                        }
                        // second fields
                        VStack{
                            HStack{
                                Text("Vechicle")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                Spacer()
                            }.padding(.leading, 20)
                            OrderTextFieldWidget(text_name: self.$data.order.make, field_name: "Make : ", is_required: false, is_number: false)
                            OrderTextFieldWidget(text_name: self.$data.order.model, field_name: "Model : ", is_required: false, is_number: false)
                            OrderTextFieldWidget(text_name: self.$data.order.year, field_name: "Year : ", is_required: false, is_number: true)
                            OrderTextFieldWidget(text_name: self.$data.order.mileage, field_name: "Mileage : ", is_required: false, is_number: true)
                            OrderTextFieldWidget(text_name: self.$data.order.vin, field_name: "VIN : ", is_required: false, is_number: false)
                            OrderTextFieldWidget(text_name: self.$data.order.color, field_name: "Color : ", is_required: false, is_number: false)
                            OrderTextFieldWidget(text_name: self.$data.order.license, field_name: "License : ", is_required: false, is_number: false)
                        }
                        
                        // third input fields
                        VStack{
                            HStack{
                                Text("Tech Notes")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                Spacer()
                            }.padding(.leading, 20)
                            TextEditor(text: self.$data.order.notes)
                                .foregroundColor(.black)
                                .frame(height: 70)
                                .font(.system(size: 13))
                                .lineSpacing(5)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                        .stroke(lineWidth: 1)
                                            .accentColor(.gray)
                                    )
                        }

                        //forth input fields
                        VStack{
                            HStack{
                                Text("Labor Type")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("colorLetter1"))
                                    
                                Spacer()
                            }.padding(.leading, 20)
                            VStack{
                                ForEach(selectedMenus, id: \.self) { item in
                                    if data.laborRates.body_rate != "" && item == "Body" {
                                        MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus, text_name: self.$body_rate,
                                                       field_name: "Body", is_required: false, is_number: true, selected_field: self.$selected_field)
                                    }
                                    if data.laborRates.mechanical_rate  != "" && item == "Mechanical"  {
                                        MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus,text_name: self.$mechanical_rate ,  field_name: "Mechanical", is_required: false, is_number: true, selected_field: self.$selected_field)
                                    }
                                    if data.laborRates.internal_rate != "" && item == "Internal"  {
                                        MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus,text_name: self.$internal_rate,  field_name: "Internal", is_required: false, is_number: true, selected_field: self.$selected_field)
                                    }
                                    if data.laborRates.warranty_rate != "" && item == "Warranty"  {
                                        MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus,text_name: self.$warranty_rate, field_name: "Warranty", is_required: false, is_number: true, selected_field: self.$selected_field)
                                    }
                                    if data.laborRates.refinish_rate  != "" && item == "Refinish"  {
                                        MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus,text_name: self.$refinish_rate , field_name: "Refinish", is_required: false, is_number: true, selected_field: self.$selected_field)
                                    }
                                    if data.laborRates.glass_rate != "" && item == "Glass"  {
                                        MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus,text_name: self.$glass_rate,  field_name: "Glass", is_required: false, is_number: true, selected_field: self.$selected_field)
                                    }
                                    if data.laborRates.frame_rate != "" && item == "Frame"  {
                                        MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus,text_name: self.$frame_rate, field_name: "Frame", is_required: false, is_number: true, selected_field: self.$selected_field)
                                    }
                                    if data.laborRates.aluminum_rate != "" && item == "Aluminum"  {
                                        MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus,text_name: self.$aluminum_rate,  field_name: "Aluminum", is_required: false, is_number: true, selected_field: self.$selected_field)
                                    }
                                    if data.laborRates.other_rate != "" && item == "Other"  {
                                        MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus,text_name: self.$other_rate,  field_name: "Other", is_required: false, is_number: true, selected_field: self.$selected_field)
                                    }
                                }
                            }
                            Spacer().frame(height:10)
                            
                            MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus,text_name: self.$test_value, field_name: "Add Labor", is_required: false, is_number: true, selected_field: self.$selected_field)
                            
                        }
                    }
                    
                }.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                
            }.onAppear(perform: modify)
        }.frame(maxHeight: .infinity)
        .padding(.bottom, keyboardHandler.keyboardHeight)
    }
}
