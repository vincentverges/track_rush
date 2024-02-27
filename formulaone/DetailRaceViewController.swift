//
//  DetailRaceViewController.swift
//  formulaone
//
//  Created by Vincent Verges on 15/02/2024.
//

import UIKit
import EventKit
import EventKitUI

class DetailRaceViewController: UIViewController, EKEventEditViewDelegate {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var addCalendarButton: UIButton!
    @IBAction func ajouterAuCalendrierPressed(_ sender: Any) {
        ajouterEvenementAuCalendrier()
    }
    
    var selectedRace: Meeting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = selectedRace?.meetingName
        
        configureButton(addCalendarButton, title: "Add to Calendar", backgroundColor: UIColor.systemTeal)
        
        if let selectedRace = selectedRace {
            let imageName = "\(selectedRace.circuitKey).png"
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

    func configureButton(_ button: UIButton, title: String, backgroundColor: UIColor, cornerRadius: CGFloat = 5) {
        button.setTitle(title, for: .normal)
        button.layer.cornerRadius = cornerRadius
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        dismiss(animated: true, completion: nil)

        switch action {
        case .canceled:
            print("L'utilisateur a annulé.")
        case .saved:
            print("Événement enregistré.")
        case .deleted:
            print("L'événement a été supprimé.")
        @unknown default:
            print("Action inconnue.")
        }
    }

    
    func ajouterEvenementAuCalendrier() {
        let eventStore = EKEventStore()
        
        eventStore.requestFullAccessToEvents { [weak self] (granted, error) in
            DispatchQueue.main.async {
                
                if let error = error {
                    // Afficher les détails de l'erreur si la demande échoue
                    print("Erreur lors de la demande d'accès complet aux événements : \(error.localizedDescription)...")
                }
                
                guard granted, let strongSelf = self, let selectedRace = strongSelf.selectedRace else {
                    print("Accès complet aux événements du calendrier refusé")
                    return
                }
                
                let event = EKEvent(eventStore: eventStore)
                event.title = selectedRace.meetingName
                event.startDate = DateFormatter.iso8601Full.date(from: selectedRace.dateStart)
                event.endDate = event.startDate?.addingTimeInterval(7200) // Exemple: 2 heures après le début
                event.location = "\(selectedRace.location), \(selectedRace.countryName)"
                
                let eventEditViewController = EKEventEditViewController()
                eventEditViewController.event = event
                eventEditViewController.eventStore = eventStore
                eventEditViewController.editViewDelegate = strongSelf
                
                strongSelf.present(eventEditViewController, animated: true)
            }
        }
    }
    
}

