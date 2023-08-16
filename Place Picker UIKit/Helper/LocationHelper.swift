//
//  LocationHelper.swift
//  Place Picker UIKit
//
//  Created by Rafli on 13/08/23.
//

import Foundation
import CoreLocation

class LocationHelper {
    
    func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let earthRadiusKm: Double = 6371.0
        
        let dLat = degreesToRadians(lat2 - lat1)
        let dLon = degreesToRadians(lon2 - lon1)
        
        let lat1Rad = degreesToRadians(lat1)
        let lat2Rad = degreesToRadians(lat2)
        
        let a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1Rad) * cos(lat2Rad)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let distance = earthRadiusKm * c
        
        return round(distance * 100) / 100
    }
    
   
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    func inCoverStartRadius(target: CLLocationCoordinate2D, currentLocation:CLLocationCoordinate2D, radius:Int) -> Bool{
        
        let distance = calculateDistance(lat1: target.latitude, lon1: target.longitude, lat2: currentLocation.latitude, lon2: currentLocation.longitude)
        if Int(distance) <= radius {
            return true
        }
        
        return false
    }
    
    func getAddressFromCoordinates(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard error == nil else {
                print("Reverse geocoding error: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                // Construct the address using placemark properties
                var address = ""
                if let name = placemark.name {
                    address += name + ", "
                }
                if let thoroughfare = placemark.thoroughfare {
                    address += thoroughfare + ", "
                }
                if let locality = placemark.locality {
                    address += locality + ", "
                }
                if let administrativeArea = placemark.administrativeArea {
                    address += administrativeArea + ", "
                }
                if let postalCode = placemark.postalCode {
                    address += postalCode + ", "
                }
                if let country = placemark.country {
                    address += country
                }
                
                completion(address)
            } else {
                completion(nil)
            }
        }
    }
    

    func convertFromStringListCoordinate(_ routeString:String) -> [CLLocationCoordinate2D] {
        // Convert the route string to a list of CLLocationCoordinate2D
        var coordinates: [CLLocationCoordinate2D] = []
        
        if let data = routeString.data(using: .utf8),
           let routeArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String]] {
            for coordinateArray in routeArray {
                if coordinateArray.count == 2,
                   let latitude = Double(coordinateArray[0]),
                   let longitude = Double(coordinateArray[1]) {
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    coordinates.append(coordinate)
                }
            }
        }
        
        return coordinates
    }
    
}
