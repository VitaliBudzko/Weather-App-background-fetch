//
//  WeatherSets.swift
//  BudzkoVitaliTestTask
//
//  Created by Vitali Budzko on 31.05.2019.
//  Copyright © 2019 BudzkoVitali. All rights reserved.
//

import Foundation
import CoreLocation

// de0f03c2b16f8f43f7a5e1849593679d - my key for dark sky API

struct Weather {
    let summary:String
    let icon:String
    let temperature:Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json:[String:Any]) throws {
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        guard let temperature = json["temperatureMax"] as? Double else {throw SerializationError.missing("temp is missing")}
        
        self.summary = summary
        self.icon = icon
        self.temperature = temperature
    }
    
    static let basePath = "https://api.darksky.net/forecast/de0f03c2b16f8f43f7a5e1849593679d/"
    
    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()) {
        
        let url = basePath + "\(location.latitude),\(location.longitude)"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
                                        forecastArray.append(weatherObject)
                                        print(forecastArray)
                                    }
                                }
                            }
                        }
                    }
                }catch {
                    print(error.localizedDescription)
                }
                completion(forecastArray)
            }
        }
        task.resume()
    }
}
