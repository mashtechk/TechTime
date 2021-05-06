//  ArchivePayView.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/4.

import SwiftUI

struct ArchivePayView: View {
    
    @Binding var data: VariableModel
    @State private var navigateTo = ""
    @Binding var pageIndex: Int
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var shoulActive = false
    let helper = Helper()
    @State var is_alert = false

    @State private var total_hours = "0.0"
    @State private var total_orders = "0"
    @State private var total_gross = "$ 0.00"
    
    @State private var order_lists : Array<OrderModel> = []
        
    func modify() {
        total_orders = String(data.archievePeriod.order_list.count)
        if data.archievePeriod.order_list.count > 0 {
            var hours = 0.0
            var gross = 0.0
            for order in data.archievePeriod.order_list {
                for labor in order.labors {
                    if labor.hours != "" {
                        hours+=Double(labor.hours) ?? 0.0
                        gross+=Double(labor.hours)! * Double(labor.price)!
                    }
                }
            }
            total_hours = helper.formatHour(h: hours)
            total_gross = helper.formatPrice(p: gross)
        }
        
        order_lists = data.archievePeriod.order_list
        
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
    
    func remove() {
        data.histories = data.histories.filter() {$0.id != data.archievePeriod.id}
        data.archievePeriod = PeriodModel(id: UUID(), start_date: "", end_date: "", cancel_date: "", order_list: [])
        helper.setVariable(data: data)
        self.pageIndex = 0
        data.selected = 0
        
    }
    
    var body: some View {
        VStack{
            //topbar widget
            VStack{
                HStack{
                    Button(action: {
                        self.pageIndex = 0
                        data.selected = 0
                    }){
                        Image("back").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                    }
                    Spacer().frame(width: 20)
                    Text("Archived Pay Period").font(.system(size: 20)).fontWeight(.semibold).foregroundColor(.white)
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            pageIndex = 5
                        }){
                            Text("Email PayRoll")
                                .font(.system(size: 10))
                        }

                        Button(action: {
                            pageIndex = 4
                        }){
                            Text("Order By").font(.system(size: 10))
                        }
                                                
                        Button(action: {
                            self.is_alert = true
                        }){
                            Text("Delete").font(.system(size: 10))
                        }
                        
                    } label: {
                        Button(action: {}){
                            Image("more")
                                .renderingMode(.template)
                                .resizable().frame(width: 25, height: 25)
                                .aspectRatio(contentMode: .fit).foregroundColor(.white)
                            }
                        .padding(.top, 5)
                        }
                }.padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))
                Divider().frame(height: 2).background(Color("colorPrimaryDark"))
                HStack{
                    Spacer()
                    HStack{
                        VStack{
                            Text("START DATE")
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("ColorBlue"))
                            Text(data.archievePeriod.start_date)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }.frame(width: UIScreen.main.bounds.width*0.35)
                    HStack{
                        Text("-")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }.frame(width: UIScreen.main.bounds.width*0.05)
                    HStack{
                        VStack{
                            Text("END DATE")
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                                .foregroundColor(Color("ColorBlue"))
                            Text(data.archievePeriod.cancel_date)
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                    }.frame(width: UIScreen.main.bounds.width*0.35)
                    Spacer()
                }.padding(.bottom, 5)
                
            }.padding(.top, (UIApplication.shared.windows.last?.safeAreaInsets.top)!)
            .background(Color("colorPrimary"))
            
            //body widget
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
                        Text(total_gross).font(.system(size: 15)).foregroundColor(Color("colorGrossPossitive")).fontWeight(.semibold)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }.frame(width: UIScreen.main.bounds.width/3)
                }.padding(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
                HStack{
                    HStack{
                        Text("TOTAL HOURS").font(.system(size: 10)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        Spacer()
                    }.frame(width: UIScreen.main.bounds.width/3)
                    HStack{
                        Text("REPAIR ORDERS").font(.system(size: 10)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                    }.frame(width: UIScreen.main.bounds.width/3)
                    HStack{
                        Spacer()
                        Text("TOTAL GROSS").font(.system(size: 10)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }.frame(width: UIScreen.main.bounds.width/3)
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 3, trailing: 0))
                Divider().frame(height:1).background(Color.gray)
            }
            
            ScrollView(.vertical) {
                ForEach(order_lists) { item in
                    ArchiveOrderSummery(order: item, data: $data, pageIndex: self.$pageIndex, isFromSearch: false)
                }
                
            }
            Spacer()
        }.onAppear(perform: modify).navigationBarHidden(true)
        .animation(.none)
        .alert(isPresented: $is_alert) {
            Alert(
                title: Text(""),
                message: Text("Delete this archived pay period?"),
                primaryButton: .destructive(Text("Delete")) {
                    // delte the current archive data
                    remove()
                },
                secondaryButton: .cancel()
            )
        }
      }
}
