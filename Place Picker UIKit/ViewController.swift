//
//  ViewController.swift
//  Place Picker UIKit
//
//  Created by Rafli on 13/08/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var tableViewSearchLocation: TableViewAdjustedHeight!
    @IBOutlet weak var searchBarLocation: UISearchBar!
    @IBOutlet weak var buttonUseLocation: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelSelectedLocation: UILabel!
    @IBOutlet weak var viewMyLocation: UIView!
    @IBOutlet weak var mapKit: MKMapView!
    
    
    //MARK: - Maps Variables
    private var locationManager = CLLocationManager()
    private var locationHelper = LocationHelper()
    private var marker: MKPointAnnotation?
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    
    //MARK: - Variables
    private var selectedCoordiante: CLLocationCoordinate2D!
    private var selectedAddress = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGesture()
        
        setupLocationManager()
        setupGesture()
        setupTableView()
        setupSearchPlace()
        
        mapKit.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupView()
    }
    
    func showErrorAlert(message: String) {
        // Display an alert with the error message
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func setupView() {
        activityIndicator.isHidden = true
        buttonUseLocation.isEnabled = false
        
    }
    
    private func setupSearchPlace() {
        searchCompleter.delegate = self
        searchBarLocation.delegate = self
    }
    
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mapKit.addGestureRecognizer(longPressGesture)
        
        viewMyLocation.addTapGesture {
            self.locationManager.startUpdatingLocation()
            self.locationManager.requestLocation()
        }

    }
    
    private func setupTableView() {
        tableViewSearchLocation.delegate = self
        tableViewSearchLocation.dataSource = self
        tableViewSearchLocation.reloadData()
    }
    
    private func resetSearch() {
        searchResults.removeAll()
        tableViewSearchLocation.reloadData()
    }
    
    private func showLoadingView() {
        labelSelectedLocation.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        self.buttonUseLocation.isEnabled = false
    }
    
    private func removeLoadingView() {
        labelSelectedLocation.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        self.buttonUseLocation.isEnabled = true
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func updateMarkerPosition(coordinate: CLLocationCoordinate2D) {
        selectedCoordiante = coordinate
        
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapKit.setRegion(coordinateRegion, animated: true)
        
        locationHelper.getAddressFromCoordinates(latitude: selectedCoordiante.latitude, longitude: selectedCoordiante.longitude, completion: { startLocation in
            self.selectedAddress = startLocation ?? ""
            self.labelSelectedLocation.text = self.selectedAddress
            self.buttonUseLocation.isEnabled = true
        })
        
        if marker == nil {
            marker = MKPointAnnotation()
            mapKit.addAnnotation(marker!)
        }
        
        marker?.coordinate = coordinate
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapKit)
            let coordinates = mapKit.convert(touchPoint, toCoordinateFrom: mapKit)
            
            updateMarkerPosition(coordinate: coordinates)
        }
        
    }
    
    
    @IBAction func buttonUseLocationTapped(_ sender: UIButton) {
    }
    
}


extension ViewController: MKMapViewDelegate {
    
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showErrorAlert(message: "Lokasi tidak ditemukan, silahkan beri ijin aplikasi untuk mengkses lokasi anda")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationSafe = locations.last {
            locationManager.stopUpdatingLocation()
            
            if let selectedCoordiante = selectedCoordiante {
                updateMarkerPosition(coordinate: selectedCoordiante)
                let coordinateRegion = MKCoordinateRegion(center: selectedCoordiante, latitudinalMeters: 800, longitudinalMeters: 800)
                mapKit.setRegion(coordinateRegion, animated: true)
            }else {
                
                selectedCoordiante = locationSafe.coordinate
                
                updateMarkerPosition(coordinate: locationSafe.coordinate)
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewSearchLocation.isHidden = searchResults.isEmpty
        
        if searchResults.count > 7 {
            return 6
        }else {
            return searchResults.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showLoadingView()
        let searchCompletion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: searchCompletion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            if let error = error {
                print("Error performing local search: \(error.localizedDescription)")
                return
            }
            
            if let mapItems = response?.mapItems, let firstItem = mapItems.first {
                let coordinate = firstItem.placemark.coordinate
                //                   let latitude = coordinate.latitude
                //                   let longitude = coordinate.longitude
                
                self.searchBarLocation.text = ""
                self.resetSearch()
                self.updateMarkerPosition(coordinate: coordinate)
                self.removeLoadingView()
            } else {
                self.removeLoadingView()
                self.showErrorAlert(message: "No coordinates found for this search completion.")
            }
        }
    }
    
}


extension ViewController: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableViewSearchLocation.reloadData()
    }
    
    private func completer(completer: MKLocalSearchCompleter, didFailWithError error: NSError) {
        // handle error
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        let query = searchBar.text ?? ""
        if query.isEmpty {
            resetSearch()
        }
        
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resetSearch()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query = searchBar.text ?? ""
        if query.isEmpty {
            resetSearch()
        }else {
            searchCompleter.queryFragment = query
        }
    }
}
