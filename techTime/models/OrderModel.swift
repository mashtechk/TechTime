//
//  OrderModel.swift
//  techTime
//
//  Created by 图娜福尔 on 2020/11/2.
//

import Foundation

struct OrderModel : Codable, Identifiable {
    var id = UUID()
    var order_id: String
    var writer: String
    var customer: String
    var insurance_co: String
    var make: String
    var model: String
    var year: String
    var mileage: String
    var vin: String
    var color: String
    var license: String
    var notes: String
    var created_date: String // created date of order
    var payroll_match: String // payroll match default: 1 (gray color), payroll_match: 2 (green), no match: 3 (red color)
    var labors: Array<LaborTypeModel>
    
}

struct LaborTypeModel : Codable, Identifiable {
    var id = UUID()
    var type: String
    var hours: String
    var price: String
}
