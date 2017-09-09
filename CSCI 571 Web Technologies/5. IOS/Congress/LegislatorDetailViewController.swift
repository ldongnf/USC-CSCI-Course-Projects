//
//  LegislatorDetailViewController.swift
//  Congress
//
//  Created by Li on 11/20/16.
//  Copyright © 2016 Li. All rights reserved.
//

// Mark - TODO: favourite click move around


import UIKit

class LegislatorDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var LegislatorPhoto: UIImageView!
	
	@IBOutlet weak var DetailTable: UITableView!
	
	var legislator = Legislator()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Legislator Details"
		
		// #remove the arrow
		self.navigationController?.navigationBar.backIndicatorImage = UIImage()
		self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()

		// #remove the space left by arrow
		UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-10, 0), for: UIBarMetrics.default)
		
		// #rightButton
		var rightButtonImage = UIImage()
		if(isFavouriteLegislator(legislator: legislator) == -1){
			rightButtonImage = UIImage(named: "star")!
		}
		else{
			rightButtonImage = UIImage(named: "starfilled")!
		}
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightButtonImage, style: UIBarButtonItemStyle.plain, target:self,action:#selector(setFavoriteLegislator))

		// #load legislator image
		LegislatorPhoto.downloadedFrom(link: "https://theunitedstates.io/images/congress/original/\(legislator.Id).jpg")
		
		// # config the data of tableview
		DetailTable.delegate = self
		DetailTable.dataSource = self
		DetailTable.showsVerticalScrollIndicator = true
		// fix empty lines
		DetailTable.tableFooterView = UIView()
    }
	
	override func viewWillDisappear(_ animated : Bool) {
		super.viewWillDisappear(animated)
		self.tabBarController?.tabBar.isHidden=false
	}
	// MARK: - Table view data source
	
	func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return legislator.attributeSize
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! LegislatorDetailCell
		
		switch (indexPath.row) {
			case 0:
				cell.Head.text = "First Name";
				cell.Content.text = self.legislator.firstName;
				cell.Content.textColor = UIColor.black
			case 1:
				cell.Head.text = "Last Name";
				cell.Content.text = self.legislator.lastName;
				cell.Content.textColor = UIColor.black
			case 2:
				cell.Head.text = "Party";
				cell.Content.text = self.legislator.party;
				cell.Content.textColor = UIColor.black
			case 3:
				cell.Head.text = "State";
				cell.Content.text = UnitedStates[self.legislator.state];
				cell.Content.textColor = UIColor.black
			case 4:
				cell.Head.text = "District";
				cell.Content.text = self.legislator.district;
				cell.Content.textColor = UIColor.black
			case 5:
				cell.Head.text = "Birth Date";
				cell.Content.text = self.legislator.getBirthDateWithFormat(targetDateFormat: "dd MMM yyyy");
				cell.Content.textColor = UIColor.black
			case 6:
				cell.Head.text = "Gender";
				if(self.legislator.gender == "M"){
					cell.Content.text = "Male";
				}
				else{
					cell.Content.text = "Female";
				}
				cell.Content.textColor = UIColor.black
			case 7:
				cell.Head.text = "Chamber";
				cell.Content.text = self.legislator.chamber.capitalized;
				cell.Content.textColor = UIColor.black
			case 8:
				cell.Head.text = "Fax No.";
				cell.Content.text = self.legislator.fax;
				cell.Content.textColor = UIColor.black
			case 9:
				cell.Head.text = "Twitter";
				if(self.legislator.twitterLink == "N.A"){
					cell.Content.text = "N.A";
					cell.Content.textColor = UIColor.black
				}
				else{
					cell.Content.text = "Twitter Link";
					cell.Content.textColor = self.view.tintColor
				}
			case 10:
				cell.Head.text = "Facebook";
				if(self.legislator.facebookLink == "N.A"){
					cell.Content.text = "N.A";
					cell.Content.textColor = UIColor.black
				}
				else{
					cell.Content.text = "Facebook Link";
					cell.Content.textColor = self.view.tintColor
				}
			case 11:
				cell.Head.text = "Website";
				if(self.legislator.websiteLink == "N.A"){
					cell.Content.text = "N.A";
					cell.Content.textColor = UIColor.black
				}
				else{
					cell.Content.text = "Website Link";
					cell.Content.textColor = self.view.tintColor
				}
			
			case 12:
				cell.Head.text = "Office No.";
				cell.Content.text = self.legislator.office;
				cell.Content.textColor = UIColor.black
			case 13:
				cell.Head.text = "Term ends on";
				cell.Content.text =  self.legislator.getTermEndOnWithFormat(targetDateFormat: "dd MMM yyyy")
				cell.Content.textColor = UIColor.black
			default:
				break;
		}
		// Configure the cell...
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if(indexPath.row == 9){
			let url = URL(string: self.legislator.twitterLink)!
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
		if(indexPath.row == 10){
			let url = URL(string: self.legislator.facebookLink)!
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
		if(indexPath.row == 11){
			let url = URL(string: self.legislator.websiteLink)!
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
	
	func isFavouriteLegislator(legislator : Legislator)->Int{
		var symbol = -1
		for (index, item) in FavouriteLegislators.enumerated(){
			if(item == legislator){
				symbol = index
			}
		}
		return symbol
	}
	
	func setFavoriteLegislator(){
		let symbol = isFavouriteLegislator(legislator: legislator)
		
		if(symbol != -1){
			FavouriteLegislators.remove(at: symbol)
			navigationItem.rightBarButtonItem?.image = UIImage(named: "star")!
		}
		else{
			FavouriteLegislators.append(legislator)
			navigationItem.rightBarButtonItem?.image = UIImage(named: "starfilled")!
		}
	}
}
