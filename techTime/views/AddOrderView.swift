//  AddOrderView.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/2.

import SwiftUI

struct AddOrderView: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    @Environment(\.presentationMode) var presentation

    let helper = Helper()
    
    @State var test_value = ""
    @State var selected_field = ""
    
    @State var menus : Array<String> = ["Add Labor"]
    @State var selectedMenus : Array<String> = []
    @StateObject private var keyboardHandler = KeyboardHandler()
    
    func modify() {
        for (index, item) in data.laborRates.enumerated() {
            if item.rate != "" {
                menus.append(item.type)
                data.laborRates[index].hours = ""
            }
        }
        menus = menus.reversed()
    }
    
    func saveData() {
        
        self.hideKeyboard()
        var isSelected = false
        if data.fromVc == "Recreate" {
            if self.data.order.labors.count > 0 {
                self.data.order.labors.removeAll()
            }
        }
        
        if data.order.order_id == "" || data.order.writer == "" {
            self.data.showMessage = "Please input the required fields"
            self.data.showingPopup = true
            return
        }
        
        if data.order.order_id.contains(".") {
            self.data.showMessage = "Please input the number in Repair Order"
            self.data.showingPopup = true
            return
        }
        
        for item in data.laborRates {
            if selectedMenus.contains(item.type) && item.hours == "" {
                self.data.showMessage = "Labor Type '" + item.type + "' Is Missing Hours Performed"
                self.data.showingPopup = true
                return
            }
        }
        
        for item in data.laborRates {
            if item.hours != "" {
                isSelected = true
                break
            }
        }
        
        if isSelected {
            for item in data.laborRates {
                if item.hours != "" {
                    if !helper.isNumber(st: item.hours) {
                        self.data.showMessage = "Labor Type '" + item.type + "' Sould be Number"
                        self.data.showingPopup = true
                        return
                    }
                    
                    let order_type = LaborTypeModel(type: item.type, hours: helper.stringToDoubleToString(st: item.hours), price: item.rate)
                    self.data.order.labors.append(order_type)
                }
            }
                        
            let formatter1 = DateFormatter()
            formatter1.dateFormat = "MMM dd, yyyy"
            let date = Date()
            self.data.order.created_date = formatter1.string(from: date)
            self.data.order.payroll_match = "1"
            
            print("order value is \(self.data.currentPeriod.order_list)")
            //if condition of Recreate feature only
            
            if data.fromVc == "Recreate" {
                let order_temp: OrderModel = OrderModel(id: UUID(), order_id: self.data.order.order_id, writer: self.data.order.writer, customer: self.data.order.customer, insurance_co: self.data.order.insurance_co, make: self.data.order.make, model: self.data.order.model, year: self.data.order.year, mileage: self.data.order.mileage, vin: self.data.order.vin, color: self.data.order.color, license: self.data.order.license, notes: self.data.order.notes, created_date: self.data.order.created_date, payroll_match: self.data.order.payroll_match, labors: self.data.order.labors)
                self.data.order = order_temp
            }
            
            self.data.currentPeriod.order_list.insert(self.data.order, at: 0)
            helper.setVariable(data: self.data)
            helper.savePeriodsToFirebase(data: self.data)
            self.data.showMessage = "New Repair " + data.order.order_id + " Order added"
            self.data.showingPopup = true
            
            self.data.previousContent = 0
            self.pageIndex = 0
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
        VStack(spacing: 0) {
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
                                .frame(height: 65)
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
                                    ForEach(0..<data.laborRates.count) { i in
                                        if data.laborRates[i].rate != "" && item == data.laborRates[i].type {
                                            MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus, text_name: self.$data.laborRates[i].hours,
                                                       field_name: data.laborRates[i].type, is_required: false, is_number: true, selected_field: self.$selected_field)
                                        }
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
        .padding(.bottom, keyboardHandler.keyboardHeight + 10)
    }
}
