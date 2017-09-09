//
//  Legislators.swift
//  Congress
//
//  Created by Li on 11/19/16.
//  Copyright © 2016 Li. All rights reserved.
//

import Foundation

class Legislator{
	var Id:String
	var firstName:String
	var lastName:String
	var gender:String
	var state:String
	var chamber:String
	var birthdate:String
	var fax:String
	var twitterLink:String
	var facebookLink:String
	var websiteLink:String
	var office:String
	var endTerm:String
	var party:String
	var district:String
	
	var attributeSize:Int
	
	init() {
		Id = ""
		firstName = ""
		lastName = ""
		gender = ""
		state = ""
		chamber = ""
		birthdate = ""
		fax = ""
		twitterLink = ""
		facebookLink = ""
		websiteLink = ""
		office = ""
		endTerm = ""
		party = ""
		district = ""
		attributeSize = 14
	}

	func setLegislator(JsonData:[String:AnyObject]){
		Id = JsonData["bioguide_id"] as! String
		firstName = JsonData["first_name"] as! String
		lastName = JsonData["last_name"] as! String
		gender = JsonData["gender"] as! String
		state = JsonData["state"] as! String
		party = JsonData["party"] as! String
		chamber = JsonData["chamber"] as! String
		birthdate = JsonData["birthday"] as! String
		endTerm = JsonData["term_end"] as! String
		
		if(party == "R"){
			party = "Republic"
		}
		else{
			if(party == "D"){
				party = "Democracy"
			}
			else{
				party = "Independent"
			}
		}
		
		if let districttemp = JsonData["district"] as? Int
		{
			district = "District " + String(districttemp)
		}
		else
		{
			district = "N.A"
		}
		
		if let faxtemp = JsonData["fax"] as? String
		{
			if(faxtemp != ""){
				fax = faxtemp
			}
		}
		else
		{
			fax = "N.A"
		}
		
		if let twittertemp = JsonData["twitter_id"] as? String
		{
			if(twittertemp != ""){
				twitterLink = "https://www.twitter.com/" + twittertemp
			}
		}
		else
		{
			twitterLink = "N.A"
		}
		
		if let facebooktemp = JsonData["facebook_id"] as? String
		{
			if(facebooktemp != ""){
				facebookLink = "https://www.facebook.com/" + facebooktemp
			}
		}
		else
		{
			facebookLink = "N.A"
		}
		
		if let websitetemp = JsonData["website"] as? String
		{
			if(websitetemp != ""){
				websiteLink = websitetemp
			}
		}
		else
		{
			websiteLink = "N.A"
		}
		
		if let officetemp = JsonData["office"] as? String
		{
			if(officetemp != ""){
				office = officetemp
			}
		}
		else
		{
			office = "N.A"
		}
	}
	
	func getBirthDateWithFormat(targetDateFormat : String)->String{
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd"
		
		let dateFormatterPrint = DateFormatter()
		dateFormatterPrint.dateFormat = targetDateFormat
		let date: NSDate? = dateFormatterGet.date(from: birthdate) as NSDate?
		return dateFormatterPrint.string(from: date! as Date)
	}
	
	func getTermEndOnWithFormat(targetDateFormat : String)->String{
		let dateFormatterGet = DateFormatter()
		dateFormatterGet.dateFormat = "yyyy-MM-dd"
		
		let dateFormatterPrint = DateFormatter()
		dateFormatterPrint.dateFormat = targetDateFormat
		
		let date: NSDate? = dateFormatterGet.date(from: endTerm) as NSDate?
		return dateFormatterPrint.string(from: date! as Date)
	}
}

func == (lhs: Legislator, rhs: Legislator) -> Bool {
	return lhs.Id == rhs.Id
}

