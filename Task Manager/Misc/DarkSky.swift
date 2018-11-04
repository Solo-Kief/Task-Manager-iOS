//  DarkSky.swift
//  Task Manager
//
//  Created by Solomon Kieffer on 11/3/18.
//  Copyright © 2018 Phoenix Development. All rights reserved.

import Foundation
import SwiftyJSON
import Alamofire

private let darkSkyKey = "3cefbd324e1163f2774db3b98731fe84"
private let darkSkyURL = "https://api.darksky.net/forecast/"

class DarkSky {
    static func getWeather(latitude: Double?, longitude: Double?, onCompletion: @escaping (WeatherData?) -> Void) {
        guard latitude != nil && longitude != nil else {return}
        
        let url = darkSkyURL + darkSkyKey + "/" + String(latitude!) + "," + String(longitude!)
        
        let request = Alamofire.request(url)
        
        request.responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let weatherData = WeatherData(json: json)
                onCompletion(weatherData)
            case .failure(let error):
                print(error.localizedDescription)
                onCompletion(nil)
            }
        }
    }
}
