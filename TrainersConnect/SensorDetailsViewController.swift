//
//  SensorDetaislViewController.swift
//  TrainersConnect
//
//  Created by Andrew Zhang on 12/2/24.
//

import UIKit
import SwiftySensors
import SwiftySensorsTrainers
class SensorDetailsViewController: UIViewController {
    
    var sensor: Sensor!
    var res: Float = 1.0
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var resistanceLabel: UILabel!
    @IBOutlet var resistanceSlider: UISlider!
    fileprivate var services: [Service] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sensor.onServiceDiscovered.subscribe(with: self) { [weak self] sensor, service in
            self?.rebuildData()
        }
        sensor.onStateChanged.subscribe(with: self) { [weak self] sensor in
            self?.updateConnectButton()
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
//        Service cyclingSpeedService = sensor.
        guard let cyclingPowerService: CyclingPowerService = sensor.service() else { return }
//
//        CyclingPowerService.WahooTrainer.setResistanceMode(<#T##self: CyclingPowerService.WahooTrainer##CyclingPowerService.WahooTrainer#>)
        
        res = resistanceSlider.value
        let formatted = String(format: "%.2f", res)
        resistanceLabel.text = formatted
        
        if let wahooTrainer = cyclingPowerService.wahooTrainer {
           wahooTrainer.setResistanceMode(resistance: res)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.text = sensor.peripheral.name
        updateConnectButton()
        
        rebuildData()
    }
    
    fileprivate func rebuildData() {
        services = Array(sensor.services.values)
        tableView.reloadData()
    }
    
    fileprivate func updateConnectButton() {
        switch sensor.peripheral.state {
        case .connected:
            connectButton.setTitle("Connected", for: UIControl.State())
            connectButton.isEnabled = true
            CyclingPowerService.WahooTrainer.activate()
        case .connecting:
            connectButton.setTitle("Connecting", for: UIControl.State())
            connectButton.isEnabled = false
        case .disconnected:
            connectButton.setTitle("Disconnected", for: UIControl.State())
            connectButton.isEnabled = true
            rebuildData()
        case .disconnecting:
            connectButton.setTitle("Disconnecting", for: UIControl.State())
            connectButton.isEnabled = false
        @unknown default:
            break
        }
    }
    
    @IBAction func connectButtonHandler(_ sender: AnyObject) {
        if sensor.peripheral.state == .connected {
            SensorManager.instance.disconnectFromSensor(sensor)
        } else if sensor.peripheral.state == .disconnected {
            SensorManager.instance.connectToSensor(sensor)
//            CyclingPowerService.WahooTrainer.activate()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let serviceDetails = segue.destination as? ServiceDetailsViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            if indexPath.row >= services.count { return }
            serviceDetails.service = services[indexPath.row]
        }
    }
}



extension SensorDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let serviceCell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell")!
        let service = services[indexPath.row]
        
        serviceCell.textLabel?.text = "\(service)".components(separatedBy: ".").last
        return serviceCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
}

