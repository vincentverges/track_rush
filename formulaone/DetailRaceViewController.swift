//
//  DetailRaceViewController.swift
//  formulaone
//
//  Created by Vincent Verges on 15/02/2024.
//

import UIKit
import EventKit
import EventKitUI

enum DetailSection: Int, CaseIterable {
    case trackDetails = 0
    case calendar
    case meteo
}

extension DetailRaceViewController: CalendarSectionDelegate {
    func ajouterEvenementAuCalendrier() {
        let eventStore = EKEventStore()
        
        eventStore.requestFullAccessToEvents { [weak self] (granted, error) in
            DispatchQueue.main.async {
                
                if let error = error {
                    // Afficher les détails de l'erreur si la demande échoue
                    print("Erreur lors de la demande d'accès complet aux événements : \(error.localizedDescription)...")
                }
                
                guard granted, let strongSelf = self, let meeting = strongSelf.meeting else {
                    print("Accès complet aux événements du calendrier refusé")
                    return
                }
                
                let event = EKEvent(eventStore: eventStore)
                event.title = meeting.meetingName
                event.startDate = DateFormatter.iso8601Full.date(from: meeting.dateStart)
                event.endDate = event.startDate?.addingTimeInterval(7200) // Exemple: 2 heures après le début
                event.location = "\(meeting.location), \(meeting.countryName)"
                
                let eventEditViewController = EKEventEditViewController()
                eventEditViewController.event = event
                eventEditViewController.eventStore = eventStore
                eventEditViewController.editViewDelegate = strongSelf
                
                strongSelf.present(eventEditViewController, animated: true)
            }
        }
    }
}


class DetailRaceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EKEventEditViewDelegate {
    
    @IBAction func showDriversListSegue(_ sender: Any) {
    }
    
    @IBOutlet var tableView: UITableView!
    
    
    var meeting: Meeting?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = meeting?.meetingName
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "racersList" {
            if let destinationVC = segue.destination as? ListDriverViewController {
                destinationVC.meeting = self.meeting
            }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return DetailSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch DetailSection(rawValue: section) {
        case .trackDetails:
            return 1
        case .calendar:
            return 1
        case .meteo:
            return 1
        case .none:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if indexPath.section == DetailSection.trackDetails.rawValue {
                return 300
            } else if indexPath.section == DetailSection.calendar.rawValue {
                return 140
            } else {
                return 300
            }
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = DetailSection(rawValue: indexPath.section) else {
            fatalError("Section non gérée")
        }
        
        switch section {
        case .trackDetails:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrackDetailSection", for: indexPath) as? TrackDetailSection else {
                fatalError("Impossible de créer une instance de TrackDetailSection")
            }
            
            if let meeting = meeting {
                let imageName = "\(meeting.circuitKey).png"
                cell.trackImageView.image = UIImage(named: imageName)
            }
            return cell
        case .calendar:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarSection", for: indexPath) as? CalendarSection else {
                fatalError("Impossible de créer une instance de CalendarSection")
            }
            if let meeting = meeting {
                
                print(meeting.dateStart)
                let isoDate = meeting.dateStart
                
                let dateFormatterDate = DateFormatter()
                dateFormatterDate.locale = Locale(identifier: "en_US_POSIX")
                dateFormatterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                if let date = dateFormatterDate.date(from: isoDate) {
                    dateFormatterDate.dateFormat = "EEEE, MMM d, yyyy"
                    let readableDate = dateFormatterDate.string(from: date)
                    cell.raceDateView.text = readableDate
                }
                
                let dateFormatterHour = DateFormatter()
                dateFormatterHour.locale = Locale(identifier: "en_US_POSIX")
                dateFormatterHour.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                if let hour = dateFormatterHour.date(from: isoDate) {
                    dateFormatterHour.dateFormat = "HH:mm:ss"
                    let readableHour = dateFormatterHour.string(from: hour)
                    cell.raceHourView.text = "Race Start at \(readableHour)"
                }
                
            }
            cell.delegate = self
            return cell
        case .meteo:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MeteoSection", for: indexPath)
            cell.textLabel?.text = "La météo"
            return cell
        }
        
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
    
}

