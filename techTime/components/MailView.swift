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
        let listString = self.selectedId=="1" ? "Complete List" : "Incorrect List"
        let messageTitle = self.data.currentPeriod.start_date + " - (" + self.title + ")" + listString
        var messsageBody = ""
        for item in data.currentPeriod.order_list {
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
                    messsageBody+="*LABOR PERFORMED*\n"
                    var th = 0.0
                    var tg = 0.0
                    for i in item.labors {
                        messsageBody+=i.type + " Hours : " + i.hours + "Gross : $" + String(Double(i.hours)!*Double(i.price)!) + " \n"
                        th += Double(i.hours)!
                        tg += Double(i.hours)! * Double(i.price)!
                    }
                    messsageBody += "Total Gross : $" + String(tg) + "\n"
                    messsageBody += "Total Hours : $" + String(th) + "\n"
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
                messsageBody+="*LABOR PERFORMED*\n"
                var th = 0.0
                var tg = 0.0
                for i in item.labors {
                    messsageBody+=i.type + " Hours : " + i.hours + " Gross : $" + String(Double(i.hours)!*Double(i.price)!) + " \n"
                    th += Double(i.hours)!
                    tg += Double(i.hours)! * Double(i.price)!
                }
                messsageBody += "Total Gross : $" + String(tg) + "\n"
                messsageBody += "Total Hours : " + String(th) + "\n"
            }
            
        }
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["support@gmail.com"])
        vc.setSubject(messageTitle)
        vc.setMessageBody(messsageBody, isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
