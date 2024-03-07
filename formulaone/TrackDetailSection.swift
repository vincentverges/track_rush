//
//  TrackDetailSection.swift
//  formulaone
//
//  Created by Vincent Verges on 06/03/2024.
//

import UIKit

class TrackDetailSection: UITableViewCell {
    @IBOutlet var trackImageView: UIImageView!
    @IBOutlet var driverListButtonView: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
