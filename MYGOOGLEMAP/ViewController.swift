//
//  ViewController.swift
//  MYGOOGLEMAP
//
//  Created by Muhammad Irfan - External on 13/07/2022.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
// AIzaSyBIIEu8XbS2XaxOVCaQ_7pb-nkyXP-FAM4
class ViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating {
    let manager = CLLocationManager()
    let searchVC = UISearchController(searchResultsController: ResultViewController())
    
    var camera = GMSCameraPosition.camera(withLatitude: 0.0, longitude: 0.0, zoom: 1.0)
    var mapView = GMSMapView()
    let marker = GMSMarker()

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        
        title = "Maps"
        searchVC.searchBar.backgroundColor = .secondarySystemBackground
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else{
            return
        }
        let coordinates = location.coordinate
        camera = GMSCameraPosition.camera(withLatitude: coordinates.latitude, longitude: coordinates.longitude, zoom: 1.0)
        mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        view.addSubview(mapView)
        mapView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.size.width, height: view.frame.size.height - view.safeAreaInsets.top)

        // Creates a marker in the center of the map.
        marker.position = coordinates
        marker.title = "London"
        marker.snippet = "UK"
        marker.map = mapView
        print("Done")
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
        let vc = searchController.searchResultsController as? ResultViewController else{
            return
        }
        vc.delegate = self
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result{
            case .success(let places):
                DispatchQueue.main.async {
                    vc.update(places: places)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}

extension ViewController: ResultViewControllerDelegate{
    func didupdate(coordinate: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true, completion: nil)
        mapView.selectedMarker?.map = nil
        
        
       let newCamera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 6.0)
        mapView.camera = newCamera
        marker.position = coordinate
        marker.map = mapView
        
    }
}
