//
//  CommitteeDetailViewController.swift
//  Congress
//
//  Created by Li on 11/24/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit

class CommitteeDetailViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{

	@IBOutlet weak var CommitteeName: UITextView!
	@IBOutlet weak var DetailTable: UITableView!
	
	var committee = Committee()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Committee Details"
		self.CommitteeName.text = committee.name
		
		// #remove the arrow
		self.navigationController?.navigationBar.backIndicatorImage = UIImage()
		self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
		
		// #remove the space left by arrow
		UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-10, 0), for: UIBarMetrics.default)
		
		// #rightButton
		var rightButtonImage = UIImage()
		if(isFavouriteCommittee(committee: committee) == -1){
			rightButtonImage = UIImage(named: "star")!
		}
		else{
			rightButtonImage = UIImage(named: "starfilled")!
		}
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightButtonImage, style: UIBarButtonItemStyle.plain, target:self,action:#selector(setFavoriteCommittee))
		
		// fix empty lines
		self.DetailTable.tableFooterView = UIView()
		
		self.DetailTable.dataSource = self
		self.DetailTable.delegate = self
		self.DetailTable.reloadData()
    }
	
	override func viewWillDisappear(_ animated : Bool) {
		super.viewWillDisappear(animated)
		self.tabBarController?.tabBar.isHidden=false
	}
	
	override func viewDidLayoutSubviews() {
		self.CommitteeName.setContentOffset(CGPoint.zero, animated: false)
		self.CommitteeName.scrollRangeToVisible(NSMakeRange(0, 0))
	}
	// MARK: - Table view data source
	
	func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return committee.attributeSize
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CommitteesDetailCell", for: indexPath) as! CommitteeDetailCell
		
		switch (indexPath.row) {
		case 0:
			cell.Head.text = "Committee ID";
			cell.Content.text = self.committee.Id;
		case 1:
			cell.Head.text = "Parent Committee";
			cell.Content.text = self.committee.parentCommittee;
		case 2:
			cell.Head.text = "Chamber";
			cell.Content.text = self.committee.chamber;
		case 3:
			cell.Head.text = "Office";
			cell.Content.text = self.committee.office
		case 4:
			cell.Head.text = "Contact";
			cell.Content.text = self.committee.contact
		default:
			break;
		}
		// Configure the cell...
		return cell
	}
	
	func isFavouriteCommittee(committee : Committee)->Int{
		var symbol = -1
		for (index, item) in FavouriteCommittees.enumerated(){
			if(item == committee){
				symbol = index
			}
		}
		return symbol
	}
	
	func setFavoriteCommittee(){
		let symbol = isFavouriteCommittee(committee: committee)
		if(symbol != -1){
			FavouriteCommittees.remove(at: symbol)
			navigationItem.rightBarButtonItem?.image = UIImage(named: "star")!
		}
		else{
			FavouriteCommittees.append(committee)
			navigationItem.rightBarButtonItem?.image = UIImage(named: "starfilled")!
		}
	}

}
