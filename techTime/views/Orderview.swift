//  Orderview.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/4.

import SwiftUI

struct Orderview: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int

    let helper = Helper()
    @State var is_alert = false
    @State private var th = ""
    @State private var tg = ""
    
    func backPage() {
        if data.previousPageOfOrderView == 0 {
            self.pageIndex = 0
        } else {
            self.pageIndex = 2
        }
    }
    
    func calHour(hour: String) -> String {
            let myDouble = Double(hour)
            if myDouble == nil {return ""}
            let doubleStr = String(format: "%.1f", myDouble as! CVarArg)// 3.14
            return doubleStr
        }
    
    func calGross(hour: String, price: String) -> String {
        let e  = (Double(hour) ?? 0) * (Double(price) ?? 0)
        return helper.formatPrice(p: e)
    }
    
    func modify() {
        var h = 0.0
        var g = 0.00
        for item in self.data.order.labors {
            h+=Double(item.hours)!
            g+=Double(item.hours)! * Double(item.price)!
        }
        
        th = helper.formatHour(h: h)
        tg = helper.formatPrice(p: g)
    }
    
    func deleteOrder() {
        data.currentPeriod.order_list = self.data.currentPeriod.order_list.filter() {
            $0.id != self.data.order.id
        }
        data.order = OrderModel(order_id: "", writer: "", customer: "", insurance_co: "", make: "", model: "", year: "", mileage: "", vin: "", color: "", license: "", notes: "", created_date: "", payroll_match: "", labors: [])
        self.pageIndex = 0
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
                    Text("Repair Order").font(.system(size: 20)).fontWeight(.semibold).foregroundColor(.white)

                    Spacer()
                    
                    !data.isEnd ? Button(action: {
                        self.pageIndex = 8
                    }){
                        Image("pen").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                    } : nil
                    !data.isEnd ? Button(action: {
                        self.is_alert = true
                    }){
                        Image("remove").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                        } : nil
                }.padding()
            }.padding(.top, (UIApplication.shared.windows.last?.safeAreaInsets.top)!)
            .background(Color("colorPrimary"))
            
            // body widget
            ScrollView(.vertical) {
                VStack(alignment: .leading){
                    Text(self.data.order.order_id)
                        .foregroundColor(Color("ColorBlue"))
                        .fontWeight(.semibold)
                        .font(.system(size: 22))
                        .padding(EdgeInsets(top: 30, leading: 15, bottom: 0, trailing: 0))
                    // base order information
                    VStack{
                        ItemView(field_name: "Writer : ", field_value: self.data.order.writer)
                        ItemView(field_name: "Date : ", field_value: self.data.order.created_date)
                        ItemView(field_name: "Customer : ", field_value: self.data.order.customer)
                        ItemView(field_name: "Insurance Co : ", field_value: self.data.order.insurance_co)
                    }.padding(EdgeInsets(top: 5, leading: 30, bottom: 5, trailing: 15))
                    // vehicle order information view
                    Text("Vehicle")
                        .foregroundColor(Color("ColorBlue"))
                        .fontWeight(.semibold)
                        .font(.system(size: 20))
                        .padding(.leading, 15)
                    VStack{
                        ItemView(field_name: "Make : ", field_value: self.data.order.make)
                        ItemView(field_name: "Model : ", field_value: self.data.order.model)
                        ItemView(field_name: "Year : ", field_value: self.data.order.year)
                        ItemView(field_name: "Mileage : ", field_value: helper.commaString(st: self.data.order.mileage))
                        ItemView(field_name: "VIN : ", field_value: self.data.order.vin)
                        ItemView(field_name: "Color : ", field_value: self.data.order.color)
                        ItemView(field_name: "License : ", field_value: self.data.order.license)
                    }.padding(EdgeInsets(top: 5, leading: 30, bottom: 5, trailing: 15))
                    
                    // tech notes
                    Text("Tech Notes")
                        .foregroundColor(Color("ColorBlue"))
                        .fontWeight(.semibold)
                        .font(.system(size: 16))
                        .padding(.leading, 15)
                    VStack{
                        Text(self.data.order.notes)
                            .foregroundColor(.gray)
                            .font(.system(size: 13)).italic()
                    }.padding(EdgeInsets(top: 5, leading: 30, bottom: 5, trailing: 15))
                    //labors data order information
                    VStack{
                        HStack{
                            HStack{
                                Text("Labor Type")
                                    .foregroundColor(Color("ColorBlue"))
                                    .fontWeight(.semibold)
                                    .font(.system(size: 16))
                                    .padding(.leading, 15)
                                Spacer()
                            }.frame(width: UIScreen.main.bounds.width/2)
                            HStack{
                                Text("Hours")
                                    .foregroundColor(Color("ColorBlue"))
                                    .fontWeight(.semibold)
                                    .font(.system(size: 13)).padding(.trailing,40)
                            }.frame(width: UIScreen.main.bounds.width/4)
                            HStack{
                                Spacer()
                                Text("Gross")
                                    .foregroundColor(Color("ColorBlue"))
                                    .fontWeight(.semibold)
                                    .font(.system(size: 13))
                                    .padding(.trailing,10)
                            }.frame(width: UIScreen.main.bounds.width/4)
                        }
                        Spacer().frame(height:10)
                        
                        VStack{
                            ForEach(data.order.labors) { item in
                            
                            HStack{
                                HStack{
                                    Text(item.type)
                                        .foregroundColor(.gray)
                                        .font(.system(size: 13))
                                        .padding(.leading, 25)
                                    Spacer()
                                }.frame(width: UIScreen.main.bounds.width/2)
                                HStack{
                                    Text(calHour(hour: item.hours))
                                        .foregroundColor(.gray)
                                        .font(.system(size: 13)).padding(.trailing, 40)
                                }.frame(width: UIScreen.main.bounds.width/4)
                                HStack{
                                    Spacer()
                                    Text(calGross(hour: item.hours, price: item.price))
                                        .foregroundColor(Color(calGross(hour: item.hours, price: item.price).contains("-") ? "colorGrossNegative" : "colorGrossPossitive"))
                                        .font(.system(size: 13))
                                        .fontWeight(.semibold)
                                        .padding(.trailing, 5)
                                }.frame(width: UIScreen.main.bounds.width/4)
                            }.padding(.trailing, 10)
                            
                             }
                        }
                    }
                    Divider().frame(height:1).background(Color.gray)
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 5, trailing: 15))
                    HStack{
                        Text("Total Hours")
                            .foregroundColor(Color("ColorBlue"))
                            .fontWeight(.semibold)
                            .font(.system(size: 16))
                        Spacer()
                        Text(th)
                            .foregroundColor(Color("colorLetter2"))
                            .fontWeight(.semibold)
                            .font(.system(size: 15))
                    }.padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
                    HStack{
                        Text("Total Gross")
                            .foregroundColor(Color("ColorBlue"))
                            .fontWeight(.semibold)
                            .font(.system(size: 16))
                        Spacer()
                        Text(tg)
                            .foregroundColor(Color(tg.contains("-") ? "colorGrossNegative" : "colorGrossPossitive"))
                            .fontWeight(.semibold)
                            .font(.system(size: 15))
                    }.padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
                }
                
            }
        }.onAppear(perform: modify)
        .alert(isPresented: $is_alert) {
            Alert(
                title: Text(""),
                message: Text("Delete this repair order?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteOrder()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct ItemView: View {
    
    var field_name : String
    var field_value : String
    
    
    var body: some View {
        HStack{
            Text(field_name)
                .foregroundColor(.gray)
                .fontWeight(.semibold)
                .font(.system(size: 13))
            
            Spacer()
            
            Text(field_value)
                .foregroundColor(.gray)
                .font(.system(size: 12))
            
        }.padding(.bottom, 1)
    }
    
    
}
