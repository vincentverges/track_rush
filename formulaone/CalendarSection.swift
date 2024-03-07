//
//  CalendarSection.swift
//  formulaone
//
//  Created by Vincent Verges on 06/03/2024.
//

import UIKit
import EventKit
import EventKitUI

protocol CalendarSectionDelegate: AnyObject {
    func ajouterEvenementAuCalendrier()
}

class CalendarSection: UITableViewCell {
    weak var delegate: CalendarSectionDelegate?
    @IBOutlet var addCalendarButton: UIButton!
    @IBAction func ajouterAuCalendrierPressed(_ sender: Any) {
        delegate?.ajouterEvenementAuCalendrier()
    }
    @IBOutlet var raceDateView: UILabel!
    @IBOutlet var raceHourView: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureButton(addCalendarButton, title: "\u{23F0} Add to Calendar", backgroundColor: UIColor.systemTeal)
        
        raceDateView.font = UIFont.boldSystemFont(ofSize: 18)
        raceHourView.font = UIFont.systemFont(ofSize: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureButton(_ button: UIButton, title: String, backgroundColor: UIColor, cornerRadius: CGFloat = 5) {
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }

}
