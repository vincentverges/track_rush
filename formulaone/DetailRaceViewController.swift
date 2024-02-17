//
//  DetailRaceViewController.swift
//  formulaone
//
//  Created by Vincent Verges on 15/02/2024.
//

import UIKit

class DetailRaceViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    
    var selectedRace: Race?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = selectedRace?.raceName
        
        if let selectedRace = selectedRace {
            let imageName = "\(selectedRace.circuit.circuitId).png"
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
