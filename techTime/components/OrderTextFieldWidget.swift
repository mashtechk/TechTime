//  OrderTextFieldWidget.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/4.

import SwiftUI


struct OrderTextFieldWidget: View {
    
    @Binding var text_name: String
    var field_name: String
    var is_required: Bool
    var is_number: Bool
    @State var isActive = false
    
    var body: some View {
        HStack{
            if field_name == "Repair Order # " {
                HStack{
                    Text(field_name).font(.system(size: 15)).fontWeight(.semibold).foregroundColor(is_required ?  Color("colorLetter1") : .gray)
                }.frame(width: (UIScreen.main.bounds.width-40)*3/10+60, alignment: .trailing)
                TextField(text_name, text: $text_name, onEditingChanged: {
                    self.isActive = $0
                }).frame(width: (UIScreen.main.bounds.width-40)*7/10-60)
                .keyboardType(is_number ? .numberPad : .default)
                .autocapitalization(field_name == "Writer : " || field_name == "Customer : " || field_name == "Insurance Co : " || field_name == "Make : " || field_name == "Model : " || field_name == "Color : " ? .words : .allCharacters)
                .overlay(VStack{Divider().frame(height: 1).background(isActive ? Color("colorPrimary") : Color(.gray)).offset(x: 0, y: 10)})
            } else {
                HStack{
                    Text(field_name).font(.system(size: 15)).fontWeight(.semibold).foregroundColor(is_required ?  Color("colorLetter1") : .gray)
                }.frame(width: (UIScreen.main.bounds.width-40)*3.5/10, alignment: .trailing)
                TextField(text_name, text: $text_name, onEditingChanged: {
                    self.isActive = $0
                }).frame(width: (UIScreen.main.bounds.width-40)*6.5/10)
                .keyboardType(is_number ? .numberPad : .default)
                    .autocapitalization(field_name == "Writer : " || field_name == "Customer : " || field_name == "Insurance Co : " || field_name == "Make : " || field_name == "Model : " || field_name == "Color : " ? .words : .allCharacters)
                .overlay(VStack{Divider().frame(height: 1).background(isActive ? Color("colorLetter1") : Color(.gray)).offset(x: 0, y: 10)})
            }
            
        }.padding(.bottom, 8)
    }
}
