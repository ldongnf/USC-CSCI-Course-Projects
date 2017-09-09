//
//  Committee.swift
//  Congress
//
//  Created by Li on 11/24/16.
//  Copyright © 2016 Li. All rights reserved.
//

import Foundation


class Committee{
	var Id:String
	var name:String
	var parentCommittee:String
	var chamber:String
	var office:String
	var contact:String
	var attributeSize:Int
	
	init() {
		Id = ""
		name = ""
		parentCommittee = ""
		chamber = ""
		office = ""
		contact = ""
		attributeSize = 5
	}
	
	func setCommittee(JsonData:[String:AnyObject]){
		Id = JsonData["committee_id"] as! String
		name = JsonData["name"] as! String
		
		if let parentcommitteetemp = JsonData["parent_committee_id"] as? String
		{
			if(parentcommitteetemp != ""){
				parentCommittee = parentcommitteetemp
			}
		}
		else
		{
			parentCommittee = "N.A"
		}
		chamber = JsonData["chamber"] as! String
		
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
		
		if let contacttemp = JsonData["phone"] as? String
		{
			if(contacttemp != ""){
				contact = contacttemp
			}
		}
		else
		{
			contact = "N.A"
		}
	}
}

func == (lhs: Committee, rhs: Committee) -> Bool {
	return lhs.Id == rhs.Id
}
