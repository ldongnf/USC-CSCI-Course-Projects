//
//  BillsTableCell.swift
//  Congress
//
//  Created by Li on 11/23/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit

class BillsTableCell: UITableViewCell {

	@IBOutlet weak var BillID: UILabel!
	@IBOutlet weak var BillOfficialTitle: UILabel!
	@IBOutlet weak var BillIntroducedON: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
