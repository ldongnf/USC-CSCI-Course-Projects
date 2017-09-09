//
//  BillDetailViewController.swift
//  Congress
//
//  Created by Li on 11/23/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit

class BillDetailViewController: UIViewController,UITableViewDelegate, UITableViewDataSource  {

	@IBOutlet weak var BillOfficialTitle: UITextView!
	@IBOutlet weak var DetailTable: UITableView!
	
	var bill = Bill()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.title = "Bill Details"
		self.BillOfficialTitle.text = bill.officialTitle
		
		// #remove the arrow
		self.navigationController?.navigationBar.backIndicatorImage = UIImage()
		self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
		
		// #remove the space left by arrow
		UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-10, 0), for: UIBarMetrics.default)
		
		// #rightButton
		var rightButtonImage = UIImage()
		if(isFavouriteBill(bill: bill) == -1){
			rightButtonImage = UIImage(named: "star")!
		}
		else{
			rightButtonImage = UIImage(named: "starfilled")!
		}
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightButtonImage, style: UIBarButtonItemStyle.plain, target:self,action:#selector(setFavoriteBill))
		
		// fix empty lines
		self.DetailTable.tableFooterView = UIView()
		
		self.DetailTable.dataSource = self
		self.DetailTable.delegate = self
		self.DetailTable.reloadData()
    }
	
	override func viewDidLayoutSubviews() {
		self.BillOfficialTitle.setContentOffset(CGPoint.zero, animated: false)
		self.BillOfficialTitle.scrollRangeToVisible(NSMakeRange(0, 0))
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
		return bill.attributeSize
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BillsDetailCell", for: indexPath) as! BillDetailCell
		
		switch (indexPath.row) {
		case 0:
			cell.Head.text = "Bill ID";
			cell.Content.text = self.bill.Id;
			cell.Content.textColor = UIColor.black
		case 1:
			cell.Head.text = "Bill Type";
			cell.Content.text = self.bill.billtype;
			cell.Content.textColor = UIColor.black
		case 2:
			cell.Head.text = "Sponsor";
			cell.Content.text = self.bill.sponsor;
			cell.Content.textColor = UIColor.black
		case 3:
			cell.Head.text = "Introduced";
			if self.bill.introducedOn != "N.A"{
				cell.Content.text = self.bill.getIntroducedOnWithFormat(targetDateFormat: "dd MMM yyyy");
			}
			else{
				cell.Content.text = self.bill.introducedOn
			}
			cell.Content.textColor = UIColor.black
		case 4:
			cell.Head.text = "Last Action";
			
			if self.bill.lastAction != "N.A"{
				cell.Content.text = self.bill.getLastActionWithFormat(targetDateFormat: "dd MMM yyyy");
			}
			else{
				cell.Content.text = self.bill.lastAction
			}
			cell.Content.textColor = UIColor.black
		case 5:
			cell.Head.text = "PDF";
			cell.Content.text = "PDF Link"
			cell.Content.textColor = self.view.tintColor
		case 6:
			cell.Head.text = "Chamber";
			cell.Content.text = self.bill.chamber.capitalized;
			cell.Content.textColor = UIColor.black
		case 7:
			cell.Head.text = "Last Vote";
			if self.bill.lastVote != "N.A"{
				cell.Content.text = self.bill.getLastVoteWithFormat(targetDateFormat: "dd MMM yyyy");
			}
			else{
				cell.Content.text = self.bill.lastVote
			}
			cell.Content.textColor = UIColor.black
		case 8:
			cell.Head.text = "Status";
			cell.Content.text = self.bill.status
			cell.Content.textColor = UIColor.black
		default:
			break;
		}
		// Configure the cell...
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if(indexPath.row == 5){
			let url = URL(string: self.bill.pdfLink)!
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}
	}
	
	func isFavouriteBill(bill : Bill)->Int{
		var symbol = -1
		for (index, item) in FavouriteBills.enumerated(){
			if(item == bill){
				symbol = index
			}
		}
		return symbol
	}

	func setFavoriteBill(){
		let symbol = isFavouriteBill(bill: bill)
		if(symbol != -1){
			FavouriteBills.remove(at: symbol)
			navigationItem.rightBarButtonItem?.image = UIImage(named: "star")!
		}
		else{
			FavouriteBills.append(bill)
			navigationItem.rightBarButtonItem?.image = UIImage(named: "starfilled")!
		}
	}

}

