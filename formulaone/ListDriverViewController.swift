//
//  ListDriverViewController.swift
//  formulaone
//
//  Created by Vincent Verges on 27/02/2024.
//

import UIKit
import CoreData

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

extension ListDriverViewController: DriverCellDelegate {
    func didTapFavoriteButton(for driver: Driver) {
        toggleFavoriteState(for: driver)
        tableView.reloadData()
    }
}

class ListDriverViewController: UITableViewController

{
    var meeting: Meeting?
    var drivers: [Driver] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        cell.driver = driver
        cell.delegate = self
        
        if isDriverFavorite(driver: driver) {
            cell.favoriteButton.backgroundColor = UIColor.clear
            cell.favoriteButton.setTitle("\u{2764}\u{FE0F}", for: .normal)
        } else {
            cell.favoriteButton.backgroundColor = UIColor.clear
            cell.favoriteButton.setTitle("\u{1F90D}", for: .normal)
        }
        
        cell.driverImageView.image = nil
        
        let countryCode = driver.countryCode ?? ""
        
        if let flagEmoji = countryFlagEmoji(forCountryCode: countryCode) {
            cell.driverNameView.text = "\(driver.fullName) \(flagEmoji)"
        } else {
            cell.driverNameView.text = driver.fullName
        }
        
        cell.driverInformationsView.text = "Team : \(driver.teamName ?? "Not disclosed")"
        cell.driverNumberView.text = "\(driver.driverNumber)"
        
        if let customColor = UIColor(hex: driver.teamColour ?? "A5A5A5") {
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
        } else {
            cell.driverImageView.image = UIImage(named: "anonymous.png")
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
    
    func toggleFavoriteState(for driver: Driver) {
        let isFavorite = isDriverFavorite(driver: driver)
        
        if isFavorite {
            // Le pilote est déjà un favori, le supprimer des favoris
            removeDriverFromFavorites(driver: driver)
        } else {
            // Le pilote n'est pas un favori, l'ajouter aux favoris
            addDriverToFavorites(driver: driver)
        }
    }
    
    func isDriverFavorite(driver: Driver) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteDriver> = FavoriteDriver.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "fullName == %@", driver.fullName)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            return !results.isEmpty
        } catch let error as NSError {
            print("Impossible de vérifier le statut favori. \(error), \(error.userInfo)")
            return false
        }
    }
    
    func addDriverToFavorites(driver: Driver) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let favoriteDriver = FavoriteDriver(context: managedContext)
        favoriteDriver.driverNumber = Int16(driver.driverNumber)
        favoriteDriver.broadcastName = driver.broadcastName
        favoriteDriver.fullName = driver.fullName
        favoriteDriver.nameAcronym = driver.nameAcronym
        favoriteDriver.teamName = driver.teamName
        favoriteDriver.teamColour = driver.teamColour
        favoriteDriver.firstName = driver.firstName
        favoriteDriver.lastName = driver.lastName
        favoriteDriver.headshotURL = driver.headshotURL
        favoriteDriver.countryCode = driver.countryCode
        favoriteDriver.sessionKey = Int32(driver.sessionKey)
        favoriteDriver.meetingKey = Int32(driver.meetingKey)
        
        do {
            try managedContext.save()
            print("Sauvegardé avec succès en favoris")
        } catch let error as NSError {
            print("Impossible de sauvegarder en favoris. \(error), \(error.userInfo)")
        }
        
    }
    
    func removeDriverFromFavorites(driver: Driver) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteDriver> = FavoriteDriver.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "fullName == %@", driver.fullName)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            for object in results {
                managedContext.delete(object)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Impossible de supprimer des favoris. \(error), \(error.userInfo)")
        }
    }
    
    func countryFlagEmoji(forCountryCode countryCode: String) -> String? {
        let countryCodes: [String : String] = [
            "NED" : "NL",
            "FRA" : "FR",
            "GBR" : "GB",
            "ESP" : "ES",
            "CHN" : "CN",
            "JPN" : "JP",
            "FIN" : "FI",
            "AUS" : "AU",
            "GER" : "DE",
            "USA" : "US",
            "CAN" : "CA",
            "MON" : "MC",
            "MEX" : "MX",
            "THA" : "TH",
            "DEN" : "DK"
        ]
        
        guard let alpha2Code = countryCodes[countryCode] else { return "" }
        
        return alpha2Code.unicodeScalars.map { 127397 + $0.value }.compactMap(UnicodeScalar.init).map(String.init).joined()
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
