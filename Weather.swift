//
//  Weather.swift
//  Clima
//
//  Created by Haven on 2022-04-04.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Weather {
    let cityName: String
    let cityCountry: String
    let temperature: Float
    let isMetric: Bool
    let weatherDesec: WeatherDescription
    
    var locationString: String {
        return "\(cityName), \(cityCountry)"
    }
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    init(json: JSON, isMetric: Bool) {
        self.cityName = json["name"].stringValue
        self.cityCountry = json["sys"]["country"].stringValue
        self.temperature = json["main"]["temp"].floatValue
        self.isMetric = isMetric
        self.weatherDesec = WeatherDescription(weatherJSON: json["weather"][0])
    }
}

struct WeatherDescription {
    let main: String
    let description: String
    var weatherIconName: String
    
    init (weatherJSON: JSON) {
        self.main = weatherJSON["main"].stringValue
        self.description = weatherJSON["description"].stringValue
        self.weatherIconName = ""
        
        let id = weatherJSON["id"].intValue
        weatherIconName = parseWeatherID(id: id)
    }
    
    func parseWeatherID(id: Int) -> String {
        print (id)
        var parsedImageName: String
        
        switch (id) {
        case 200...232:
            parsedImageName = "cloud.bolt.fill"
        case 300...321:
            parsedImageName = "cloud.drizzle.fill"
        case 500...531:
            parsedImageName = "cloud.rain.fill"
        case 600...622:
            parsedImageName = "cloud.snow.fill"
        case 711:
            parsedImageName = "smoke.fill"
        case 721:
            parsedImageName = "sun.haze.fill"
        case 731, 761:
            parsedImageName = "sun.dust.fill"
        case 741:
            parsedImageName = "cloud.fog.fill"
        case 800:
            parsedImageName = "sun.max.fill"
        case 801...804:
            parsedImageName = "cloud.fill"
        case 781:
            parsedImageName = "tornado"
        default:
            parsedImageName = "termometer"
        }
        return parsedImageName
    }
}
