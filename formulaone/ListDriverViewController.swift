//
//  ListDriverViewController.swift
//  formulaone
//
//  Created by Vincent Verges on 27/02/2024.
//
// https://api.openf1.org/v1/sessions?circuit_key=22&meeting_key=1210&year=2023&session_name=Race
//
// https://api.openf1.org/v1/drivers?meeting_key=1210&session_key=9094

import UIKit

extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

class ListDriverViewController: UITableViewController

{
    var meeting: Meeting?
    var drivers: [Driver] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 110
        tableView.rowHeight = UITableView.automaticDimension
        performApiCalls()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drivers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DriverCell", for: indexPath) as? DriverTableViewCell else {
            fatalError("La cellule n'est pas une instance de DriverTableViewCell")
        }
        
        let driver = drivers[indexPath.row]
        
        let countryCode = isoCountryCode(fromCountryName: driver.countryCode ?? "")
        let flagEmoji = countryCode.flatMap { countryFlagEmoji(fromCountryCode: $0) } ?? ""
        
        cell.driverImageView.image = nil
        cell.driverNameView.text = "\(driver.fullName) \(flagEmoji)"
        cell.driverInformationsView.text = "Team : \(driver.teamName ?? "Unknown")"
        cell.driverNumberView.text = "\(driver.driverNumber)"
        print(driver.countryCode ?? "none")
        
        if let customColor = UIColor(hex: driver.teamColour ?? "000000") {
                cell.backgroundColor = customColor
            }
        
        if let headshotURLString = driver.headshotURL, let imageURL = URL(string: headshotURLString) {
            URLSession.shared.dataTask(with: imageURL) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        if let updateCell = tableView.cellForRow(at: indexPath) as? DriverTableViewCell {
                            updateCell.driverImageView.image = image
                        }
                    }
                }
            }.resume()
        }
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
                    self?.fetchDrivers(with: sessionKey)
                } else {
                    print("No Session Key Find")
                }
                
            } catch {
                print(error)
            }
        }
        
        sessionTask.resume()
    }
    
    func fetchDrivers(with sessionKey: Int) {
        guard let meeting = meeting else {
            print("Les informations de la réunion sont manquantes ou incomplètes.")
            return
        }
        
        guard let driversUrl = URL(string: "https://api.openf1.org/v1/drivers?meeting_key=\(meeting.meetingKey)&session_key=\(sessionKey)") else { return }
        
        let driversTask = URLSession.shared.dataTask(with: driversUrl) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode([Driver].self, from: data)
                DispatchQueue.main.async {
                    self?.drivers = response
                    self?.tableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
        
        driversTask.resume()
    }
    
    func countryFlagEmoji(fromCountryCode countryCode: String) -> String {
        return countryCode
            .unicodeScalars
            .map { 127397 + $0.value }
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()
    }

    func isoCountryCode(fromCountryName countryName: String) -> String? {
        let specialCases: [String: String] = [
            "Great Britain": "GB", // GB est le code ISO pour le Royaume-Uni (United Kingdom)
        ]
        
        if let specialCode = specialCases[countryName] {
            return specialCode
        }
        
        let currentLocale = Locale.current
        
        if #available(iOS 16.0, *) {
            for region in Locale.Region.isoRegions {
                if let localizedCountryName = currentLocale.localizedString(forRegionCode: region.identifier),
                   localizedCountryName == countryName {
                    return region.identifier
                }
            }
        } else {
            // Pour les versions iOS antérieures à iOS 16, utilisez l'approche précédente
            let countryCodes = Locale.isoRegionCodes
            for code in countryCodes {
                if let localizedCountryName = currentLocale.localizedString(forRegionCode: code),
                   localizedCountryName == countryName {
                    return code
                }
            }
        }
        
        return nil
    }
    
}


struct Session: Decodable {
    let location: String
    let countryKey: Int
    let countryCode: String
    let countryName: String
    let circuitKey: Int
    let circuitShortName: String
    let sessionType: String
    let sessionName: String
    let dateStart: String
    let dateEnd: String
    let gmtOffset: String
    let sessionKey: Int
    let meetingKey: Int
    let year: Int
    
    enum CodingKeys: String, CodingKey {
        case location, countryKey = "country_key", countryCode = "country_code", countryName = "country_name", circuitKey = "circuit_key", circuitShortName = "circuit_short_name", sessionType = "session_type", sessionName = "session_name", dateStart = "date_start", dateEnd = "date_end", gmtOffset = "gmt_offset", sessionKey = "session_key", meetingKey = "meeting_key", year
    }
}

struct Driver: Decodable {
    let driverNumber: Int
    let broadcastName: String
    let fullName: String
    let nameAcronym: String
    let teamName: String?
    let teamColour: String?
    let firstName: String?
    let lastName: String?
    let headshotURL: String?
    let countryCode: String?
    let sessionKey: Int
    let meetingKey: Int
    
    enum CodingKeys: String, CodingKey {
        case driverNumber = "driver_number"
        case broadcastName = "broadcast_name"
        case fullName = "full_name"
        case nameAcronym = "name_acronym"
        case teamName = "team_name"
        case teamColour = "team_colour"
        case firstName = "first_name"
        case lastName = "last_name"
        case headshotURL = "headshot_url"
        case countryCode = "country_code"
        case sessionKey = "session_key"
        case meetingKey = "meeting_key"
    }
}
