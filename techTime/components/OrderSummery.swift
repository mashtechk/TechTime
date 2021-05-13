//  OrderSummery.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/4.

import SwiftUI

struct OrderSummery: View {
    
    var order: OrderModel
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    @State var isFromSearch: Bool
    
    let helper = Helper()
    
    @State private var paymacth = "1"
    @State private var hours = ""
    @State private var prices = ""
    @State private var order_data = OrderModel(id: UUID(), order_id: "", writer: "", customer: "", insurance_co: "", make: "", model: "", year: "", mileage: "", vin: "", color: "", license: "", notes: "", created_date: "", payroll_match: "", labors: [])
    
    func modify() {
        var h = 0.0
        var p = 0.00
        for item in self.order.labors {
            if item.hours != "" {
                h += Double(item.hours)!
                p += Double(item.price)! * Double(item.hours)!
            }
        }
        hours = helper.formatHour(h: h)
        print("hours is \(hours)")
        print("order is \(self.order.labors)")
        prices = helper.formatPrice(p: p)
        
        order_data = order
        paymacth = order_data.payroll_match
    }
    
    func changePayroll() {
        paymacth = String(Int(paymacth)!+1)
        if paymacth == "4" {
            paymacth = "1"
        }
        for (index, item) in data.currentPeriod.order_list.enumerated() {
            if data.currentPeriod.order_list[index].id == order.id {
                data.currentPeriod.order_list[index].payroll_match = paymacth
                print(item)
                break;
            }
        }
        helper.setVariable(data: self.data)
        switch paymacth {
        case "2":
            self.data.showMessage = "Payroll Matches"
            self.data.showingPopup = true
        case "3":
            self.data.showMessage = "Payroll does Not Match"
            self.data.showingPopup = true
        default:
            print(paymacth)
        }
    }
    
    var body: some View {
        
        Button(action: {
            self.data.order = order
            self.pageIndex = 7
        }) {
            VStack{
                mainContent
                
                Divider().frame(height:1).background(Color.gray)
            }
            .animation(.none)
            .onAppear(perform: modify)
            
        }
    }
    
    var mainContent: some View {
        HStack{
            HStack{
                Button(action: {
                    changePayroll()
                }){
                    ZStack{
                        Circle()
                            .strokeBorder(paymacth=="2" ? Color("colorGrossPossitive") : paymacth=="3" ? Color("colorGrossNegative") : Color("colorLetter2"), lineWidth: 2)
                        Text(hours)
                            .font(.system(size: 13))
                            .fontWeight(.semibold)
                            .foregroundColor(paymacth=="2" ? Color("colorGrossPossitive") : paymacth=="3" ? Color("colorGrossNegative") : Color("colorLetter2"))
                        
                    }
                }
                .frame(width:50, height:50)
                VStack(alignment: .leading){
                    Text(order_data.order_id)
                        .font(.system(size: 15))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Spacer().frame(height:5)
                    Text(order_data.writer)
                        .font(.system(size: 12))
                        .foregroundColor(Color("colorLetter2"))
                }
            }
            Spacer()
            VStack(alignment: .trailing){
                Text(order_data.created_date)
                    .font(.system(size: 12))
                    .foregroundColor(Color("colorLetter2"))
                Spacer().frame(height:5)
                Text(prices)
                    .font(.system(size: 13))
                    .foregroundColor(prices.contains("-") ? Color("colorGrossNegative") : Color("colorGrossPossitive"))
                    .fontWeight(.semibold)
            }
        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
    }
}
