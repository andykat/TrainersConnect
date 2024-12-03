//
//  ServiceDetailsViewController.swift
//  TrainersConnect
//
//  Created by Andrew Zhang on 12/2/24.
//


import UIKit
import SwiftySensors
import SwiftySensorsTrainers

class ServiceDetailsViewController: UIViewController {
    
    var service: Service!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    fileprivate var characteristics: [Characteristic] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        service.sensor.onCharacteristicDiscovered.subscribe(with: self) { [weak self] sensor, characteristic in
            self?.rebuildData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.text = "\(service!)".components(separatedBy: ".").last
        
        rebuildData()
    }
    
    fileprivate func rebuildData() {
        characteristics = Array(service.characteristics.values)
        tableView.reloadData()
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let charViewController = segue.destination as? CharacteristicViewController {
//            guard let indexPath = tableView.indexPathForSelectedRow else { return }
//            if indexPath.row >= characteristics.count { return }
//            charViewController.characteristic = characteristics[indexPath.row]
//        }
//    }
    
}



extension ServiceDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let charCell = tableView.dequeueReusableCell(withIdentifier: "CharCell")!
        let characteristic = characteristics[indexPath.row]
        
        charCell.textLabel?.text = "\(characteristic)".components(separatedBy: ".").last
        return charCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characteristics.count
    }
    
}
