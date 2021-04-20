//
//  PeriodModel.swift
//  techTime
//
//  Created by 图娜福尔 on 2020/11/2.
//

import Foundation

struct PeriodModel : Codable, Identifiable {
    var id = UUID()
    //date range with start date and end date
    var start_date: String
    var end_date: String
    var cancel_date: String
    var order_list: Array<OrderModel>
}
