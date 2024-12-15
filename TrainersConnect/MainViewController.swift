//
//  MainViewController.swift
//  TrainersConnect
//
//  Created by Andrew Zhang on 12/14/24.
//

import Foundation
import UIKit
import SwiftySensors
import SwiftySensorsTrainers
class MainViewController: UIViewController {
    var res: Float = 1.0
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var resistanceLabel: UILabel!
    @IBOutlet var resistanceSlider: UISlider!
    var connection = "disconnected"
    
    fileprivate var sensors: [Sensor] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        SensorManager.instance.onSensorDiscovered.subscribe(with: self) { [weak self] sensor in
            guard let s = self else { return }
            print("found sensor")
            if !s.sensors.contains(sensor) {
                s.sensors.append(sensor)
                s.tableView.reloadData()
            }
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        //Get resistance slider value and set text
        res = resistanceSlider.value
        let formatted = String(format: "%.2f", res)
        resistanceLabel.text = formatted

        //update resistance to all connected bikes
        for s in sensors {
            //checks if the trainer has cyclingpowerservice active
            guard let cyclingPowerService: CyclingPowerService = s.service() else { return }
            
            //sets new resistance on trainer
            if let wahooTrainer = cyclingPowerService.wahooTrainer {
                wahooTrainer.setResistanceMode(resistance: res)
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //refresh all the UI
        sensors = SensorManager.instance.sensors
        updateConnectButton()
        
        rebuildData()
    }
    
    fileprivate func rebuildData() {
//        services = Array(sensor.services.values)
        tableView.reloadData()
    }
    
    fileprivate func updateConnectButton() {
        switch connection {
            case "disconnected":
                connectButton.setTitle("Disconnected", for: UIControl.State())
                connectButton.isEnabled = true
                rebuildData()
            case "connected":
                connectButton.setTitle("Connected", for: UIControl.State())
                connectButton.isEnabled = true
            default:
                break
        }
    }
    
    @IBAction func connectButtonHandler(_ sender: AnyObject) {
        for s in sensors {
            if connection == "connected" {
                SensorManager.instance.disconnectFromSensor(s)
                print("\(String(describing: s.peripheral.name)) disconnected")
            }
            else if connection == "disconnected" {
                SensorManager.instance.connectToSensor(s)
                print("\(String(describing: s.peripheral.name)) connected")
            }
        }
        if connection == "connected" {
            connection = "disconnected"
        }
        else {
            connection = "connected"
        }
        updateConnectButton()
        
        //needs to be run before using cycling
        CyclingPowerService.WahooTrainer.activate()
    }
}



extension MainViewController: UITableViewDataSource {
    
    //UI for a row of the table
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trainerCell = tableView.dequeueReusableCell(withIdentifier: "TrainerCell")!
        let sensor = sensors[indexPath.row]
        trainerCell.textLabel?.text = sensor.peripheral.name
        
        return trainerCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }
    
}

