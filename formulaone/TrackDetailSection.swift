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
    @IBOutlet var raceCompletNameView: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        raceCompletNameView.font = UIFont.boldSystemFont(ofSize: 14)
        raceCompletNameView.textColor = UIColor.gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
