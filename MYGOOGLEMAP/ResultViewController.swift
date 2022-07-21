//
//  ResultViewController.swift
//  MYGOOGLEMAP
//
//  Created by Muhammad Irfan - External on 13/07/2022.
//

import UIKit
import CoreLocation

protocol ResultViewControllerDelegate: AnyObject{
    func didupdate(coordinate: CLLocationCoordinate2D)
}

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate: ResultViewControllerDelegate?
    private var place: [Places] = []
    
    private let tableview : UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLayoutSubviews() {
        tableview.frame = view.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableview)
        view.backgroundColor = .clear
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    public func update(places: [Places]){
        self.tableview.isHidden = false
        self.place = places
        print(places.count)
        tableview.reloadData()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return place.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = place[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        tableview.isHidden = true
        let place = place[indexPath.row]
        GooglePlacesManager.shared.resolveLoc(place: place) { result in
            switch result{
            case .success(let coordinates):
                DispatchQueue.main.async {
                    self.delegate?.didupdate(coordinate: coordinates)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}
