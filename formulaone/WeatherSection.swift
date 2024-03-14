//
//  WeatherSection.swift
//  formulaone
//
//  Created by Vincent Verges on 07/03/2024.
//

import UIKit

class WeatherSection: UITableViewCell {
    @IBOutlet var weatherTitleView: UILabel!
    
    @IBOutlet var airTemperatureView: UILabel!
    @IBOutlet var trackTempertatureView: UILabel!
    @IBOutlet var windSpeedView: UILabel!
    @IBOutlet var windDirectionView: UILabel!
    @IBOutlet var rainFallView: UILabel!
    @IBOutlet var huimidityView: UILabel!
    
    @IBOutlet var airTemperatureTitleView: UILabel!
    @IBOutlet var trackTemperatureTitle: UILabel!
    @IBOutlet var windSpeedTitleView: UILabel!
    @IBOutlet var windDirectionTitleView: UILabel!
    @IBOutlet var rainfallTitleView: UILabel!
    @IBOutlet var humidityTitleView: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        weatherTitleView.font = UIFont.boldSystemFont(ofSize: 18)
        airTemperatureView.font = UIFont.boldSystemFont(ofSize: 18)
        trackTempertatureView.font = UIFont.boldSystemFont(ofSize: 18)
        windSpeedView.font = UIFont.boldSystemFont(ofSize: 18)
        windDirectionView.font = UIFont.boldSystemFont(ofSize: 18)
        rainFallView.font = UIFont.boldSystemFont(ofSize: 18)
        huimidityView.font = UIFont.boldSystemFont(ofSize: 18)
        
        airTemperatureTitleView.font = UIFont.systemFont(ofSize: 14)
        airTemperatureTitleView.textColor = UIColor.gray
        trackTemperatureTitle.font = UIFont.systemFont(ofSize: 14)
        trackTemperatureTitle.textColor = UIColor.gray
        windSpeedTitleView.font = UIFont.systemFont(ofSize: 14)
        windSpeedTitleView.textColor = UIColor.gray
        windDirectionTitleView.font = UIFont.systemFont(ofSize: 14)
        windDirectionTitleView.textColor = UIColor.gray
        rainfallTitleView.font = UIFont.systemFont(ofSize: 14)
        rainfallTitleView.textColor = UIColor.gray
        humidityTitleView.font = UIFont.systemFont(ofSize: 14)
        humidityTitleView.textColor = UIColor.gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
