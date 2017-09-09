//
//  FavouriteLegislatorViewController.swift
//  Congress
//
//  Created by Li on 11/24/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit

class FavouriteLegislatorViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate{
	
	@IBOutlet weak var legislatorsTable: UITableView!
	@IBOutlet weak var SearchButton: UIBarButtonItem!
	var favouriteLegislatorsSet = [Legislator]()
	
	//Display of searchbar, 0 no seach bar, 1 display
	var shouldDisplaySearchBar = true
	var shouldShowSearchResults = false
	var filteredLegislatorsSet = [Legislator]()
	
	//Mune open symbol
	var sidebarMenuOpen = Bool()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sidebarMenuOpen = false	
		
		legislatorsTable.delegate = self
		legislatorsTable.dataSource = self
		legislatorsTable.reloadData()
		
		// fix empty lines
		legislatorsTable.tableFooterView = UIView()
		
		// fix empty table area toggle
		let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
		self.legislatorsTable.addGestureRecognizer(tap)
	}
	
	func tableTapped(tap:UITapGestureRecognizer) {
		let location = tap.location(in: self.legislatorsTable)
		let path = self.legislatorsTable.indexPathForRow(at: location)
		if let indexPathForRow = path {
			self.tableView(self.legislatorsTable, didSelectRowAt: indexPathForRow)
		} else {
			if sidebarMenuOpen{
				self.revealViewController().revealToggle(self)
				sidebarMenuOpen = !sidebarMenuOpen
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		favouriteLegislatorsSet = FavouriteLegislators.sorted{$0.lastName < $1.lastName}
		self.legislatorsTable.reloadData()
	}
	
	@IBAction func showMune(_ sender: Any) {
		//show mune
		if revealViewController() != nil{
			self.revealViewController().revealToggle(self)
		}
		sidebarMenuOpen = !sidebarMenuOpen
	}
	
	//MARK : - Search Bar
	@IBAction func SearchLegislators(_ sender: Any) {
		if(shouldDisplaySearchBar == true){
			let searchBar = UISearchBar()
			searchBar.showsCancelButton = false
			searchBar.placeholder = "Search By Lastname"
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
			legislatorsTable.reloadData()
			return
		}
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		filteredLegislatorsSet = favouriteLegislatorsSet.filter({(legislator:Legislator) -> Bool in return legislator.lastName.lowercased().range(of: searchText.lowercased()) != nil})
		
		if(searchText != ""){
			shouldShowSearchResults = true
		}
		else{
			shouldShowSearchResults = false
		}
		self.legislatorsTable.reloadData()
	}
	
	// MARK: - Table view data source
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if shouldShowSearchResults{
			return filteredLegislatorsSet.count
		}
		else{
			return favouriteLegislatorsSet.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "FavouriteLegislatorCell", for: indexPath) as! LegislatorTableCell
		
		var legislator = Legislator()
		if shouldShowSearchResults{
			legislator = filteredLegislatorsSet[indexPath.row]
		}
		else{
			legislator = favouriteLegislatorsSet[indexPath.row]
		}
		
		cell.LegislatorName.text = "\(legislator.lastName), \(legislator.firstName)"
		cell.LegislatorState.text = UnitedStates[legislator.state]
		cell.LegislatorPhoto.downloadedFrom(link: "https://theunitedstates.io/images/congress/original/\(legislator.Id).jpg")
		return cell
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
			performSegue(withIdentifier: "Show Legislator Detail", sender: indexPath)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let detailView = segue.destination as! LegislatorDetailViewController
		
		if let indexPath = sender as? IndexPath{
			var currentLegislator = Legislator()
			if shouldShowSearchResults{
				currentLegislator = filteredLegislatorsSet[indexPath.row]
			}
			else{
				currentLegislator = favouriteLegislatorsSet[indexPath.row]
			}
			detailView.legislator = currentLegislator
		}
		else{
			detailView.legislator = Legislator()
		}
		
		let backItem = UIBarButtonItem()
		backItem.title = "Back"
		navigationItem.backBarButtonItem = backItem
	}
}
