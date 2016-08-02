//
//  DimmedCell.swift
//  Crownhog
//
//  Created by Samuel Huang on 2/2/16.
//  Copyright © 2016 Zomero LLC. All rights reserved.
//

import UIKit

class DimmedCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var profileView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        profileView.contentMode = .ScaleAspectFit
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
