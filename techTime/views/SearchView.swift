//  SearchView.swift
//  techTime
//  Created by 图娜福尔 on 2020/10/30.

import SwiftUI

struct SearchView: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    
    let search_txt_0 = "Search Repair Order"
    let search_txt_1 = "Search Writer"
    let search_txt_2 = "Search Date Range"
    let search_txt_3 = "Search Writer with Date Range"
    
    @State private var search_txt = ""
    @State private var search_place_txt = "Search Repair Order"
    @State private var search_index = 0 //search index 0: by orderid 1: writer, 2: date range, 3: date range and writer
    @State private var is_search = false
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    @State var keyboard_open = false
    
    @State private var search_result : Array<OrderModel> = []
    @State private var search_result_current : Array<OrderModel> = []
    
    @State private var bottomPadding: CGFloat = 0
    
    let helper = Helper()
    let formatter1 = DateFormatter()
    
    func backPage() {
        self.hideKeyboard()
        self.pageIndex = 0
        data.previousPageOfOrderView = 0
    }
    
    func searchData() {
        keyboard_open = false
        self.hideKeyboard()
        if search_txt == "" && search_index != 2 {
            is_search = false
            data.showMessage = "Please input field"
            data.showingPopup = true
            
        } else {
            formatter1.dateFormat = "MMM dd, yyyy"
            search_result = []
            search_result_current = []
            is_search = true
            let d1 = formatter1.string(from: startDate)
            startDate = formatter1.date(from: d1)!
            let d2 = formatter1.string(from: endDate)
            endDate = formatter1.date(from: d2)!
            for j in data.currentPeriod.order_list {
                switch search_index {
                case 1:
                    if j.writer.lowercased() == search_txt.lowercased() {
                        search_result_current.append(j)
                    }
                case 2:
                    if formatter1.date(from: j.created_date)! >= startDate && formatter1.date(from: j.created_date)! <= endDate {
                        search_result_current.append(j)
                    }
                case 3:
                    if formatter1.date(from: j.created_date)! >= startDate && formatter1.date(from: j.created_date)! <= endDate && j.writer == search_txt {
                        search_result_current.append(j)
                    }
                default:
                    if j.order_id == search_txt {
                        search_result_current.append(j)
                    }
                }
            }
            
            for i in data.histories {
                for j in i.order_list {
                    switch search_index {
                    case 1:
                        if j.writer.lowercased() == search_txt.lowercased() {
                            search_result.append(j)
                        }
                    case 2:
                        if formatter1.date(from: j.created_date)! >= startDate && formatter1.date(from: j.created_date)! <= endDate {
                            search_result.append(j)
                        }
                    case 3:
                        if formatter1.date(from: j.created_date)! >= startDate && formatter1.date(from: j.created_date)! <= endDate && j.writer == search_txt {
                            search_result.append(j)
                        }
                    default:
                        if j.order_id == search_txt {
                            search_result.append(j)
                        }
                    }
                }
            }
        }
    }
    
    func calTotalHours() -> String {
        var th = 0.0
        
        for i in search_result_current {
            for j in i.labors {
                th += Double(j.hours)!
            }
        }
        
        for i in search_result {
            for j in i.labors {
                th += Double(j.hours)!
            }
        }
        
        return helper.formatHour(h: th)
    }
    
    func calTotalGross() -> String {
        var tg = 0.0
        for i in search_result {
            for j in i.labors {
                tg += Double(j.hours)! * Double(j.price)!
            }
        }
        for i in search_result_current {
            for j in i.labors {
                tg += Double(j.hours)! * Double(j.price)!
            }
        }
        return helper.formatPrice(p: tg)
    }
    
    func calAverHours() -> String {
        var th = 0.0
        for i in search_result {
            for j in i.labors {
                th += Double(j.hours)!
            }
        }
        
        for i in search_result_current {
            for j in i.labors {
                th += Double(j.hours)!
            }
        }
        if search_result.count + search_result_current.count != 0 {
            th = th/Double(search_result.count + search_result_current.count)
        }
        return helper.formatHour(h: th)
        
    }
    
    func calAverGross() -> String {
        var tg = 0.0
        for i in search_result {
            for j in i.labors {
                tg += Double(j.hours)! * Double(j.price)!
            }
        }
        for i in search_result_current {
            for j in i.labors {
                tg += Double(j.hours)! * Double(j.price)!
            }
        }
        if search_result.count + search_result_current.count != 0 {
            tg = tg/Double(search_result.count + search_result_current.count)
        }
        return helper.formatPrice(p: tg)
    }
    
    var body: some View {
        VStack {
            //topbar widget
            topContent
            
            //Search input widget
            searchContent
                        
            if(is_search) {
                mainContent
            } else {
                Spacer()
                if !keyboard_open {
                    emptyContent
                }
            }
            Spacer()

            if !keyboard_open {
                totalViweContent
            }
            
        }
        .onAppear(perform: {
            data.previousPageOfOrderView = 1
        })
    }
    
    var topContent: some View {
        VStack{
            HStack{
                Button(action: {
                    backPage()
                }){
                    Image("back").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
                }

                Spacer().frame(width: 20)

                Text("Search").font(.system(size: 20)).fontWeight(.semibold).foregroundColor(.white)

                Spacer()
                
                Menu {
                    search_index != 0 ? Button(action: {
                        search_result = []
                        search_result_current = []
                        keyboard_open = false
                        search_index = 0
                        search_place_txt = search_txt_0
                        is_search = false
                        search_txt = ""
                        self.hideKeyboard()
                    }){
                        Text(search_txt_0)
                    } : nil
                    search_index == 0 ? Text(search_txt_0) : nil
                    search_index != 1 ? Button(action: {
                        search_result = []
                        search_result_current = []
                        keyboard_open = false
                        search_index = 1
                        search_place_txt = search_txt_1
                        is_search = false
                        search_txt = ""
                        self.hideKeyboard()
                    }){
                        Text(search_txt_1)
                    } : nil
                    search_index == 1 ? Text(search_txt_1) : nil
                    search_index != 2 ? Button(action: {
                        search_result = []
                        search_result_current = []
                        keyboard_open = false
                        search_index = 2
                        search_place_txt = search_txt_2
                        is_search = false
                        search_txt = ""
                        self.hideKeyboard()
                    }){
                        Text(search_txt_2)
                    } : nil
                    search_index == 2 ? Text(search_txt_2) : nil
                    search_index != 3 ? Button(action: {
                        search_result = []
                        search_result_current = []
                        keyboard_open = false
                        search_index = 3
                        search_place_txt = search_txt_3
                        is_search = false
                        search_txt = ""
                        self.hideKeyboard()
                    }){
                        Text(search_txt_3)
                    } : nil
                    search_index == 3 ? Text(search_txt_3) : nil
                } label: {
                    Button(action: {}){
                        Image("more")
                            .renderingMode(.template)
                            .resizable().frame(width: 25, height: 25)
                            .aspectRatio(contentMode: .fit).foregroundColor(.white)
                        }
                    .padding(.top, 5)
                }
            }.padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        }.padding(.top, (UIApplication.shared.windows.last?.safeAreaInsets.top)!)
        .background(Color("colorPrimary"))
    }
    
    var searchContent: some View {
        VStack {
            HStack(spacing: 0) {
                if search_index == 2 {
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .frame(height:40)
                        .background(Color.white)
                        .labelsHidden()
                        .accentColor(.black)
                        .font(.system(size: 11))
                        .border(Color("colorPrimary"), width: 3)
                        .cornerRadius(4)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                        .frame(minWidth: 0)
                        .compositingGroup()
                    
                    Spacer()
                    
                    DatePicker("", selection: $endDate, displayedComponents: .date)
                        .frame(height:40)
                        .labelsHidden()
                        .font(.system(size: 11))
                        .accentColor(.black)
                        .border(Color("colorPrimary"), width: 3)
                        .cornerRadius(4)
                        .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3))
                        .frame(minWidth: 0)
                        .compositingGroup()
                } else {
                    HStack{
                        HStack{}.frame(width:7)
                        TextField(search_place_txt, text: $search_txt)
                            .frame(width: UIScreen.main.bounds.width * 0.7 , height: 40)
                            .keyboardType(search_index==0 ? .decimalPad : .default)
                    }.overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color("colorPrimary"), lineWidth: 3)
                    ).padding(EdgeInsets(top: 5, leading: 0, bottom: 3, trailing: 0))
                    .onTapGesture {
                        keyboard_open = true
                        print("----- this is teh gapgesture -----")
                    }
                }
                
                Button(action:{
                    searchData()
                }) {
                    Image("search").renderingMode(.template).resizable().frame(width: 20, height: 20).aspectRatio(contentMode: .fit).foregroundColor(.white)
                }
                .frame(width: 45, height: 40)
                .background(LinearGradient(gradient: Gradient(colors: [Color("colorButtonLight"), Color("colorPrimaryDark")]), startPoint: .top, endPoint: .bottom))
                .cornerRadius(20).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 5))
            }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            
            if search_index == 3 {
                HStack(spacing: 0) {
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .frame(height:40)
                        .background(Color.white)
                        .labelsHidden()
                        .accentColor(.black)
                        .font(.system(size: 11))
                        .border(Color("colorPrimary"), width: 3)
                        .cornerRadius(4)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 3))
                        .frame(minWidth: 0)
                        .compositingGroup()
                    
                    Spacer()
                    
                    DatePicker("", selection: $endDate, displayedComponents: .date)
                        .frame(height:40)
                        .labelsHidden()
                        .font(.system(size: 11))
                        .accentColor(.black)
                        .border(Color("colorPrimary"), width: 3)
                        .cornerRadius(4)
                        .padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 3))
                        .frame(minWidth: 0)
                        .compositingGroup()
                    
                    Spacer().frame(width: 60)
                }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            }
            
            if is_search && search_result.count == 0 && search_result_current.count == 0 {
                HStack{
                    Text("No Match Found")
                        .foregroundColor(.red)
                        .font(.system(size: 13))
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            }
            
            if search_index != 0 {
                VStack{
                    Divider().frame(height: 3).background(Color("colorDivider"))
                    
                    Text("AVERAGE REPAIR ORDER")
                        .font(.system(size: 10))
                        .foregroundColor(Color("ColorBlue"))
                        .fontWeight(.semibold)
                    
                    HStack{
                        Text(calAverHours())
                            .font(.system(size: 13))
                            .foregroundColor(Color("colorLetter2"))
                            .fontWeight(.semibold)
                        Spacer()
                        Text(calAverGross())
                            .font(.system(size: 13))
                            .foregroundColor(search_result.count + search_result_current.count == 0 ? Color("colorLetter2") : calAverGross().contains("-") ? Color("colorGrossNegative") : Color("colorGrossPossitive"))
                            .fontWeight(.semibold)
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    
                    HStack{
                        Text("AVG. HOURS")
                            .font(.system(size: 11))
                            .foregroundColor(Color("ColorBlue"))
                            .fontWeight(.semibold)
                            
                        Spacer()
                        Text("AVG. GROSS")
                            .font(.system(size: 11))
                            .foregroundColor(Color("ColorBlue"))
                            .fontWeight(.semibold)
                    }.padding(EdgeInsets(top: 1, leading: 10, bottom: 0, trailing: 10))
                }
            }
            
            //divider line
            Divider().frame(height: 2).background(Color("colorDivider"))
        }
    }
    
    var totalViweContent: some View{
        VStack{
            //divider line
            Divider().frame(height: 2).background(Color("colorDivider"))
            
            HStack{
                HStack{
                    Text(calTotalHours()).font(.system(size: 13)).foregroundColor(Color("colorLetter2")).fontWeight(.semibold)
                        .padding(EdgeInsets(top: -3, leading: 10, bottom: 0, trailing: 0))
                    Spacer()
                }.frame(width: UIScreen.main.bounds.width/3)
                HStack{
                    Text(String(search_result.count + search_result_current.count)).font(.system(size: 13)).foregroundColor(Color("colorLetter2")).fontWeight(.semibold).padding(EdgeInsets(top: -3, leading: 5, bottom: 0, trailing: 0))
                }.frame(width: UIScreen.main.bounds.width/3)
                HStack{
                    Spacer()
                    Text(calTotalGross()).font(.system(size: 13))
                        .foregroundColor(search_result.count + search_result_current.count == 0 ? Color("colorLetter2") : calTotalGross().contains("-") ?  Color("colorGrossNegative") :  Color("colorGrossPossitive"))
                        .fontWeight(.semibold)
                        .padding(EdgeInsets(top: -3, leading: 0, bottom: 0, trailing: 10))
                }.frame(width: UIScreen.main.bounds.width/3)
            }
            
            HStack{
                HStack{
                    Text("TOTAL HOURS").font(.system(size: 11)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 0))
                    Spacer()
                }.frame(width: UIScreen.main.bounds.width/3)
                HStack{
                    Text("REPAIR ORDERS").font(.system(size: 11)).foregroundColor(Color("ColorBlue")).fontWeight(.bold).padding(EdgeInsets(top: 5, leading: 5, bottom: 0, trailing: 0))
                }.frame(width: UIScreen.main.bounds.width/3)
                HStack{
                    Spacer()
                    Text("TOTAL GROSS").font(.system(size: 11)).foregroundColor(Color("ColorBlue")).fontWeight(.bold)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 10))
                }.frame(width: UIScreen.main.bounds.width/3)
            }
            
            Divider().frame(height:1).background(Color("colorDivider"))
        }
    }
    
    var mainContent: some View {
        VStack{
            ScrollView(.vertical) {
                if search_result.count > 0 || search_result_current.count > 0 {
                    ForEach(search_result_current) { item in
                        OrderSummery(order: item, data: $data, pageIndex: self.$pageIndex, isFromSearch: true)
                    }
                    
                    ForEach(search_result) { item in
                        ArchiveOrderSummery(order: item, data: $data, pageIndex: self.$pageIndex, isFromSearch: true)
                    }
                }
            }
        }
    }
        
    var emptyContent: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                Image("search_empty").renderingMode(.template).resizable().frame(width: 200, height: 200).aspectRatio(contentMode: .fit).foregroundColor(Color("colorPrimary"))
                Spacer()
            }
            Spacer()
        }
    }
}


struct SearchTextFieldWidget: View {
    
    @Binding var search_txt: String
    @Binding var search_index: Int
    var search_place_txt: String
    
    var body: some View {
        HStack{
            HStack{}.frame(width:7)
            TextField(search_place_txt, text: $search_txt)
                .frame(height: 40)
                .keyboardType(search_index==0 ? .decimalPad : .default)
        }.overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color("colorPrimary"), lineWidth: 3)
        ).padding(EdgeInsets(top: 5, leading: 0, bottom: 3, trailing: 0))
    }
}

//extension UIResponder {
//    static var currentFirstResponder: UIResponder? {
//        _currentFirstResponder = nil
//        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
//        return _currentFirstResponder
//    }
//
//    private static weak var _currentFirstResponder: UIResponder?
//
//    @objc private func findFirstResponder(_ sender: Any) {
//        UIResponder._currentFirstResponder = self
//    }
//
//    var globalFrame: CGRect? {
//        guard let view = self as? UIView else { return nil }
//        return view.superview?.convert(view.frame, to: nil)
//    }
//}
