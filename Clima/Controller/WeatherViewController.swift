//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var temperatureUnit: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    var weatherHandler: WeatherInfoHandler?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let locale = NSLocale.current
        weatherHandler = WeatherInfoHandler(useMetric: true)//locale.usesMetricSystem)
        
        searchTextfield.delegate = self
        weatherHandler?.delegate = self
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchTextfield.endEditing(true);
    }
    
    @IBAction func currentLocationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    func handleWeatherSearch(location: String?) {
        if location != nil {
            //print(weatherHandler?.getResult(cityName: location!, after: didUpdateWeather))
            print(weatherHandler?.getResult(of: location!))
        }
    }
}

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextfield.endEditing(true);
        return true;
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            textField.placeholder = "Type something"
            return false
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        handleWeatherSearch(location: textField.text)
        searchTextfield.text = ""
    }
}

extension WeatherViewController: WeatherInfoHandlerDelegate {
    func didUpdateWeather(weather: Weather) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.cityLabel.text = weather.locationString
            self.temperatureUnit.text = weather.isMetric ? "C" : "F"
            self.conditionImageView.image = UIImage.init(systemName: weather.weatherDesec.weatherIconName)
            self.mainLabel.text = weather.weatherDesec.main
            self.descriptionLabel.text = weather.weatherDesec.description
        }
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            
            weatherHandler?.getResult(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print (error)
    }
}
