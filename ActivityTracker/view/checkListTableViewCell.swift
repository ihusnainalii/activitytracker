//
//  checkListTableViewCell.swift
//  ActivityTracker
//
//  Created by macintosh on 12/20/18.
//  Copyright © 2018 macintosh. All rights reserved.
//

import UIKit

class checkListTableViewCell: UITableViewCell {
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lblTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
