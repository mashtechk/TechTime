//  Helper.swift
//  techTime
//  Created by 图娜福尔 on 2020/11/2.

import SwiftUI
import Firebase
import StoreKit
import SwiftyStoreKit

class Helper {

    let productId = "com.techtimeapp.techtime.full"
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
                if data.orderByIndex == "" {
                    data.orderByIndex = "2"
                }
                let formatter1 = DateFormatter()
                formatter1.dateFormat = "MMM dd, yyyy"
                
                //check if difference between two dates is 1
                if data.currentPeriod.cancel_date != "" && daysBetweenDates(startDate:data.currentPeriod.cancel_date, endDate: self.getDate(st: Date())) == true {
                    data.currentPeriod.cancel_date = data.currentPeriod.end_date//self.getDate(st: Date())
                    data.histories.append(data.currentPeriod)
                    data.isEnd = true
                    data.currentPeriod = PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: [])
                }
                return data
            }
        }
        data = VariableModel(selected: 0, showingPopup: false, showMessage: "", orderByIndex: "3", is_alert: false, currentPeriod: PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: []), isEnd: false, archievePeriod: PeriodModel(start_date: "", end_date: "", cancel_date: "", order_list: []), laborRates: LaborRatesModel(body_rate: "", mechanical_rate: "", internal_rate: "", warranty_rate: "", refinish_rate: "", glass_rate: "", frame_rate: "", aluminum_rate: "", other_rate: ""), order: OrderModel(order_id: "", writer: "", customer: "", insurance_co: "", make: "", model: "", year: "", mileage: "", vin: "", color: "", license: "", notes: "", created_date: "", payroll_match: "", labors: []), histories: [], isFull: true, isTrial: true, isInternet: true, currentUser: PersonModel(device_id: "", status: false, is_full: false, start_date: "", user_id: "", email: ""), fromVc: "", selectedHours: "", selectedPrice: "" ,selectedType : "" )
        return data
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
        if components.day == 1 {
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
    
    // get the labor rates
    func getLaborRates() -> LaborRatesModel {
        let laborRate : LaborRatesModel
        if let data = UserDefaults.standard.data(forKey: "labor_rates") {
            if let decoded = try? JSONDecoder().decode(LaborRatesModel.self, from: data) {
                laborRate = decoded
                return laborRate
            }
        }
        laborRate = LaborRatesModel(body_rate: "" , mechanical_rate: "", internal_rate: "", warranty_rate: "", refinish_rate: "", glass_rate: "", frame_rate: "", aluminum_rate: "", other_rate: "")
        return laborRate
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
        let differ_month = delta.month!
        let differ_day = delta.day!
        var return_value = true
        if differ_month>4 && differ_day>0 {
            return_value = false
        }
        return return_value
    }
    
    
    // check the test trial
    func is5minsOver(fromDate: Date) -> Bool {
        let delta = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fromDate, to: Date())
        var return_value = true
        if (delta.year! > 0 || delta.month! > 0 || delta.day! > 21) {
            return_value = false
        }
        return return_value
    }
    
    func formatHour(h: Double) -> String {
        return String(Double(Int(Double(h)*10))/10)
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
            result = String(Double(Int(Double(st)!*100))/100)
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
