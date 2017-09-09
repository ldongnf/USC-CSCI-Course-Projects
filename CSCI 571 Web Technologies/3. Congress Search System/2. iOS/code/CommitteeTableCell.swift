//
//  CommitteeTableCell.swift
//  Congress
//
//  Created by Li on 11/24/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit

class CommitteeTableCell: UITableViewCell {

	@IBOutlet weak var CommitteeID: UILabel!
	@IBOutlet weak var CommitteeName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
