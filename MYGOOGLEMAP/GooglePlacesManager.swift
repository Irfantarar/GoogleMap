//
//  GooglePlacesManager.swift
//  MYGOOGLEMAP
//
//  Created by Muhammad Irfan - External on 13/07/2022.
//

import Foundation
import GooglePlaces
import CoreLocation

struct Places{
    let name: String
    let identifier: String
}

final class GooglePlacesManager{
    static let shared = GooglePlacesManager()
    private let client = GMSPlacesClient.shared()
    
    
    private init() {}
    
    
    public func findPlaces(query: String, completion: @escaping (Result<[Places], Error>) -> Void ){
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) { results, error in
            guard let result = results, error == nil else{
                completion(.failure(error!))
                return
            }
            let place: [Places] = result.compactMap({ Places(
                name: $0.attributedFullText.string,
                identifier: $0.placeID
            )
            })
            completion(.success(place)) 
        }
    }
    
    public func resolveLoc(place: Places, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void){
        client.fetchPlace(fromPlaceID: place.identifier, placeFields: .coordinate, sessionToken: nil) { googlePlace, error in
            guard let googlePlace = googlePlace, error == nil else {
                completion(.failure(error!))
                return
            }
            let corrdinate = CLLocationCoordinate2D(
                latitude: googlePlace.coordinate.latitude,
                longitude: googlePlace.coordinate.longitude)
            completion(.success(corrdinate))
        }
    }

    
}
