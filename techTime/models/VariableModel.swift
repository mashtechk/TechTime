//
//  VariableModel.swift
//  techTime
//
//  Created by 图娜福尔 on 2020/11/4.
//

import Foundation

struct VariableModel : Codable {
    var selected: Int // in the main page (pay and archive tab managment variable)
//    var pageIndex: Int // this is the page lists
    var showingPopup: Bool // toast show message varibale
    var showMessage: String // toast message
    var orderByIndex: String // orderby index
    var is_alert: Bool // show alert
    var currentPeriod: PeriodModel
    var isEnd: Bool // ended the current period
    var archievePeriod: PeriodModel // history period info variable for archive management
    var laborRates: LaborRatesModel
    var order: OrderModel
    var histories: Array<PeriodModel>
    var isFull: Bool // if free version or full version function check variable
    var isTrial: Bool // for 3 months is true, after that is false
    var isPaid: Bool
    var isInternet: Bool // check the internet connection
    var currentUser: PersonModel // user info
    var fromVc: String
    var selectedHours : String
    var selectedPrice : String
    var selectedType: String
    var startDate: String
    var previousContent: Int // 0 = PayContent, 1 = ArchiveContent
    var previousPageOfOrderView: Int // 0 = Others, 1 = SearchView
    var is_selected_endDate: Bool
}
