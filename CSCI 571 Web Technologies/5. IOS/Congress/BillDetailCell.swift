//
//  BillDetailCell.swift
//  Congress
//
//  Created by Li on 11/23/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit

class BillDetailCell: UITableViewCell {

	@IBOutlet weak var Head: UILabel!
	@IBOutlet weak var Content: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
