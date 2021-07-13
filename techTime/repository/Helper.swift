//  Helper.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/2.

import SwiftUI
import Firebase
import StoreKit
import SwiftyStoreKit

class Helper {

    let subOneMonth = "com.techtimeapp.techtime.sub"
    let subSixMonths = "com.techtimeapp.techtime.six"
    let subOneYear = "com.techtimeapp.techtime.year"
    let sharedKey = "bdf62b8709c34cd4b27bc1f5cf1a6d5b"
    
    //save the data
    func setVariable(data: VariableModel) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "data")
        }
    }

    //Get the data
    func getVariable() -> VariableModel {
        var data: VariableModel
        if let da = UserDefaults.standard.data(forKey: "data") {
            if let decoded = try? JSONDecoder().decode(VariableModel.self, from: da) {
                data = decoded
                data.showMessage = ""
                data.showingPopup = false
                data.selected = 0
                data.is_alert = false
                data.previousContent = 0
                data.previousPageOfOrderView = 0
                data.is_selected_endDate = false
                if data.orderByIndex == "" {
                    data.orderByIndex = "2"
                }
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "MMM dd, yyyy"
                
                let dd = formatter1.date(from: data.startDate)!
                
                if data.currentUser.email == "55gwsp2y7j@privaterelay.appleid.com" {
                    data.isTrial = is1DayOver(fromDate: dd)
                } else {
                    data.isTrial = is3MonthOver(fromDate: dd)
                }
                
                if !data.isPaid && !data.isTrial {
                    data.isFull = false
                    
                    if data.currentPeriod.cancel_date != "" {
                        data.currentPeriod.cancel_date = self.getDate(st: Date().dayBefore)
                        data.histories.append(data.currentPeriod)
                        data.isEnd = true
                        data.currentPeriod = PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: [])
                    }
                } else {
                    //check if difference between two dates is 1
                    if data.currentPeriod.cancel_date != "" && daysBetweenDates(startDate:data.currentPeriod.cancel_date, endDate: self.getDate(st: Date())) == true {
                        data.currentPeriod.cancel_date = data.currentPeriod.end_date//self.getDate(st: Date())
                        data.histories.append(data.currentPeriod)
                        data.isEnd = true
                        data.currentPeriod = PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: [])
                    }
                }
                
                return data
            }
        }
        
        var labors : Array<LaborModel>
        labors = []
        labors.append(LaborModel(type: "Body", rate: "", hours: ""))
        labors.append(LaborModel(type: "Mechanical", rate: "", hours: ""))
        labors.append(LaborModel(type: "Internal", rate: "", hours: ""))
        labors.append(LaborModel(type: "Warranty", rate: "", hours: ""))
        labors.append(LaborModel(type: "Refinish", rate: "", hours: ""))
        labors.append(LaborModel(type: "Glass", rate: "", hours: ""))
        labors.append(LaborModel(type: "Frame", rate: "", hours: ""))
        labors.append(LaborModel(type: "Aluminum", rate: "", hours: ""))
        
        data = VariableModel(selected: 0, showingPopup: false, showMessage: "", orderByIndex: "3", is_alert: false, currentPeriod: PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: []), isEnd: false, archievePeriod: PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: []), laborRates: labors, order: OrderModel(order_id: "", writer: "", customer: "", insurance_co: "", make: "", model: "", year: "", mileage: "", vin: "", color: "", license: "", notes: "", created_date: "", payroll_match: "", labors: []), histories: [], isFull: true, isTrial: true, isPaid: false, isInternet: true, currentUser: PersonModel(device_id: "", status: false, is_full: false, start_date: "", user_id: "", email: ""), fromVc: "", selectedHours: "", selectedPrice: "" ,selectedType : "", startDate: "", previousContent: 0, previousPageOfOrderView: 0, is_selected_endDate: false)
        return data
    }
    
    func saveOrderByToFirebase(data: VariableModel) {
        if data.currentUser.email != "" {
            let document = Firestore.firestore().collection("users").document(data.currentUser.email)
            document.updateData(["order_by":data.orderByIndex])
        }
    }
    
    func saveLaborRatesToFirebase(data: VariableModel) {
        if data.currentUser.email != "" {
            let document = Firestore.firestore().collection("users").document(data.currentUser.email)
            var array: [Any] = []
            
            for labor in data.laborRates {
                array.append(["type":labor.type, "rate":labor.rate])
            }
            
            document.updateData(["laborRates": array])
        }
    }
    
    func savePeriodsToFirebase(data: VariableModel) {
        if data.currentUser.email != "" {
            let document = Firestore.firestore().collection("users").document(data.currentUser.email)
            
            var periodArray: [Any] = []
            
            for period in data.histories {
                var orderArray: [Any] = []
                for order in period.order_list {
                    var laborArray: [Any] = []
                    for labor in order.labors {
                        laborArray.append(["type":labor.type, "hours":labor.hours, "price":labor.price])
                    }
                    
                    orderArray.append(["order_id":order.order_id, "writer":order.writer, "customer":order.customer, "insurance_co":order.insurance_co, "make":order.make, "model":order.model, "year":order.year, "mileage":order.mileage, "vin":order.vin, "color":order.color, "license":order.license, "notes":order.notes, "created_date":order.created_date, "payroll_match":order.payroll_match, "labors":laborArray])
                }
                
                periodArray.append(["start_date":period.start_date, "end_date":period.end_date, "cancel_date":period.cancel_date, "order_list":orderArray])
            }
            
            if data.currentPeriod != nil {
                var orderArray: [Any] = []
                for order in data.currentPeriod.order_list {
                    var laborArray: [Any] = []
                    for labor in order.labors {
                        laborArray.append(["type":labor.type, "hours":labor.hours, "price":labor.price])
                    }
                    
                    orderArray.append(["order_id":order.order_id, "writer":order.writer, "customer":order.customer, "insurance_co":order.insurance_co, "make":order.make, "model":order.model, "year":order.year, "mileage":order.mileage, "vin":order.vin, "color":order.color, "license":order.license, "notes":order.notes, "created_date":order.created_date, "payroll_match":order.payroll_match, "labors":laborArray])
                }
                
                periodArray.append(["start_date":data.currentPeriod.start_date, "end_date":data.currentPeriod.end_date, "cancel_date":data.currentPeriod.cancel_date, "order_list":orderArray])
            }
            
            document.updateData(["period": periodArray])
        }
    }
    
    //MARK:- Get difference between two dates
    func daysBetweenDates(startDate: String, endDate: String) -> Bool
    {
        let calendar = NSCalendar.current
        if startDate == "" {
            return false
        }
        if endDate == "" {
            return true
        }
        let formatter1 = DateFormatter()
        
        formatter1.dateFormat = "MMM dd,yyyy"
        guard let date1 = formatter1.date(from: startDate) else {
            return false
        }
        guard let date2 = formatter1.date(from: endDate) else {
            return false
        }
        
        let components = calendar.dateComponents([.day], from: date1 as Date, to: date2 as Date)
        print("days component is \(components)")
        if components.day! > 0 {
            return true
        } else {
            return false
        }
        return false
        
    }
    
    //get the current period information
    func getCurrentPeriod() -> PeriodModel {
        let currentPeriod : PeriodModel
        if let data = UserDefaults.standard.data(forKey: "current_period") {
            if let decoded = try? JSONDecoder().decode(PeriodModel.self, from: data) {
                currentPeriod = decoded
                return currentPeriod
            }
        }
        currentPeriod = PeriodModel(start_date: "", end_date: "",cancel_date : "" ,order_list: [])
        return currentPeriod
    }
    
    // save teh pay period history
    func setHistoryPeriod(history_data: Array<PeriodModel>) {
        if let encoded = try? JSONEncoder().encode(history_data) {
            UserDefaults.standard.set(encoded, forKey: "histories")
        }
    }
    
    // get the histories period information
    func getHistoryPeriod() -> Array<PeriodModel> {
        let historyPeriod : Array<PeriodModel>
        if let data = UserDefaults.standard.data(forKey: "histories") {
            if let decoded = try? JSONDecoder().decode(Array<PeriodModel>.self, from: data) {
                historyPeriod = decoded
                return historyPeriod
            }
        }
        historyPeriod = []
        return historyPeriod
    }
    
    //compare to date
    func isBiggerDate(oneDate: String, twoDate: String) -> Bool {
        if oneDate == "" {
            return false
        }
        if twoDate == "" {
            return true
        }
        let formatter1 = DateFormatter()
        
        formatter1.dateFormat = "MMM dd,yyyy"
        guard let date1 = formatter1.date(from: oneDate) else {
            return false
        }
        guard let date2 = formatter1.date(from: twoDate) else {
            return false
        }

        formatter1.dateFormat = "yyyy"
        let year1 = formatter1.string(from: date1)
        formatter1.dateFormat = "MM"
        let month1 = formatter1.string(from: date1)
        formatter1.dateFormat = "dd"
        let day1 = formatter1.string(from: date1)
        
        formatter1.dateFormat = "yyyy"
        let year2 = formatter1.string(from: date2)
        formatter1.dateFormat = "MM"
        let month2 = formatter1.string(from: date2)
        formatter1.dateFormat = "dd"
        let day2 = formatter1.string(from: date2)
        
        if Int(year1)! > Int(year2)! {
            return true
        }
        if Int(year1)! < Int(year2)! {
            return false
        }
        if Int(month1)! > Int(month2)! {
            return true
        }
        if Int(month1)! < Int(month2)! {
            return false
        }
        if Int(day1)! > Int(day2)! {
            return true
        }
        
        if Int(day1)! == Int(day2)! {
            return true
        }
                
        return false
    }
    
    
    //compare to date
    func isBigger(oneDate: String, twoDate: String) -> Bool {
        if oneDate == "" {
            return false
        }
        if twoDate == "" {
            return true
        }
        let formatter1 = DateFormatter()
        
        formatter1.dateFormat = "MMM dd,yyyy"
        guard let date1 = formatter1.date(from: oneDate) else {
            return false
        }
        guard let date2 = formatter1.date(from: twoDate) else {
            return false
        }

        formatter1.dateFormat = "yyyy"
        let year1 = formatter1.string(from: date1)
        formatter1.dateFormat = "MM"
        let month1 = formatter1.string(from: date1)
        formatter1.dateFormat = "dd"
        let day1 = formatter1.string(from: date1)
        
        formatter1.dateFormat = "yyyy"
        let year2 = formatter1.string(from: date2)
        formatter1.dateFormat = "MM"
        let month2 = formatter1.string(from: date2)
        formatter1.dateFormat = "dd"
        let day2 = formatter1.string(from: date2)
        
        if Int(year1)! > Int(year2)! {
            return true
        }
        if Int(year1)! < Int(year2)! {
            return false
        }
        if Int(month1)! > Int(month2)! {
            return true
        }
        if Int(month1)! < Int(month2)! {
            return false
        }
        if Int(day1)! > Int(day2)! {
            return true
        }
        
        if Int(day1)! == Int(day2)! {
            return false
        }
                
        return false
    }
    
    // set default userdefault
    func setDeaultData() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    // get the is full version or free version
    func is3MonthOver(fromDate: Date) -> Bool {
        let delta = Calendar.current.dateComponents([.year, .month, .day], from: fromDate, to: Date())
        var return_value = true
        
        if (delta.year! > 0 || delta.month! > 0) {
            return_value = false
        }
        
        return return_value
    }
    
    func is1DayOver(fromDate: Date) -> Bool {
        return false
    }
    
    func formatHour(h: Double) -> String {
        return String(Double(Int(Double(h)*100))/100)
    }
    
    func formatHours(h: Double) -> String {
        return String(format: "%.1f", h)
    }
    
    func formatPrice(p: Double) -> String {
        var result = ""
        let d = String(Double(Int(Double(p)*100))/100)
        if d == "" {
            return ""
        }
        
        let dd = d.split{$0 == "."}.map(String.init)
        let dd_reversed = dd[0].reversed()
        for (index, name) in dd_reversed.enumerated() {
            if name == "-" {
                break
            }
            result = result + String(name)
            if index%3 == 2 {
                result = result + ","
            }
        }
        if result.last == "," {
            result = String(result.dropLast())
        }
        result = String(result.reversed())
        if dd.count > 1 {
            result = result + "." + dd[1]
            if dd[1].count < 2 {
                result = result + "0"
            }
        } else {
            result = result + ".00"
        }
        if d.contains("-") {
            result = "-$" + result
        } else {
            result = "$" + result
        }

        return result
    }
    
    func commaString(st: String) -> String {
        var result = ""
        if st != ""{
            let st_reversed = st.reversed()
            for (index, name) in st_reversed.enumerated() {
                result = result + String(name)
                if index%3 == 2 {
                    result = result + ","
                }
            }
        }
        if result.last == "," {
            result = String(result.dropLast())
        }
        return String(result.reversed())
    }
    
    func replace(myString: String, _ index: Int, _ newChar: Character) -> String {
        var chars = Array(myString)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
    
    func  isNumber(st: String) -> Bool {
        var result = false
        if st.count > 0 {
            let num = Double(st)
            if num != nil {
                result = true
            }
        }
        return result
    }
    
    func stringToDoubleToString(st: String) -> String {
        if st == "" {
            return ""
        }
        var result = "0"
        if st.count > 0 {
            let val = CGFloat(Double(st)!)
            result = String(format: "%.2f", val)
            let dd = result.split{$0 == "."}.map(String.init)
            if dd.count > 1 && dd[1].count==1 {
                result = result + "0"
            }
        }
        return result
    }
    
    func getDate(st: Date) -> String {
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MMM dd, yyyy"
        return formatter1.string(from: st)
    }
}
