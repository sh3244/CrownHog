//
//  CustomCell.swift
//  
//
//  Created by Samuel Huang on 1/28/16.
//
//

import UIKit
import Parse

class CustomCell: UITableViewCell {
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    var passName: String!
    var toPass: String!
    var cellIndex: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupAppearance()
    }
    
    func setupAppearance() {
        likeButton.imageView?.contentMode = .ScaleAspectFit
        likeButton.highlighted = true
        likeButton.addTarget(self, action: "unLike", forControlEvents: .TouchUpInside)
    }
    
    func unLike() {
//        likeButton.enabled = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }}
