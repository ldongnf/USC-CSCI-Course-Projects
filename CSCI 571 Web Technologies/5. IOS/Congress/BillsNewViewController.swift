//
//  BillsNewViewController.swift
//  Congress
//
//  Created by Li on 11/24/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class BillsNewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
	
	@IBOutlet weak var SearchButton: UIBarButtonItem!
	@IBOutlet weak var BillsTable: UITableView!
	
	var strURL = "http://lowcost-env.waxmixxy3a.us-west-2.elasticbeanstalk.com/congress/backup.php"
	var params = ["congressDB":"BillsNew"]
	
	var billsSet = [Bill]()
	var billsSetSortedByIntroducedOn = [Bill]()
	var buff = [[String:AnyObject]]() //Array of Bill
	
	//Display of searchbar, 0 no seach bar, 1 display
	var shouldDisplaySearchBar = true
	var filteredBillsSet = [Bill]()
	var shouldShowSearchResults = false
	
	//Mune open symbol
	var sidebarMenuOpen = Bool()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		SwiftSpinner.show("Extracting Data...")
		sidebarMenuOpen = false
		Alamofire.request(
			strURL,
			parameters: params
			).responseJSON { (responseData) -> Void in
				if((responseData.result.value) != nil) {
					let swiftyJsonVar = JSON(responseData.result.value!)
					if let resData = swiftyJsonVar["results"].arrayObject {
						self.buff = resData as! [[String:AnyObject]]
						for item in self.buff{
							let b = Bill()
							b.setBill(JsonData: item)
							self.billsSet.append(b)
						}
					}
					if self.billsSet.count > 0 {
						// #Sort By LastName
						self.billsSetSortedByIntroducedOn = self.billsSet.sorted{$0.introducedOn > $1.introducedOn}
						self.billsSet = self.billsSetSortedByIntroducedOn
						
						self.BillsTable.reloadData()
						SwiftSpinner.hide()
					}
				}
		}
		// Do any additional setup after loading the view.
		BillsTable.delegate = self
		BillsTable.dataSource = self
		BillsTable.reloadData()
		
		// fix empty lines
		self.BillsTable.tableFooterView = UIView()
		
		// fix empty table area toggle
		let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
		self.BillsTable.addGestureRecognizer(tap)
	}
	
	func tableTapped(tap:UITapGestureRecognizer) {
		let location = tap.location(in: self.BillsTable)
		let path = self.BillsTable.indexPathForRow(at: location)
		if let indexPathForRow = path {
			self.tableView(self.BillsTable, didSelectRowAt: indexPathForRow)
		} else {
			if sidebarMenuOpen{
				self.revealViewController().revealToggle(self)
				sidebarMenuOpen = !sidebarMenuOpen
			}
		}
	}
	
	@IBAction func showMune(_ sender: Any) {
		//show mune
		if revealViewController() != nil{
			self.revealViewController().revealToggle(self)
		}
		sidebarMenuOpen = !sidebarMenuOpen
	}
	
	// Display Search Bar
	@IBAction func SearchBIlls(_ sender: Any) {
		if(shouldDisplaySearchBar == true){
			let searchBar = UISearchBar()
			searchBar.showsCancelButton = false
			searchBar.placeholder = "Search By Title"
			searchBar.delegate = self
			
			self.navigationItem.titleView = searchBar
			self.SearchButton.image = UIImage(named: "Cancel")
			shouldDisplaySearchBar = false
			return
		}
		if(shouldDisplaySearchBar == false){
			self.navigationItem.titleView = nil
			self.SearchButton.image = UIImage(named: "Search")
			shouldDisplaySearchBar = true
			shouldShowSearchResults = false
			BillsTable.reloadData()
			return
		}
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		filteredBillsSet = billsSetSortedByIntroducedOn.filter({(bill:Bill) -> Bool in return bill.officialTitle.lowercased().range(of: searchText.lowercased()) != nil})
		
		if(searchText != ""){
			shouldShowSearchResults = true
		}
		else{
			shouldShowSearchResults = false
		}
		self.BillsTable.reloadData()
	}
	
	// MARK: - Table view data source
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if shouldShowSearchResults{
			return filteredBillsSet.count
		}
		else{
			return billsSetSortedByIntroducedOn.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BillNewCell", for: indexPath) as! BillsTableCell
		
		var bill = Bill()
		if shouldShowSearchResults{
			bill = filteredBillsSet[indexPath.row]
		}
		else{
			bill = billsSetSortedByIntroducedOn[indexPath.row]
		}
		
		cell.BillID.text = bill.Id
		cell.BillOfficialTitle.text = bill.officialTitle
		cell.BillIntroducedON.text = bill.getIntroducedOnWithFormat(targetDateFormat: "MMM dd,yyyy")
		
		cell.BillID.font = UIFont.boldSystemFont(ofSize: 13.0)
		cell.BillOfficialTitle.numberOfLines = 4 // line wrap
		//cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
		return cell
	}
	
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	// MARK: - Navagation
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if(sidebarMenuOpen == true){
			self.revealViewController().revealToggle(self)
			sidebarMenuOpen = !sidebarMenuOpen
		} else {
			for cell in tableView.visibleCells{
				cell.isSelected = false
			}
			tableView.cellForRow(at: indexPath)?.isSelected = true
			self.tabBarController?.tabBar.isHidden = true
			performSegue(withIdentifier: "Show Bill Detail", sender: indexPath)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let detailView = segue.destination as! BillDetailViewController
		
		if let indexPath = sender as? IndexPath{
			var currentBill = Bill()
			if shouldShowSearchResults{
				currentBill = filteredBillsSet[indexPath.row]
			}
			else{
				currentBill = billsSetSortedByIntroducedOn[indexPath.row]
			}
			detailView.bill = currentBill
		}
		else{
			detailView.bill = Bill()
		}
		
		let backItem = UIBarButtonItem()
		backItem.title = "Back"
		navigationItem.backBarButtonItem = backItem
	}
}
