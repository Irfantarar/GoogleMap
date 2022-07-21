//
//  AppleMapVC.swift
//  MYGOOGLEMAP
//
//  Created by Muhammad Irfan - External on 14/07/2022.
//

import UIKit
import MapKit

class AppleMapVC: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let manager = CLLocationManager()
    @IBOutlet weak var address: UILabel!
    var previousLocation: CLLocation?
    
    let searchController = UISearchController(searchResultsController: ResultViewController())
        
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        previousLocation = getcentreLoc(mapview: mapView)
        
        title = "Maps"
        searchController.searchBar.backgroundColor = .secondarySystemBackground
        navigationItem.searchController = searchController
        // Do any additional setup after loading the view.
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{
            return
        }
        let coordinates = location.coordinate

        let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: 1000000, longitudinalMeters: 1000000)
        mapView.setRegion(region, animated: true)

    }
    
    func getcentreLoc(mapview: MKMapView)-> CLLocation{
        let latitude = mapview.centerCoordinate.latitude
        let longitude = mapview.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    @IBAction func refresh(_ sender: Any) {
        let center = CLLocationCoordinate2D(latitude: 51.5072, longitude: 0.1276)

            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

            self.mapView.setRegion(region, animated: true)
    }
    
}

extension AppleMapVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getcentreLoc(mapview: mapView)
        let geocoder = CLGeocoder()
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geocoder.reverseGeocodeLocation(center) { [weak self] placemarks, error in
            guard let self = self else{ return}
            
            if let e = error
            {
                print(e.localizedDescription)
                return
            }
            
            guard let placemarkss = placemarks?.first else{
                return
            }
            
            let streetNumber = placemarkss.subThoroughfare ?? ""
            let streetName = placemarkss.thoroughfare ?? ""
            DispatchQueue.main.async {
                self.address.text = "\(streetNumber) \(streetName)"
            }
        }
    }
    
}
