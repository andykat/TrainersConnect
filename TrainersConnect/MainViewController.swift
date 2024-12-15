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
    
//    var sensor: Sensor!
    var res: Float = 1.0
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var resistanceLabel: UILabel!
    @IBOutlet var resistanceSlider: UISlider!
    var connection = "disconnected"
//    fileprivate var services: [Service] = []
    
    fileprivate var sensors: [Sensor] = []
    var sensorCount: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SensorManager.instance.onSensorDiscovered.subscribe(with: self) { [weak self] sensor in
            guard let s = self else { return }
            print("found sensor")
            if !s.sensors.contains(sensor) {
                s.sensors.append(sensor)
                s.sensorCount.append(0)
                s.tableView.reloadData()
            }
        }
//        sensor.onServiceDiscovered.subscribe(with: self) { [weak self] sensor, service in
//            self?.rebuildData()
//        }
//        sensor.onStateChanged.subscribe(with: self) { [weak self] sensor in
//            self?.updateConnectButton()
//        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        //Get resistance slider value and set text
        res = resistanceSlider.value
        let formatted = String(format: "%.2f", res)
        resistanceLabel.text = formatted

        //update resistance to all connected bikes
        for s in sensors {
            guard let cyclingPowerService: CyclingPowerService = s.service() else { return }
            
            
            if let wahooTrainer = cyclingPowerService.wahooTrainer {
                wahooTrainer.setResistanceMode(resistance: res)
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        nameLabel.text = sensor.peripheral.name
        sensors = SensorManager.instance.sensors
        updateConnectButton()
        
        rebuildData()
    }
    
    fileprivate func rebuildData() {
//        services = Array(sensor.services.values)
        tableView.reloadData()
    }
    
    fileprivate func updateConnectButton() {
//        switch sensor.peripheral.state {
//        case .connected:
//            connectButton.setTitle("Connected", for: UIControl.State())
//            connectButton.isEnabled = true
//            CyclingPowerService.WahooTrainer.activate()
//        case .connecting:
//            connectButton.setTitle("Connecting", for: UIControl.State())
//            connectButton.isEnabled = false
//        case .disconnected:
//            connectButton.setTitle("Disconnected", for: UIControl.State())
//            connectButton.isEnabled = true
//            rebuildData()
//        case .disconnecting:
//            connectButton.setTitle("Disconnecting", for: UIControl.State())
//            connectButton.isEnabled = false
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
        CyclingPowerService.WahooTrainer.activate()
//        if sensor.peripheral.state == .connected {
//            SensorManager.instance.disconnectFromSensor(sensor)
//        } else if sensor.peripheral.state == .disconnected {
//            SensorManager.instance.connectToSensor(sensor)
////            CyclingPowerService.WahooTrainer.activate()
//        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let serviceDetails = segue.destination as? ServiceDetailsViewController {
//            guard let indexPath = tableView.indexPathForSelectedRow else { return }
//            if indexPath.row >= services.count { return }
//            serviceDetails.service = services[indexPath.row]
//        }
//    }
}



extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trainerCell = tableView.dequeueReusableCell(withIdentifier: "TrainerCell")!
        let sensor = sensors[indexPath.row]
        trainerCell.textLabel?.text = sensor.peripheral.name
        
        return trainerCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return services.count
        return sensors.count
    }
    
}

