//
//  LaborRatesModel.swift
//  techTime
//
//  Created by 图娜福尔 on 2020/11/2.

import Foundation

struct LaborRatesModel : Codable {
    var body_rate: String
    var mechanical_rate: String
    var internal_rate: String
    var warranty_rate: String
    var refinish_rate: String
    var glass_rate: String
    var frame_rate: String
    var aluminum_rate: String
    var other_rate: String
    
    func isSetLaborRate() -> Bool {
        var isSelected = false
        if body_rate != "" || mechanical_rate != "" || internal_rate != "" || warranty_rate != "" || refinish_rate != "" {
            isSelected = true
        }
        if glass_rate != "" || frame_rate != "" || aluminum_rate != "" || other_rate != "" || isSelected {
            isSelected = true
        }
        return isSelected
    }
    
    func countRates() -> Int {
        return 9
    }
}
