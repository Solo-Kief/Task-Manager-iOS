//  WeatherData.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 11/3/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import Foundation
import SwiftyJSON

class WeatherData {
    enum weatherCondition: String {
        case Day = "clear-day"
        case Night = "clear-night"
        case Rain = "rain"
        case Snow = "snow"
        case Sleet = "sleet"
        case Wind = "wind"
        case Fog = "fog"
        case Cloudy = "cloudy"
        case Partly_Cloudy_Day = "partly-cloudy-day"
        case Partly_Cloudy_Night = "partly-cloudy-night"
        
        var icon: String {
            switch self {
            case .Day:
                return "☀️"
            case .Night:
                return "🌑"
            case .Rain:
                return "🌧"
            case .Snow:
                return "❄️"
            case .Sleet:
                return "❄️"
            case .Wind:
                return "💨"
            case .Fog:
                return "🌫"
            case .Cloudy:
                return "☁️"
            case .Partly_Cloudy_Day:
                return "⛅️"
            case .Partly_Cloudy_Night:
                return "🌑"
            }
        }
    }
    
    //MARK:- Properties
    let temperature: Double?
    let highTemperature: Double?
    let lowTemperature: Double?
    let condition: weatherCondition?
    
    //MARK:- Initializers
    init(json: JSON) {
        let temperature = json["currently"]["temperature"].double
        let highTemperature = json["daily"]["data"][0]["temperatureHigh"].double
        let lowTemperature = json["daily"]["data"][0]["temperatureLow"].double
        let condition = weatherCondition(rawValue: json["currently"]["icon"].string!)
        
        self.temperature = temperature
        self.highTemperature = highTemperature
        self.lowTemperature = lowTemperature
        self.condition = condition
    }
}
