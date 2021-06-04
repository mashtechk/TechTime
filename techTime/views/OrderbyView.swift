//  OrderbyView.swift
//  techTime
//  Created by 图娜福尔 on 2020/10/30.

import SwiftUI

struct OrderbyView: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var orderIndex = "1"
    
    let helper = Helper()
    let callback: (String) -> ()
    
    func modify(){
        orderIndex = self.data.orderByIndex
        print(orderIndex)
    }
    
    func saveData() {
        self.data.orderByIndex = orderIndex
        helper.setVariable(data: self.data)
        helper.saveOrderByToFirebase(data: self.data)
        
        self.data.showMessage = "Order By is updated"
        self.data.showingPopup = true
        
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
        orderIndex = id
        callback(id)
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
                    
                    Text("Order By").font(.system(size: 20)).fontWeight(.semibold).foregroundColor(.white)
                    
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
                    Text("Display the pay period to your preference")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
                Spacer().frame(height: 30)
                order_asc
                HStack{
                    Text("Repair order numbers listed least to greatest")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                }.padding(EdgeInsets(top: -5, leading: 40, bottom: 5, trailing: 0))
                order_desc
                HStack{
                    Text("Repair order numbers greatest to least")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                }.padding(EdgeInsets(top: -5, leading: 40, bottom: 5, trailing: 0))
                order_date
                HStack{
                    Text("Repair order dates listed earliest to most current")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Spacer()
                }.padding(EdgeInsets(top: -5, leading: 40, bottom: 5, trailing: 0))
            }.padding()
            
            Spacer()
        }.onAppear(perform: modify).navigationBarHidden(true)
    }
    
    var order_asc: some View{
        RadioButtonField(
            id: "1",
            label: "Ascending",
            isMarked: orderIndex == "1" ? true : false,
            callback: radioGroupCallback
        )
    }
    
    var order_desc: some View{
        RadioButtonField(
            id: "2",
            label: "Descending",
            isMarked: orderIndex == "2" ? true : false,
            callback: radioGroupCallback
        )
    }
    
    var order_date: some View{
        RadioButtonField(
            id: "3",
            label: "Date",
            isMarked: orderIndex == "3" ? true : false,
            callback: radioGroupCallback
        )
    }
}
