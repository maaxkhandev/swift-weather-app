//
//  WeatherManager.swift
//  Clima
//
//  Created by Maaz Khan on 30/05/2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherMagager: WeatherManager, weather: WeatherModel)
    func didFailWithError (error: Error)
}

struct WeatherManager {
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b94100169dd50d57f73bb3b0a6994dc9&units=metric"
    var delegate: WeatherManagerDelegate?
    func fetchWeather (cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude:CLLocationDegrees ){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest (with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task =  session.dataTask(with: url) { (data,response, error) in
                if error != nil {
                    print(error!)
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if  let weather =   self.parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON (weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
         let decodedData =   try  decoder.decode(WeatherData.self, from: weatherData)
        let id = decodedData.weather[0].id
        let temp = decodedData.main.temp
        let name = decodedData.name
       let weather = WeatherModel(conditionId: id, cityName: name, temprature: temp)
            
          return weather
        } catch {
            print(error)
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
   
}
