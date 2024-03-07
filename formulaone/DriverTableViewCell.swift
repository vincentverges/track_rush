//
//  DriverTableViewCell.swift
//  formulaone
//
//  Created by Vincent Verges on 28/02/2024.
//

import UIKit

protocol DriverCellDelegate: AnyObject {
    func didTapFavoriteButton(for driver: Driver)
}

class DriverTableViewCell: UITableViewCell {
    weak var delegate: DriverCellDelegate?
    var driver: Driver?
    
    
    @IBOutlet var favoriteButton: UIButton!
    @IBAction func favoriteButton(_ sender: UIButton) {
        if let driver = driver {
            delegate?.didTapFavoriteButton(for: driver)
        }
    }
    
    @IBOutlet var driverImageView: UIImageView!
    @IBOutlet var driverNameView: UILabel!
    @IBOutlet var driverInformationsView: UILabel!
    @IBOutlet var driverNumberView: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        driverNameView.font = UIFont.boldSystemFont(ofSize: 18)
        
        driverInformationsView.font = UIFont.systemFont(ofSize: 14)
        
        driverNumberView.font = UIFont.boldSystemFont(ofSize: 40)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
