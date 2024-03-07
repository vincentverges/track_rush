//
//  ViewController.swift
//  f1 infos
//
//  Created by Vincent Verges on 07/02/2024.
//

import UIKit
import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

class ViewController: UITableViewController {
    
    var meetingsResponse: [Meeting]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(RaceTableViewCell.self, forCellReuseIdentifier: "RaceCell")
        
        fetchAPI { [weak self] result in
            switch result {
            case .success(let data):
                //print("Data Receveid")
                self?.meetingsResponse = data
                DispatchQueue.main.async { [weak self] in
                    //let season = self?.returnedSeasonRaces?.season ?? "Unknow Season"
                    self?.title = "2023 Races \u{1F3CE}"
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching API: \(error.localizedDescription)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetingsResponse?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RaceCell", for: indexPath) as! RaceTableViewCell
        if let meeting = meetingsResponse?[indexPath.row] {
            cell.configure(with: meeting)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailRaceViewController {
            vc.meeting = meetingsResponse?[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fetchAPI(completion: @escaping (Result<[Meeting], Error>) -> Void) {
        guard let url = URL(string: "https://api.openf1.org/v1/meetings") else {
            completion(.failure(NSError(domain: "InvalidURLErrorDomain", code: 0, userInfo: nil)))
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: url) {(data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "HTTPErrorDomain", code: 0, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "DataErrorDomain", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
                
                do {
                    let decodeData = try jsonDecoder.decode([Meeting].self, from: data)
                    completion(.success(decodeData))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
}



class RaceTableViewCell: UITableViewCell {
    let raceRoundLabel = UILabel()
    let raceDateLabel = UILabel()
    let raceNameLabel = UILabel()
    let raceCircuitNameLabel = UILabel()
    let raceLocationLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView(arrangedSubviews: [raceRoundLabel, raceDateLabel, raceNameLabel, raceCircuitNameLabel, raceLocationLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = -4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        [raceRoundLabel, raceDateLabel, raceNameLabel, raceCircuitNameLabel, raceLocationLabel].forEach { label in
            label.numberOfLines = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with meeting: Meeting) {
        
        let countryCode = isoCountryCode(fromCountryName: meeting.countryName)
        let flagEmoji = countryCode.flatMap { countryFlagEmoji(fromCountryCode: $0) } ?? ""
        raceRoundLabel.text = "\(flagEmoji) \(meeting.meetingOfficialName)"
        raceRoundLabel.font = UIFont.systemFont(ofSize: 10)
        raceRoundLabel.textColor = .gray
        
        let dateText = readableDateOrDaysUntil(dateString: meeting.dateStart)
        raceDateLabel.text = dateText
    
        
        raceDateLabel.font = UIFont.systemFont(ofSize: 11)
        raceDateLabel.textColor = .gray
        raceNameLabel.text = meeting.meetingName
        raceNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        raceCircuitNameLabel.text = meeting.circuitShortName
        raceCircuitNameLabel.font = UIFont.systemFont(ofSize: 11)
        raceCircuitNameLabel.textColor = .gray
        raceLocationLabel.text = "\(meeting.countryName)"
        raceLocationLabel.font = UIFont.systemFont(ofSize: 11)
        raceLocationLabel.textColor = .gray
    }
    
    func readableDateOrDaysUntil(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "fr_FR")
        
        guard let targetDate = dateFormatter.date(from: dateString) else {
            print("Erreur de formatage de la date")
            return "Date Invalide"
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        if currentDate > targetDate {
            dateFormatter.dateFormat = "d MMMM yyyy 'à' HH:mm"
            return "Le \(dateFormatter.string(from: targetDate))"
        } else {
            let components = calendar.dateComponents([.day], from: currentDate, to: targetDate)
            if let day = components.day, day >= 0 {
                return "\(day) jour(s) restant(s)"
            } else {
                return "Date invalide"
            }
        }
        
    }
    
    
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

struct Meeting: Decodable {
    let meetingName: String
    let meetingOfficialName: String
    let location: String
    let countryKey: Int
    let countryCode: String
    let countryName: String
    let circuitKey: Int
    let circuitShortName: String
    let dateStart: String
    let gmtOffset: String
    let meetingKey: Int
    let year: Int
}
