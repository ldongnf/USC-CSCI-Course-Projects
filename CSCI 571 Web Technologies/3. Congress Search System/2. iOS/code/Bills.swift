//
//  Bills.swift
//  Congress
//
//  Created by Li on 11/22/16.
//  Copyright © 2016 Li. All rights reserved.
//

import Foundation

class Bill{
	var Id:String
	var billtype:String
	var sponsor:String
	var lastAction:String
	var pdfLink:String
	var chamber:String
	var status:String
	var officialTitle:String
	var lastVote:String
	var introducedOn:String
	var attributeSize:Int
	
	init() {
		Id = ""
		billtype = ""
		sponsor = ""
		lastAction = ""
		pdfLink = ""
		chamber = ""
		status = ""
		officialTitle = ""
		lastVote = ""
		introducedOn = ""
		attributeSize = 9
	}

	func setBill(JsonData:[String:AnyObject]){
		Id = JsonData["bill_id"] as! String
		billtype = JsonData["bill_type"] as! String
		
		//sponsor
		let title = JsonData["sponsor"]?["title"] as! String
		let lastname = JsonData["sponsor"]?["last_name"] as! String
		let firstname = JsonData["sponsor"]?["first_name"] as! String
		sponsor = title+" "+lastname+" "+firstname

		//Introducedon
		let introduceddate = JsonData["introduced_on"] as! String
		let index = introduceddate.index(introduceddate.startIndex, offsetBy: 10)
		introducedOn = introduceddate.substring(to: index)
		
		//last action
		if let actiondatetemp = JsonData["last_action_at"] as? String
		{
			if(actiondatetemp != ""){
				let index = actiondatetemp.index(actiondatetemp.startIndex, offsetBy: 10)
				lastAction = actiondatetemp.substring(to: index)
			}
		}
		else
		{
			lastAction = "N.A"
		}
		
		//pdf
		let lastversion = JsonData["last_version"] as! NSDictionary
		let urls = lastversion["urls"] as! NSDictionary
		pdfLink = urls["pdf"] as! String
		
		chamber = JsonData["chamber"] as! String
		
		let history = JsonData["history"] as! NSDictionary
		if(history["active"] as! Bool){
			status = "Active"
		}
		else{
			status = "New"
		}
		
		officialTitle = JsonData["official_title"] as! String
		
		if let lastVotetemp = JsonData["last_vote_at"] as? String
		{
			if(lastVotetemp != ""){
				let index = lastVotetemp.index(lastVotetemp.startIndex, offsetBy: 10)
				lastVote = lastVotetemp.substring(to: index)
			}
		}
		else
		{
			lastVote = "N.A"
		}
	}
	
	func getLastActionWithFormat(targetDateFormat : String)->String{
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd"
		
		let dateFormatterPrint = DateFormatter()
		dateFormatterPrint.dateFormat = targetDateFormat
		
		let date: NSDate? = dateFormatterGet.date(from: lastAction) as NSDate?
		return dateFormatterPrint.string(from: date! as Date)
	}
	
	func getIntroducedOnWithFormat(targetDateFormat : String)->String{
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd"
		
		let dateFormatterPrint = DateFormatter()
		dateFormatterPrint.dateFormat = targetDateFormat
		
		let date: NSDate? = dateFormatterGet.date(from: introducedOn) as NSDate?
		return dateFormatterPrint.string(from: date! as Date)
	}
	
	func getLastVoteWithFormat(targetDateFormat : String)->String{
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd"
		
		let dateFormatterPrint = DateFormatter()
		dateFormatterPrint.dateFormat = targetDateFormat
		
		let date: NSDate? = dateFormatterGet.date(from: lastVote) as NSDate?
		return dateFormatterPrint.string(from: date! as Date)
	}
}

func == (lhs: Bill, rhs: Bill) -> Bool {
	return lhs.Id == rhs.Id
}
