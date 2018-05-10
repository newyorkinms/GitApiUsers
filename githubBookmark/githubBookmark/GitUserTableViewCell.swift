//
//  GitUserTableViewCell.swift
//  githubBookmark
//
//  Created by 강문성 on 2018. 5. 5..
//  Copyright © 2018년 강문성. All rights reserved.
//

import UIKit

class GitUserTableViewCell: UITableViewCell {
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnBookmark: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        imgProfile.af_cancelImageRequest()
        imgProfile.image = nil
    }

}
