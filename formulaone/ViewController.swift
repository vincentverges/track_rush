//
//  ViewController.swift
//  f1 infos
//
//  Created by Vincent Verges on 07/02/2024.
//

import UIKit
import Foundation

class ViewController: UITableViewController {
    
    var returnedSeasonRaces: RaceTable?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(RaceTableViewCell.self, forCellReuseIdentifier: "RaceCell")
        
        fetchAPI { [weak self] result in
            switch result {
            case .success(let data):
                print("Data Receveid")
                self?.returnedSeasonRaces = data
                DispatchQueue.main.async { [weak self] in
                    let season = self?.returnedSeasonRaces?.season ?? "Unknow Season"
                    self?.title = "\(season) Races"
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching API: \(error.localizedDescription)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return returnedSeasonRaces?.races.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RaceCell", for: indexPath) as! RaceTableViewCell
        if let race = returnedSeasonRaces?.races[indexPath.row] {
            cell.configure(with: race)
        }
        return cell
    }
    
    
    func fetchAPI(completion: @escaping (Result<RaceTable, Error>) -> Void) {
        
        if let url = URL(string: "https://ergast.com/api/f1/2024.json") {
            let session = URLSession.shared
            let task = session.dataTask(with: url) { [weak self] (data, response, error) in
                
                guard self != nil else {
                    return
                }
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "HTTPErrorDomain", code: 0, userInfo: nil)))
                    return
                }
                
                //print("HTTP RESPONSE STATUS CODE: \(httpResponse.statusCode)")
                      
                guard httpResponse.statusCode == 200 else {
                    completion(.failure(NSError(domain: "HTTPErrorDomain", code: httpResponse.statusCode, userInfo: nil)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "HTTPErrorDomain", code: 0, userInfo: nil)))
                    return
                }
                
                //print("Receveid Data: \(String(data: data, encoding: .utf8) ?? "")")
                
                do {
                    let jsonDecoder = JSONDecoder()
                    let decodeData = try jsonDecoder.decode(F1ApiResponse.self, from: data)
                    completion(.success(decodeData.mrData.raceTable))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        } else {
            completion(.failure(NSError(domain: "InvalidURLErrorDomain", code: 0, userInfo: nil)))
        }
        
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
    
    func configure(with race: Race) {
        
        
        raceRoundLabel.text = "Round \(race.round)"
        raceRoundLabel.font = UIFont.systemFont(ofSize: 11)
        raceRoundLabel.textColor = .gray
        if let dayRemaining = daysUntil(dateString: race.date) {
            raceDateLabel.text = "\(String(describing: dayRemaining)) days until the race"
        } else {
            print("Impossible de calculer le nombre de jours restants")
            raceDateLabel.text = race.date
        }
        
        raceDateLabel.font = UIFont.systemFont(ofSize: 11)
        raceDateLabel.textColor = .gray
        raceNameLabel.text = race.raceName
        raceNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        raceCircuitNameLabel.text = race.circuit.circuitName
        raceCircuitNameLabel.font = UIFont.systemFont(ofSize: 11)
        raceCircuitNameLabel.textColor = .gray
        raceLocationLabel.text = "\(race.circuit.location.locality), \(race.circuit.location.country)"
        raceLocationLabel.font = UIFont.systemFont(ofSize: 11)
        raceLocationLabel.textColor = .gray
    }
    
    func daysUntil(dateString: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let targetDate = dateFormatter.date(from: dateString) else {
            print("Erreur de formatage de la date")
            return nil
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
        let currentDateOnly = calendar.date(from: currentDateComponents)!
        let components = calendar.dateComponents([.day], from: currentDateOnly, to: targetDate)
        
        return components.day
    }
}

struct F1ApiResponse: Decodable {
    let mrData: MRData
    
    private enum CodingKeys: String, CodingKey {
        case mrData = "MRData"
    }
}

struct MRData: Decodable {
    let raceTable: RaceTable
    
    private enum CodingKeys: String, CodingKey {
        case raceTable = "RaceTable"
    }
}

struct RaceTable: Decodable {
    let season: String
    let races: [Race]
    
    private enum CodingKeys: String, CodingKey {
        case season = "season"
        case races = "Races"
    }
}

struct Race: Decodable {
    let season: String
    let round: String
    let url: String
    let raceName: String
    let circuit: Circuit
    let date: String
    
    private enum CodingKeys: String, CodingKey {
        case season = "season"
        case round = "round"
        case url = "url"
        case raceName = "raceName"
        case circuit = "Circuit"
        case date = "date"
    }
}

struct Circuit: Decodable {
    let circuitId: String
    let url: String
    let circuitName: String
    let location: Location
    
    private enum CodingKeys: String, CodingKey {
        case circuitId = "circuitId"
        case url = "url"
        case circuitName = "circuitName"
        case location = "Location"
    }
}

struct Location: Decodable {
    let lat: String
    let long: String
    let locality: String
    let country: String
    
    private enum CodingKeys: String, CodingKey {
        case lat = "lat"
        case long = "long"
        case locality = "locality"
        case country = "country"
    }
}
