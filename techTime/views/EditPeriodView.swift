//  EditPeriodView.swift
//  techTime
//  Created by 图娜福尔 on 2020/10/30.

import SwiftUI

struct EditPeriodView: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    
    @State private var startDate = Date()
    @State private var endDate = Date() + 86400
    
    let formatter1 = DateFormatter()
    let helper = Helper()
    
    func saveData() {
        if self.startDate > Date() {
            self.data.showMessage = "START DATE cannot be later than today's date"
            self.data.showingPopup = true
            return
        }
        let helper = Helper()
        formatter1.dateFormat = "MMM dd, yyyy"
        if self.data.histories.count > 0 && helper.isBiggerDate(oneDate: self.data.histories.last?.cancel_date ?? "", twoDate: formatter1.string(from: self.startDate)) == true {
            self.data.showMessage = "START DATE cannot be relative with the last END DATE"
            self.data.showingPopup = true
            return
        }
        
        self.data.currentPeriod.start_date = formatter1.string(from: self.startDate)
        self.data.currentPeriod.end_date = formatter1.string(from: self.endDate)
        
        //save period data in device
        helper.setVariable(data: self.data)
        self.data.showMessage = "Pay Period is updated"
        self.data.showingPopup = true
        self.pageIndex = 0
    }
    
    func backPage() {
        self.pageIndex = 0
    }
    
    func  modify() {
        
        formatter1.dateFormat = "MMM dd, yyyy"
        startDate = formatter1.date(from: self.data.currentPeriod.start_date) ?? Date()
        endDate = formatter1.date(from: self.data.currentPeriod.end_date) ?? Date()
    }
    
    var body: some View {
            VStack{
                // topbar widget
                HStack{
                    HStack{
                        Button(action: {
                            backPage()
                        }){
                            Image("back").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                        }
                        
                        Spacer().frame(width: 20)
                        
                        Text("Edit Pay Period Dates").font(.system(size: 20)).fontWeight(.semibold).foregroundColor(.white)
                        
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
                VStack{
                    HStack{
                        Spacer()
                        Image("calendar")
                            .resizable()
                            .frame(width: 200, height: 170, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .padding()
                        Spacer()
                    }
                    Spacer().frame(height: 20)
                    Text("Current Pay Period")
                        .font(.system(size: 17))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("ColorBlue"))
                    Spacer().frame(height:10)
                    Text("Select the fields you would like to adjust")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer().frame(height:15)
                    HStack{
                        Text("START DATE")
                            .font(.system(size: 15))
                            .foregroundColor(Color("ColorBlue")).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                        Spacer()
                        Text("END DATE")
                            .font(.system(size: 15))
                            .foregroundColor(Color("ColorBlue"))
                    }.padding(EdgeInsets(top: 10, leading: 37, bottom: 0, trailing: 50))
                    HStack{
                        Text(helper.getDate(st: startDate))
                            .frame(width:120, height: 40)
                            .overlay(DatePicker("", selection: $startDate, displayedComponents: .date)
                                        .frame(width: 120, height:40)
                                        .labelsHidden()
                                        .accentColor(.black)
                                        .border(Color("colorPrimary"), width: 3)
                                        .cornerRadius(4), alignment: .center).padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0))
                        
//                        DatePicker("", selection: $startDate, displayedComponents: .date)
//                            .frame(height:40)
//                            .background(Color.white)
//                            .labelsHidden()
//                            .accentColor(.black)
//                            .font(.system(size: 12))
//                            .border(Color("colorPrimary"), width: 3)
//                            .cornerRadius(4)
//                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 0))
//                            .animation(nil)
                            
                        Spacer()
                        Text(helper.getDate(st: endDate))
                            .frame(width:120, height: 40)
                            .overlay(DatePicker("", selection: $endDate, in: Date()..., displayedComponents: .date)
                                        .frame(width: 120, height:40)
                                        .labelsHidden()
                                        .accentColor(.black)
                                        .border(Color("colorPrimary"), width: 3)
                                        .cornerRadius(4), alignment: .center).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 30))
//                        DatePicker("", selection: $endDate, in: Date()..., displayedComponents: .date)
//                            .frame(height:40)
//                            .background(Color.white)
//                            .labelsHidden()
//                            .accentColor(.black)
//                            .font(.system(size: 12))
//                            .border(Color("colorPrimary"), width: 3)
//                            .cornerRadius(4)
//                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 20))
//                            .animation(nil)
                    }.padding(.top, 0)
                }
                Spacer()
            }.onAppear(perform: modify)
        
    }
}

