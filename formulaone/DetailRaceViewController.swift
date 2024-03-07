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
                    print("Erreur lors de la demande d'accès complet aux événements : \(error.localizedDescription)...")
                }
                
                guard granted, let strongSelf = self, let meeting = strongSelf.meeting else {
                    print("Accès complet aux événements du calendrier refusé")
                    return
                }
                
                let event = EKEvent(eventStore: eventStore)
                event.title = meeting.meetingName
                event.startDate = DateFormatter.iso8601Full.date(from: meeting.dateStart)
                event.endDate = event.startDate?.addingTimeInterval(7200)
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
    var weathers: [Weather] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = meeting?.meetingName
        
        tableView.dataSource = self
        tableView.delegate = self
        
        performApiCalls()
        
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
            
            cell.driverListButtonView.setTitle("\u{1F3CE} Driver List", for: .normal) 
            
            return cell
        case .calendar:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarSection", for: indexPath) as? CalendarSection else {
                fatalError("Impossible de créer une instance de CalendarSection")
            }
            if let meeting = meeting {
                
                let isoDate = meeting.dateStart
                
                let dateFormatterDate = DateFormatter()
                dateFormatterDate.locale = Locale(identifier: "en_US_POSIX")
                dateFormatterDate.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                if let date = dateFormatterDate.date(from: isoDate) {
                    dateFormatterDate.dateFormat = "EEEE, MMM d, yyyy"
                    let readableDate = dateFormatterDate.string(from: date)
                    cell.raceDateView.text = "\u{1F4C5} \(readableDate)"
                }
                
                let dateFormatterHour = DateFormatter()
                dateFormatterHour.locale = Locale(identifier: "en_US_POSIX")
                dateFormatterHour.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                if let hour = dateFormatterHour.date(from: isoDate) {
                    dateFormatterHour.dateFormat = "HH:mm:ss"
                    let readableHour = dateFormatterHour.string(from: hour)
                    cell.raceHourView.text = "\u{1F55B} \(readableHour)"
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
    
    func performApiCalls() {
        
        guard let meeting = meeting else {
            print("Les informations de la réunion sont manquantes ou incomplètes.")
            return
        }
        
        guard let sessionUrl = URL(string: "https://api.openf1.org/v1/sessions?circuit_key=\(meeting.circuitKey)&meeting_key=\(meeting.meetingKey)&year=\(meeting.year)&session_name=Race") else { return }
        
        let sessionTask = URLSession.shared.dataTask(with: sessionUrl) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode([Session].self, from: data)
                if let sessionKey = response.first?.sessionKey {
                    
                    self?.fetchWeather(with: sessionKey)
                } else {
                    print("No Session Key Find")
                }
                
            } catch {
                print(error)
            }
        }
        
        sessionTask.resume()
    }
    
    func fetchWeather(with sessionKey: Int) {
        guard let meeting = meeting else {
            print("Les informations de la réunion sont manquantes ou incomplètes.")
            return
        }
        
        guard let weathersUrl = URL(string: "https://api.openf1.org/v1/weather?meeting_key=\(meeting.meetingKey)&session_key=\(sessionKey)") else { return }
        
        let weathersTask = URLSession.shared.dataTask(with: weathersUrl) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode([Weather].self, from: data)
                DispatchQueue.main.async {
                    self?.weathers = response
                    self?.tableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
        
        weathersTask.resume()
    }
    
}

struct Weather: Decodable {
    let airTemperature: Double
    let humidity: Double
    let pressure: Double
    let rainfall: Double
    let trackTemperature: Double
    let windDirection: Int
    let windSpeed: Double
    let date: String
    let sessionKey: Int
    let meetingKey: Int

    enum CodingKeys: String, CodingKey {
        case airTemperature = "air_temperature"
        case humidity
        case pressure
        case rainfall
        case trackTemperature = "track_temperature"
        case windDirection = "wind_direction"
        case windSpeed = "wind_speed"
        case date
        case sessionKey = "session_key"
        case meetingKey = "meeting_key"
    }
}
