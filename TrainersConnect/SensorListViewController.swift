//
//  SensorListViewController.swift
//  SwiftySensorsExample
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import UIKit
import SwiftySensors
import SwiftySensorsTrainers
import CoreBluetooth

class SensorListViewController: UITableViewController {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sensors = SensorManager.instance.sensors
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sensorCell = tableView.dequeueReusableCell(withIdentifier: "SensorCell")!
        let sensor = sensors[indexPath.row]
        sensorCell.textLabel?.text = sensor.peripheral.name
        return sensorCell
    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let sensorCell = tableView.dequeueReusableCell(withIdentifier: "SensorCell")!
//        let sensor = sensors[indexPath.row]
//        
//        sensorCell.textLabel?.text = sensor.peripheral.name
//        if sensorCount[indexPath.row] == 0 {
//            var cellButton: UIButton!
//            cellButton = UIButton(frame: CGRect(x: 5, y: 5, width: 50, height: 30))//5, 5, 50, 30
//            cellButton.setTitle("Connect", for: UIControl.State.normal)
//            sensorCell.addSubview(cellButton)
//            sensorCell.accessoryView = cellButton
//            cellButton.backgroundColor = UIColor.blue
//        }
//        
//        return sensorCell
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sensorDetails = segue.destination as? SensorDetailsViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            if indexPath.row >= sensors.count { return }
            sensorDetails.sensor = sensors[indexPath.row]
        }
    }
    
}
