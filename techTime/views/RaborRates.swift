//  RaborRates.swift
//  techTime
//  Created by 图娜福尔 on 2020/10/30.

import SwiftUI

struct LaborRates: View {
    
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let helper = Helper()
    @State var newLabor: LaborModel = LaborModel(type: "", rate: "", hours: "")
    @State var laborRates: Array<LaborModel> = []
    
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
                        Image("check").renderingMode(.template).resizable().frame(width: 25, height: 25).aspectRatio(contentMode: .fit).foregroundColor(.white)
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
                    Spacer().frame(height:20)
                    
                    HStack {
                        Text("Simply enter the amount you earn per flagged hour. When you are all done, tap the check mark to save.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                            
                        Spacer()
                    }
                    
                    Spacer().frame(height:20)

                    //body
                    VStack{
                        ForEach(0..<self.laborRates.count, id: \.self) { i in
                            TextFieldWidget(text_name: self.$laborRates[i].rate, field_name: self.laborRates[i].type)
                        }
                        
                        if newLabor.hours != "" {
                            NewTextFieldWidget(text_name: $newLabor.rate, field_name: $newLabor.type)
                        }
                    }.padding(.leading, 10)
                    
                    HStack {
                        Button(action: {
                            addLabor()
                        }){
                            Image("add_labor")
                                .resizable()
                                .frame(width: 50, height: 50, alignment: .center)
                        }
                        
                        Spacer()
                    }.padding(EdgeInsets(top: -5, leading: 10, bottom: 0, trailing: 0))
                }.padding(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15))
            }.navigationBarHidden(true)
            Spacer()
        }.onAppear(perform: modify)
    }
    
    func  modify() {
        laborRates = data.laborRates
    }
    
    func addLabor() {
        if newLabor.hours == "" {
            newLabor = LaborModel(type: "", rate: "", hours: "0")
        } else {
            if newLabor.type != "" {
                newLabor.hours = ""
                self.laborRates.append(newLabor)
                newLabor = LaborModel(type: "", rate: "", hours: "0")
            }
        }
    }
    
    func saveData() {
        self.hideKeyboard()
        
        var isSelected = false
                        
        for item in data.laborRates {
            if item.rate != "" {
                isSelected = true
                break
            }
        }
        
        if !isSelected && newLabor.type != "" && newLabor.rate != "" {
            isSelected = true
        }
        
        if isSelected {
            if newLabor.type != "" {
                newLabor.hours = ""
                self.laborRates.append(newLabor)
            }
            
            for (index, item) in self.laborRates.enumerated() {
                self.laborRates[index].rate = helper.stringToDoubleToString(st: item.rate)
            }
            
            self.data.laborRates = self.laborRates
            helper.setVariable(data: self.data)
            self.data.showMessage = "Labor rates saved"
            self.data.showingPopup = true
            self.pageIndex = 0
        } else {
            self.data.showMessage = "Please set your labor rates"
            self.data.showingPopup = true
        }
    }
    
    func backPage() {
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
            Text("Rate  $ ").font(.system(size: 15)).fontWeight(text_name == "" ? .none : .semibold).foregroundColor(text_name == "" ? .gray : Color("ColorBlue"))
            TextField(text_name, text: $text_name, onEditingChanged: {
                self.isActive = $0
                })
                .frame(width:UIScreen.main.bounds.width * 0.25)
                .keyboardType(.decimalPad)
                .overlay(VStack{Divider().frame(height: 1).background(isActive ? Color("ColorBlue") : Color(.gray)).offset(x: 0, y: 10)})
            
        }.padding(.bottom, 8)
    }
}

struct NewTextFieldWidget: View {
    
    @Binding var text_name: String
    @State var isActive = false
    @Binding var field_name: String

    var body: some View {
        HStack{
            TextField(field_name, text: $field_name, onEditingChanged: {
                self.isActive = $0
                })
                .frame(width:UIScreen.main.bounds.width * 0.35)
                .font(.system(size: 15))
                .overlay(VStack{Divider().frame(height: 1).background(Color(.black)).offset(x: 0, y: 10)})
            Spacer()
            Text("Rate  $ ").font(.system(size: 15)).fontWeight(text_name == "" ? .none : .semibold).foregroundColor(text_name == "" ? .gray : Color("ColorBlue"))
            TextField(text_name, text: $text_name, onEditingChanged: {
                self.isActive = $0
                })
                .frame(width:UIScreen.main.bounds.width * 0.25)
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
