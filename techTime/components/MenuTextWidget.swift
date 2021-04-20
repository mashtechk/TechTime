//
//  MenuTextWidget.swift
//  techTime
//
//  Created by 图娜福尔 on 2020/11/4.

import SwiftUI
import SwiftUIX

struct MenuTextWidget: View {
    
    @Binding var menus: Array<String>
    @Binding var selectedMenus: Array<String>
    @Binding var text_name: String
    
    var field_name: String
    var is_required: Bool
    var is_number: Bool
    @Binding var selected_field: String
    
    func addMenu(item: String) {
        if item != "Add Labor" {
            selected_field = item
            if field_name == "Add Labor" {
                selectedMenus.append(item)
                
            } else {
                
                var changed_index = 0
                for (i, element) in selectedMenus.enumerated() {
                    if element == field_name {
                        changed_index = i
                        break
                    }
                }
                selectedMenus[changed_index] = item
            }
            menus = menus.filter(){ $0 != item }
        }
        
        if item == "Add Labor" && field_name != "Add Labor" {
            selectedMenus = selectedMenus.filter(){ $0 != field_name }
            text_name = ""
        }
        
        if field_name != "Add Labor" {
            menus = menus.reversed()
            menus.append(field_name)
            menus = menus.reversed()
        }
    }
    
    var body: some View {
        HStack{
            Menu {
                ForEach (menus, id: \.self) {item in
                    Button {
                        addMenu(item: item)
                    } label: {
                        Text(item)
                    }
                }
                
            } label: {
                HStack{
                    Text(field_name)
                       .foregroundColor(.black)
                       .font(.system(size: 16))
                   Spacer()
                    Image("sort_down")
                       .foregroundColor(.gray)
                       .font(.system(size: 10))
                       .frame(width: 8, height: 10, alignment: .center)
                }.frame(width: 120)
            }
            
            Spacer().frame(width: 30)
            Text("Hours : ").font(.system(size: 15)).fontWeight(.semibold).foregroundColor(text_name != "" ?  Color("colorLetter1") : .gray)
            Spacer()

            CocoaTextField(text_name, text: $text_name)
                .isFirstResponder(selected_field == field_name ? true : false)
                .keyboardType(is_number ? .numbersAndPunctuation : .default)
                .overlay(VStack{Divider().offset(x: 0, y: 10)})
                .onTapGesture {
                    selected_field = field_name
                }
//            TextField(text_name, text: $text_name)
//                .keyboardType(is_number ? .numbersAndPunctuation : .default)
//                .overlay(VStack{Divider().offset(x: 0, y: 10)})
        }.padding(.bottom, 8).frame(height: 40)
    }
}

