//
//  LegislatorTableCell.swift
//  Congress
//
//  Created by Li on 11/22/16.
//  Copyright © 2016 Li. All rights reserved.
//

import UIKit

class LegislatorTableCell: UITableViewCell {

	@IBOutlet weak var LegislatorPhoto: UIImageView!
	@IBOutlet weak var LegislatorState: UILabel!
	@IBOutlet weak var LegislatorName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
