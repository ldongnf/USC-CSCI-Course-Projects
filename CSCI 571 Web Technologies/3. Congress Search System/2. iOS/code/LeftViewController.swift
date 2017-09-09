//
//  LeftViewController.swift
//  SlideMenuControllerSwift
//
//  Created by Yuji Hato on 12/3/14.
//

import UIKit

enum LeftMenu: Int {
	case main = 0
	case billsActive
	case committeeHouse
	case favouriteLegislator
	case aboutMe
}


class LeftViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
	
	@IBOutlet weak var tableView: UITableView!
	var menus = ["legilator", "bill", "committee", "favourite", "aboutme"]
	var legislatorStateViewController: UIViewController!
	var billsActiveViewController: UIViewController!
	var committeeHouseViewController: UIViewController!
	var favouriteLegislatorViewController: UIViewController!
	var aboutMeViewController: UIViewController!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

	}
	
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return menus.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if let menu = LeftMenu(rawValue: indexPath.row) {
			
			switch menu {
			case .main:
				let cell = tableView.dequeueReusableCell(withIdentifier: "LegislatorMune", for: indexPath)
				return cell
			case .billsActive:
				let cell = tableView.dequeueReusableCell(withIdentifier: "BillMune", for: indexPath)
				return cell
			case .committeeHouse:
				let cell = tableView.dequeueReusableCell(withIdentifier: "CommitteeMune", for: indexPath)
				return cell
			case .favouriteLegislator:
				let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteMune", for: indexPath)
				return cell
			case .aboutMe:
				let cell = tableView.dequeueReusableCell(withIdentifier: "MeMune", for: indexPath)
				return cell
			}
		}
		return UITableViewCell()
	}
}

