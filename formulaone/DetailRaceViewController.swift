//
//  DetailRaceViewController.swift
//  formulaone
//
//  Created by Vincent Verges on 15/02/2024.
//

import UIKit
import EventKit

class DetailRaceViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBAction func ajouterAuCalendrierPressed(_ sender: Any) {
        ajouterEvenementAuCalendrier()
    }
    
    
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
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch {
                    // Gérer l'erreur
                    print("Erreur lors de la sauvegarde de l'événement dans le calendrier: \(error)")
                }
            }
        }
    }
    
}

