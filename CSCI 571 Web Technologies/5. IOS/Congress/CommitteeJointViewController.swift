//
//  CommitteeJointViewController.swift
//  Congress
//
//  Created by Li on 11/24/16.
//  Copyright © 2016 Li. All rights reserved.
//  self.tabBarController?.tabBar.isUserInteractionEnabled = true

import UIKit

class CommitteeJointViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
	
	@IBOutlet weak var SearchButton: UIBarButtonItem!
	@IBOutlet weak var CommitteeTable: UITableView!
	
	var committeesSetSortedByName = [Committee]()
	var committeesSenate = [Committee]()
	var buff = [[String:AnyObject]]()
	
	//Display of searchbar, 0 no seach bar, 1 display
	var shouldDisplaySearchBar = true
	var shouldShowSearchResults = false
	var filteredCommitteesSet = [Committee]()

	//Mune open symbol
	var sidebarMenuOpen = Bool()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sidebarMenuOpen = false
		committeesSetSortedByName = CommitteesGlobalSet
		for item in self.committeesSetSortedByName{
			if item.chamber == "joint"{
				self.committeesSenate.append(item)
			}
		}
		// Do any additional setup after loading the view.
		CommitteeTable.delegate = self
		CommitteeTable.dataSource = self
		CommitteeTable.reloadData()
		
		// fix empty lines
		CommitteeTable.tableFooterView = UIView()
		
		// fix empty table area toggle
		let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
		self.CommitteeTable.addGestureRecognizer(tap)
	}
	
	func tableTapped(tap:UITapGestureRecognizer) {
		let location = tap.location(in: self.CommitteeTable)
		let path = self.CommitteeTable.indexPathForRow(at: location)
		if let indexPathForRow = path {
			self.tableView(self.CommitteeTable, didSelectRowAt: indexPathForRow)
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
			sidebarMenuOpen = !sidebarMenuOpen
		}
	}

	@IBAction func SearchCommittee(_ sender: Any) {
		if(shouldDisplaySearchBar == true){
			let searchBar = UISearchBar()
			searchBar.showsCancelButton = false
			searchBar.placeholder = "Search By Name"
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
			CommitteeTable.reloadData()
			return
		}
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		filteredCommitteesSet = committeesSenate.filter({(committee:Committee) -> Bool in return committee.name.lowercased().range(of: searchText.lowercased()) != nil})
		
		if(searchText != ""){
			shouldShowSearchResults = true
		}
		else{
			shouldShowSearchResults = false
		}
		self.CommitteeTable.reloadData()
	}
	
	// MARK: - Table view data source
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if shouldShowSearchResults{
			return filteredCommitteesSet.count
		}
		else{
			return committeesSenate.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CommitteeJointCell", for: indexPath) as! CommitteeTableCell
		
		var committee = Committee()
		if shouldShowSearchResults{
			committee = filteredCommitteesSet[indexPath.row]
		}
		else{
			committee = committeesSenate[indexPath.row]
		}
		
		cell.CommitteeName.text = committee.name
		cell.CommitteeID.text = committee.Id
		cell.isSelected = false
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
			performSegue(withIdentifier: "Show Committee Detail", sender: indexPath)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let detailView = segue.destination as! CommitteeDetailViewController
		if let indexPath = sender as? IndexPath{
			var currentCommittee = Committee()
			if shouldShowSearchResults{
				currentCommittee = filteredCommitteesSet[indexPath.row]
			}
			else{
				currentCommittee = committeesSenate[indexPath.row]
				
			}
			detailView.committee = currentCommittee
		}
		else{
			detailView.committee = Committee()
		}
		
		let backItem = UIBarButtonItem()
		backItem.title = "Back"
		navigationItem.backBarButtonItem = backItem
	}
}
