//
//  ViewController.swift
//  BudzkoVitaliTestTask
//
//  Created by Vitali Budzko on 30.05.2019.
//  Copyright © 2019 BudzkoVitali. All rights reserved.
//

import UIKit
import CoreLocation

// 1) Создать проект в bitbucket репозитории 2) реализовать получение данных погоды 3) отобразить полученнные данные в виде таблицы 4) получать посредством background fetch раз в 60 минут

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var forecastData = [Weather]()

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var submitButton: UIButton!
        
    @IBAction func submit(_ sender: Any) {
        
        if textField.text == "" {
            updateWeatherForLocation(location: "Minsk")
        } else {
            updateWeatherForLocation(location: textField.text!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        submitButton.layer.cornerRadius = 7
        
        updateWeatherForLocation(location: "Minsk")
    }
    
    func updateWeatherForLocation (location:String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                if let location = placemarks?.first?.location {
                    Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                        
                        if let weatherData = results {
                            self.forecastData = weatherData
                            print(self.forecastData)
                            
                            DispatchQueue.main.async {
                                self.table.reloadData()
                            }
                        }
                    })
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return forecastData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Calendar.current.date(byAdding: .day, value: section, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        
        return dateFormatter.string(from: date!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let weatherObject = forecastData[indexPath.row]
        
        cell.textLabel?.text = weatherObject.summary
        
        let temperature = Int((Double(weatherObject.temperature) - 32) / 1.8)
        
        cell.detailTextLabel?.text = "\(temperature)  °C"
        cell.imageView?.image = UIImage(named: weatherObject.icon)

        return cell
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

