//
//  LegislatorStateViewController.swift
//  Congress
//
//  Created by Li on 11/22/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SwiftSpinner

class LegislatorStateViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
	
	// subview setup
	@IBOutlet weak var statePicker: UIPickerView!
	@IBOutlet weak var legislatorsTable: UITableView!
	
	// Php params
	var strURL = "http://lowcost-env.waxmixxy3a.us-west-2.elasticbeanstalk.com/congress/backup.php"
	var params = ["congressDB":"Legislators"]
	
	// legislator datasets
	var legislatorsSet = [Legislator]()
	var legislatorsSetSorted = [Legislator]()
	var buff = [[String:AnyObject]]() //Array of legislator
	var sections : [(index: Int, length :Int, title: String)] = Array()
	var defaultSections : [(index: Int, length :Int, title: String)] = Array()
	var state = [String]()
	
	// sidebar symbol
	var sidebarMenuOpen = Bool()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// init side bar closed
		sidebarMenuOpen = false
		
		// Load Animation
		SwiftSpinner.show("Extracting Data...")
		
		// # Ajax Call
		Alamofire.request(
			strURL,
			parameters: params
			).responseJSON { (responseData) -> Void in
				if((responseData.result.value) != nil) {
					let swiftyJsonVar = JSON(responseData.result.value!)
					if let resData = swiftyJsonVar["results"].arrayObject {
						self.buff = resData as! [[String:AnyObject]]
						
						for item in self.buff{
							let l = Legislator()
							l.setLegislator(JsonData: item)
							self.legislatorsSet.append(l)
						}
					}
					if self.legislatorsSet.count > 0 {
						// #Sort By LastName
						LegislatorsGlobalSet = self.legislatorsSet.sorted{$0.lastName < $1.lastName}
						
						self.legislatorsSetSorted = self.legislatorsSet.sorted{
							switch ($0.state[0],$1.state[0]) {
							// if neither “category" is nil and contents are equal,
							case let (lhs,rhs) where lhs == rhs:
								// compare “status” (> because DESC order)
								return $0.lastName < $1.lastName
							// else just compare “category” using <
							case let (lhs, rhs):
								return lhs < rhs
							}
						}

						self.legislatorsSet = self.legislatorsSetSorted

						// #Set up section
						var index = 0;
						for (i,legislator) in self.legislatorsSetSorted.enumerated(){
							
							if self.legislatorsSetSorted[index].state[0] != legislator.state[0]{
								let title = "\(self.legislatorsSetSorted[index].state[0])"

								let newSection = (index: index, length: i - index, title: title)
								
								self.sections.append(newSection)
								index = i;
							}
						}
						
						if(self.legislatorsSetSorted[index-1].state[0] != self.legislatorsSetSorted.last?.state[0]){
							let title = "\(self.legislatorsSetSorted[index].state[0])"
							let newSection = (index: index, length: self.legislatorsSetSorted.count - index, title: title)
							self.sections.append(newSection)
						}
						self.defaultSections = self.sections
						self.legislatorsTable.reloadData()

						SwiftSpinner.hide()
					}
				}
		}
		// set up unitedstateds
		state.append(contentsOf: UnitedStates.keys.sorted{$0<$1})
		
		// view default settings
		self.statePicker.isHidden = true
		self.legislatorsTable.isHidden = false
		
		legislatorsTable.delegate = self
		legislatorsTable.dataSource = self
		
		statePicker.delegate = self
		statePicker.dataSource = self

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
		if revealViewController() != nil{
			self.revealViewController().revealToggle(self)
		}
		sidebarMenuOpen = !sidebarMenuOpen
	}
	
	// MARK: - Table view data source
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].length
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LegislatorCell", for: indexPath) as! LegislatorTableCell
		
		let legislator = legislatorsSetSorted[sections[indexPath.section].index + indexPath.row]
		
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
			let currentLegislator = legislatorsSetSorted[sections[indexPath.section].index + indexPath.row]
			detailView.legislator = currentLegislator
		}
		else{
			detailView.legislator = Legislator()
		}
		
		let backItem = UIBarButtonItem()
		backItem.title = "Back"
		navigationItem.backBarButtonItem = backItem
	}

	// Mark: - Picker Data
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return state.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return UnitedStates[state[row]]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		let selectedState = state[row]
		self.statePicker.isHidden = true
		self.legislatorsTable.isHidden = false
		legislatorsSetSorted.removeAll()
		if(UnitedStates[selectedState] == "All States"){
			legislatorsSetSorted = legislatorsSet
		}
		else{
			for legislator in legislatorsSet{
				if(legislator.state == selectedState){
					legislatorsSetSorted.append(legislator)
				}
			}
		}
		self.sections.removeAll()
		if(UnitedStates[selectedState] == "All States"){
			self.sections=defaultSections
		}
		else{
			let index = 0
			let title = "\(self.legislatorsSetSorted[index].state[0])"
			let newSection = (index: index, length: self.legislatorsSetSorted.count - index, title: title)
			self.sections.append(newSection)
		}
		self.legislatorsTable.reloadData()
	}
	
	@IBAction func LegislatorFilterByState(_ sender: Any) {
		statePicker.isHidden = false
		legislatorsTable.isHidden = true
	}
}
