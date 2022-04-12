//
//  WeatherInfoHandler.swift
//  Clima
//
//  Created by Haven on 2022-03-26.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol WeatherInfoHandlerDelegate {
    func didUpdateWeather(weather: Weather)
}

struct WeatherInfoHandler {
    let secretAPIKey = ""
    let currentWeatherAPIURL = "https://api.openweathermap.org/data/2.5/weather?"
    let geocodingAPIURL = "https://api.openweathermap.org/geo/1.0/direct?"
    let useMetric: Bool
    var delegate: WeatherInfoHandlerDelegate?
    
    enum HttpRequestError: Error {
        case NoData, invalidURL
    }
    
    init (useMetric: Bool) {
        self.useMetric = useMetric
    }
    
    func getResult(of cityName: String) {
        getLanLonFromCityName(of: cityName)
    }
    
    func getResult(lat: Double, lon: Double) {
        getWeatherOf(lat: lat, lon: lon)
    }
    
    func getWeatherOf(lat: Double, lon: Double) {
        let weatherAPI = generateCurrentWeatherAPI(lat: lat, lon: lon)
        httpRequest(to: weatherAPI) { result in
            switch (result) {
            case .success(let json):
                delegate?.didUpdateWeather(weather: Weather(json: json, isMetric: useMetric))
            case .failure(let error):
                print ("Error occured! \(error)")
            }
        }
    }
    
    func getLanLonFromCityName(of cityName: String) {
        let apiURL = generateGeocodingAPI(cityName: cityName, searchLimit: 1)
        httpRequest(to: apiURL) { result in
            switch (result) {
            case .success(let json):
                let lat = json[0]["lat"].doubleValue
                let lon = json[0]["lon"].doubleValue
                getWeatherOf(lat: lat, lon: lon)
            case .failure(let error):
                print ("Error occured! \(error)")
            }
        }
    }
    
    func buildParameter(baseURL: String, newParams: String...) -> String {
        var resultURL = baseURL
        for param in newParams {
            resultURL += (param + "&")
        }
        
        return String(resultURL.dropLast())
    }
    
    func generateGeocodingAPI(cityName: String, searchLimit: Int) -> String {
        return buildParameter(
            baseURL: geocodingAPIURL,
            newParams: "appid=\(secretAPIKey)","q=\(cityName)", "limit=\(searchLimit)")
    }
    
    func generateCurrentWeatherAPI(lat: Double, lon: Double) -> String{
        return buildParameter(
            baseURL: currentWeatherAPIURL,
            newParams: "appid=\(secretAPIKey)","lat=\(lat)", "lon=\(lon)", (useMetric ? "units=metric" : "units=imperial") )
    }
    
    // < iOS 15.0 (Swift 5.5)
    //    static func fetchJSONDataFromURL(url: String) async throws -> JSON? {
    //        guard let url = URL(string: url) else {
    //            return nil
    //        }
    //        let (data, _) = try await URLSession.shared.data(from: url)
    //        let iTunesResult = try JSONDecoder().decode(ITunesResult.self, from: data)
    //        return iTunesResult.results
    //    }
    
    func httpRequest(to url: String, completion: @escaping (Result<JSON, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(HttpRequestError.invalidURL))
            return
        }
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard data != nil else {
                completion(.failure(HttpRequestError.NoData))
                return
            }
            
            do {
                let jsonObject = try JSON(data: data!)
                completion(.success(jsonObject))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
