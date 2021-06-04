//  EditOrderView.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/4.

import SwiftUI

struct EditOrderView: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    
    let helper = Helper()
    
    @State var test_value = ""
    @State var selected_field = ""
    
    @State var menus : Array<String> = ["Add Labor"]
    @State var selectedMenus : Array<String> = []
    @StateObject private var keyboardHandler = KeyboardHandler()
    
    func modify() {
        for item in data.order.labors {
            selectedMenus.append(item.type)
            
            for (index, item_labor) in data.laborRates.enumerated() {
                if item.type == item_labor.type {
                    data.laborRates[index].hours = self.calHour(hour: item.hours)
                }
            }
        }
        
        for (index, item) in data.laborRates.enumerated() {
            if item.rate != "" && !selectedMenus.contains(item.type) {
                menus.append(item.type)
                data.laborRates[index].hours = ""
            }
        }
        
        menus = menus.reversed()
        selectedMenus = selectedMenus.reversed()
    }
    
    func calHour(hour: String) -> String {
            let myDouble = Double(hour)
            if myDouble == nil {return ""}
            let doubleStr = String(format: "%.1f", myDouble as! CVarArg)// 3.14
            return doubleStr
        }
    
    func saveData() {
        self.hideKeyboard()
        var isSelected = false
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
            //save rates data in device
            self.data.order.labors = []
            
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
            
            if let row = self.data.currentPeriod.order_list.firstIndex(where: {$0.id == self.data.order.id}) {
                self.data.currentPeriod.order_list[row] = self.data.order
            }
            helper.setVariable(data: self.data)
            helper.savePeriodsToFirebase(data: self.data)
            self.data.showMessage = "Repair " + data.order.order_id + " Order updated"
            self.data.showingPopup = true
            self.pageIndex = 7
        } else {
            self.data.showMessage = "Please input the required fields"
            self.data.showingPopup = true
            return
        }
    }
    
    func backPage() {
        self.hideKeyboard()
        self.pageIndex = 7
    }

    
    var body: some View {
        VStack(spacing: 0) {
            // topbar widget
            HStack{
                HStack{
                    Button(action: {
                        backPage()
                    }){
                        Image("back").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                    }
                    
                    Spacer().frame(width: 20)

                    Text("Edit Repair Order").font(.system(size: 20)).fontWeight(.semibold).foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        saveData()
                    }){
                        Image("check").renderingMode(.template).resizable().frame(width: 20, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                    }
                }.padding()
                
            }.padding(.top, (UIApplication.shared.windows.last?.safeAreaInsets.top)!)
            .background(Color("colorPrimary"))
            
            //body widget
            ScrollView(.vertical) {
                VStack{
                    Text("Only the fields in blue are required")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer().frame(height:20)
                    
                    //body
                    VStack{
                        //first input fields
                        VStack{
                            OrderTextFieldWidget(text_name: self.$data.order.order_id, field_name: "Repair Order # ", is_required: true, is_number: true)
                            OrderTextFieldWidget(text_name: self.$data.order.writer, field_name: "Writer : ", is_required: true, is_number: false)
                            OrderTextFieldWidget(text_name: self.$data.order.customer, field_name: "Customer : ", is_required: false, is_number: false)
                            OrderTextFieldWidget(text_name: self.$data.order.insurance_co, field_name: "Insurance Co : ", is_required: false, is_number: false).frame(height:50)
                        }
                        //second fields
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
                                ForEach(0..<data.laborRates.count) { i in
                                    if data.laborRates[i].rate != "" && selectedMenus.contains(data.laborRates[i].type) {
                                        MenuTextWidget(menus: self.$menus, selectedMenus: self.$selectedMenus, text_name: self.$data.laborRates[i].hours, field_name: data.laborRates[i].type, is_required: false, is_number: true, selected_field: self.$selected_field)
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
