//
//  DetailRaceViewController.swift
//  formulaone
//
//  Created by Vincent Verges on 15/02/2024.
//

import UIKit

class DetailRaceViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    var selectedRace: Meeting?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = selectedRace?.meetingName
        
        if let selectedRace = selectedRace {
            let imageName = "\(selectedRace.circuitKey).png"
            //print(imageName)
            imageView.image = UIImage(named: imageName)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.hidesBarsOnTap = true
        }

    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            navigationController?.hidesBarsOnTap = false
        }

}
