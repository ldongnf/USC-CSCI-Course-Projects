//
//  AboutMeViewController.swift
//  Congress
//
//  Created by Li on 11/25/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit

class AboutMeViewController: UIViewController{

	@IBOutlet weak var MuneButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add the mune Func
		
		if revealViewController() != nil{
			MuneButton.target = revealViewController()
			MuneButton.action = #selector(SWRevealViewController.revealToggle(_:))
			view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
			view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
		}
		
    }
}
