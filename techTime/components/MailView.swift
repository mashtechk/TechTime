//
//  MailView.swift
//  techTime
//
//  Created by 图娜福尔 on 2020/11/5.
//

import Foundation
import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    @Binding var data: VariableModel
    @Binding var selectedId: String // complete list or incorrect list option 1: correct, 2: incorrect list
    @Binding var title: String
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        var order_lists : Array<OrderModel> = []
        
        if data.previousPageOfOrderView == 0 {
            order_lists = data.currentPeriod.order_list
        } else {
            order_lists = data.archievePeriod.order_list
        }
        
        let listString = self.selectedId=="1" ? "Complete List" : "Incorrect List"
        var messageTitle = self.data.currentPeriod.start_date + " - " + self.data.currentPeriod.cancel_date + " (" + self.title + ") " + listString
        
        if data.previousPageOfOrderView == 2 {
            messageTitle = self.data.archievePeriod.start_date + " - " + self.data.archievePeriod.cancel_date + " (" + self.title + ") " + listString
        }
        
        var messsageBody = ""
        
        if data.orderByIndex == "1" {
            order_lists = order_lists.sorted { Int($0.order_id)! < Int($1.order_id)! }
        }
        if data.orderByIndex == "2" {
            order_lists = order_lists.sorted { Int($0.order_id)! > Int($1.order_id)! }
        }
        if data.orderByIndex == "3" {
            order_lists = order_lists.sorted{ $0.created_date > $1.created_date }
            order_lists = order_lists.reversed()
        }
        
        for item in order_lists {
            if selectedId=="2" {
                if item.payroll_match=="3" {
                    messsageBody+="Repair Order : " + item.order_id + "\n"
                    messsageBody+="Writer : " + item.writer + "\n"
                    messsageBody+="Date : " + item.created_date + "\n"
                    messsageBody+="Customer : " + item.customer + "\n"
                    messsageBody+="Insurance Co : " + item.insurance_co + "\n"
                    messsageBody+="*VEHICLE*\n"
                    messsageBody+="Make : " + item.make + "\n"
                    messsageBody+="Model : " + item.model + "\n"
                    messsageBody+="Year : " + item.year + "\n"
                    messsageBody+="Mileage : " + item.mileage + "\n"
                    messsageBody+="VIN : " + item.vin + "\n"
                    messsageBody+="Color : " + item.color + "\n"
                    messsageBody+="License : " + item.license + "\n"
                    messsageBody+="Tech Notes : " + item.notes + "\n"
                    messsageBody+="*LABOR PERFORMED*\n"
                    var th = 0.0
                    var tg = 0.0
                    for i in item.labors {
                        messsageBody+=i.type + " Hours : " + removeZeroFromEnd(num: i.hours) + " Gross : $" + String(format: "%.2f", Double(i.hours)!*Double(i.price)!) + " \n"
                        th += Double(i.hours)!
                        tg += Double(i.hours)! * Double(i.price)!
                    }
                    messsageBody += "Total Gross : $" + String(format: "%.2f", tg) + "\n"
                    messsageBody += "Total Hours : " + removeZeroFromEnd(num: String(th)) + "\n\n\n"
                }
            } else {
                messsageBody+="Repair Order : " + item.order_id + "\n"
                messsageBody+="Writer : " + item.writer + "\n"
                messsageBody+="Date : " + item.created_date + "\n"
                messsageBody+="Customer : " + item.customer + "\n"
                messsageBody+="Insurance Co : " + item.insurance_co + "\n"
                messsageBody+="*VEHICLE*\n"
                messsageBody+="Make : " + item.make + "\n"
                messsageBody+="Model : " + item.model + "\n"
                messsageBody+="Year : " + item.year + "\n"
                messsageBody+="Mileage : " + item.mileage + "\n"
                messsageBody+="VIN : " + item.vin + "\n"
                messsageBody+="Color : " + item.color + "\n"
                messsageBody+="License : " + item.license + "\n"
                messsageBody+="Tech Notes : " + item.notes + "\n"
                messsageBody+="*LABOR PERFORMED*\n"
                var th = 0.0
                var tg = 0.0
                for i in item.labors {
                    messsageBody+=i.type + " Hours : " + removeZeroFromEnd(num: i.hours) + " Gross : $" + String(format: "%.2f", Double(i.hours)!*Double(i.price)!) + " \n"
                    th += Double(i.hours)!
                    tg += Double(i.hours)! * Double(i.price)!
                }
                messsageBody += "Total Gross : $" + String(format: "%.2f", tg) + "\n"
                messsageBody += "Total Hours : " + removeZeroFromEnd(num: String(th)) + "\n\n\n"
            }
            
        }
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["support@gmail.com"])
        vc.setSubject(messageTitle)
        vc.setMessageBody(messsageBody, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func removeZeroFromEnd(num: String) -> String {
        if num == "" {
            return ""
        }
        
        let val = Double(num)
        var tempVar = String(format: "%g", val!)
        
        if !tempVar.contains(".") {
            tempVar = tempVar + ".0"
        }
        
        return tempVar
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
