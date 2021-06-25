//  ArchiveContent.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/4.

import SwiftUI

struct ArchiveContent: View {
    
    @State private var willMoveToNextScreen = false
    @Binding var data: VariableModel
    @Binding var pageIndex: Int
    @State private var shouldShowActive = true
    @State var selection: Int? = nil
    let helper = Helper()

    func modify() {
        data = helper.getVariable();
    }
    
    var body: some View{
        VStack{
            if data.histories.count == 0 {
                emptyBody
            } else {
                dataListBody
            }
        }
    }
    
    var emptyBody: some View{
        return VStack{
            Spacer()
            VStack{
                HStack{
                    Spacer()
                    Image("archive")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width*0.45, height: UIScreen.main.bounds.width*0.5, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        .padding()
                    Spacer()
                }
                Spacer().frame(height: 25)
                HStack{
                    Spacer()
                    Text("ARCHIVE").font(.system(size: 17)).fontWeight(.bold).foregroundColor(Color("ColorBlue"))
                    Spacer()
                }
                Spacer().frame(height: 15)
                HStack{
                    Spacer()
                    Text("Past pay periods will be stored here").font(.system(size: 12)).foregroundColor(Color("colorLetter2"))
                    Spacer()
                }
            }
            Spacer()
        }
    }
    
    func calHours(item: PeriodModel) -> String {
        var h = 0.0
        for list in item.order_list {
            for labor in list.labors {
                h+=Double(labor.hours)!
            }
        }
        
        return helper.formatHours(h: h)
    }
    
    func calGross(item: PeriodModel) -> String {
        var g = 0.0
        for list in item.order_list {
            for labor in list.labors {
                g+=Double(labor.hours)! * Double(labor.price)!
            }
        }
        return helper.formatPrice(p: g)
        
    }
    
    var dataListBody: some View {
        return VStack{
            ScrollView{
                VStack(spacing:0){
                    ForEach(0..<data.histories.count, id: \.self) {i in
                        Button(action:  {
                            self.shouldShowActive = true
                            data.archievePeriod = data.histories[i]
                            data.previousContent = 1
                            self.pageIndex = 9
                        })
                        {
                            VStack{
                                VStack{
                                    Spacer().frame(height:3)
                                    
                                    HStack{
                                        Text(data.histories[i].start_date)
                                        .font(.system(size: 14))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("ColorBlue"))
                                        .frame(width:UIScreen.main.bounds.width*0.35)

                                        Text("-")
                                        .font(.system(size: 15))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("ColorBlue"))
                                        .frame(width: UIScreen.main.bounds.width*0.05)

                                        Text(data.histories[i].cancel_date ?? "\(helper.getDate(st: Date()))" )
                                        .font(.system(size: 14))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("ColorBlue"))
                                        .frame(width: UIScreen.main.bounds.width*0.35)
                                    }
                                    
                                    Divider().frame(height:2).background(Color("colorDivider"))
                                        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                    
                                    HStack{
                                        Text(calHours(item: data.histories[i]))
                                        .font(.system(size: 13))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("colorLetter2"))
                                        .frame(width: UIScreen.main.bounds.width*0.35, alignment: .leading)
                                        .padding(.leading, 7)

                                        Text(String(data.histories[i].order_list.count))
                                        .font(.system(size: 13))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("colorLetter2"))
                                        .frame(width: UIScreen.main.bounds.width*0.15)

                                        Text(calGross(item: data.histories[i]))
                                        .font(.system(size: 13))
                                        .fontWeight(.semibold)
                                        .foregroundColor(calGross(item: data.histories[i]).contains("-") ? Color("colorGrossNegative") : Color("colorGrossPossitive"))
                                        .frame(width: UIScreen.main.bounds.width*0.35, alignment: .trailing)
                                        .padding(.trailing, 7)
                                    }
                                }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                
                                Divider().frame(height:1).background(Color("colorDivider"))
                            }
                        }.background(i%2==0 ? Color.white : Color("colorDate"))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                }
            }.navigationBarHidden(true)
    //        .onAppear(perform: modify)
        }
    }
}
