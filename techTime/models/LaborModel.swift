//
//  LaborModel.swift
//  techtime
//
//  Created by mac on 5/26/21.
//

import Foundation

struct LaborModel: Codable, Identifiable {
    var id = UUID()
    var type: String
    var rate: String
    var hours: String
}
