//
//  LegislatorSenateViewController.swift
//  Congress
//
//  Created by Li on 11/22/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit

class LegislatorSenateViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate{
	
	@IBOutlet weak var legislatorsTable: UITableView!
	@IBOutlet weak var SearchButton: UIBarButtonItem!

	var legislatorsSet = [Legislator]()
	var legislatorsSetSenate = [Legislator]()
	
	//Display of searchbar, 0 no seach bar, 1 display
	var shouldDisplaySearchBar = true
	
	var filteredLegislatorsSet = [Legislator]()
	var shouldShowSearchResults = false
	
	var sidebarMenuOpen = Bool()
	
	// index sections
	var sections : [(index: Int, length :Int, title: String)] = Array()
	var defaultSections : [(index: Int, length :Int, title: String)] = Array()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sidebarMenuOpen = false
		
		legislatorsSet = LegislatorsGlobalSet
		for item in legislatorsSet{
			if item.chamber == "senate"{
				legislatorsSetSenate.append(item)
			}
		}
		
		// set up sections
		var index = 0;
		for (i,legislator) in self.legislatorsSetSenate.enumerated(){
			
			if self.legislatorsSetSenate[index].lastName[0] != legislator.lastName[0]{
				let title = "\(self.legislatorsSetSenate[index].lastName[0])"
				
				let newSection = (index: index, length: i - index, title: title)
				
				self.sections.append(newSection)
				index = i;
			}
		}
		
		if(self.legislatorsSetSenate[index-1].lastName[0] != self.legislatorsSetSenate.last?.lastName[0]){
			let title = "\(self.legislatorsSetSenate[index].lastName[0])"
			let newSection = (index: index, length: self.legislatorsSetSenate.count - index, title: title)
			self.sections.append(newSection)
		}
		self.defaultSections = self.sections
		
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
		filteredLegislatorsSet = legislatorsSetSenate.filter({(legislator:Legislator) -> Bool in return legislator.firstName.lowercased().range(of: searchText.lowercased()) != nil})
		
		if(searchText != ""){
			sections.removeAll()
			// set up sections
			var index = 0;
			for (i,legislator) in self.filteredLegislatorsSet.enumerated(){
				
				if self.filteredLegislatorsSet[index].lastName[0] != legislator.lastName[0]{
					let title = "\(self.filteredLegislatorsSet[index].lastName[0])"
					
					let newSection = (index: index, length: i - index, title: title)
					
					self.sections.append(newSection)
					index = i;
				}
			}
			
			if(self.filteredLegislatorsSet.count>0 && self.filteredLegislatorsSet[index-1].lastName[0] != self.filteredLegislatorsSet.last?.lastName[0]){
				let title = "\(self.filteredLegislatorsSet[index].lastName[0])"
				let newSection = (index: index, length: self.filteredLegislatorsSet.count - index, title: title)
				self.sections.append(newSection)
			}
			shouldShowSearchResults = true
		}
		else{
			sections.removeAll()
			sections = defaultSections
			shouldShowSearchResults = false
		}
		self.legislatorsTable.reloadData()
	}
	
	// MARK: - Table view data source
	/*
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}*/
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	/*
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if shouldShowSearchResults{
			return filteredLegislatorsSet.count
		}
		else{
			return legislatorsSetSenate.count
		}
	}*/
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].length
	}
	/*
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LegislatorCell", for: indexPath) as! LegislatorTableCell
		
		var legislator = Legislator()
		if shouldShowSearchResults{
			legislator = filteredLegislatorsSet[indexPath.row]
		}
		else{
			legislator = legislatorsSetSenate[indexPath.row]
		}
		
		cell.LegislatorName.text = "\(legislator.lastName), \(legislator.firstName)"
		cell.LegislatorState.text = UnitedStates[legislator.state]
		cell.LegislatorPhoto.downloadedFrom(link: "https://theunitedstates.io/images/congress/original/\(legislator.Id).jpg")
		return cell
	}*/
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LegislatorCell", for: indexPath) as! LegislatorTableCell
		
		var legislator = Legislator()
		if shouldShowSearchResults{
			legislator = filteredLegislatorsSet[sections[indexPath.section].index + indexPath.row]
		}
		else{
			legislator = legislatorsSetSenate[sections[indexPath.section].index + indexPath.row]
			
		}
		
		cell.LegislatorName.text = "\(legislator.lastName), \(legislator.firstName)"
		cell.LegislatorState.text = UnitedStates[legislator.state]
		cell.LegislatorPhoto.downloadedFrom(link: "https://theunitedstates.io/images/congress/original/\(legislator.Id).jpg")
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].title
	}
	
	func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return sections.map { $0.title }
	}
	
	func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return index
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
				//currentLegislator = filteredLegislatorsSet[indexPath.row]
				currentLegislator = filteredLegislatorsSet[sections[indexPath.section].index + indexPath.row]
			}
			else{
				//currentLegislator = legislatorsSetSenate[indexPath.row]
				currentLegislator = legislatorsSetSenate[sections[indexPath.section].index + indexPath.row]
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
