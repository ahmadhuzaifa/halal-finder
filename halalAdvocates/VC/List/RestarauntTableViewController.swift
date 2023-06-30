//
//  RestarauntTableViewController.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 4/13/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import FirebaseStorage
import SJFluidSegmentedControl
import Alamofire

class RestarauntTableViewController: UITableViewController {
    let cellID = "restaurantCell"
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var currentLocation: CLLocation?
    var places = [Place]()
    var displayedPlaces = [Place]()
    var placesDictionary = [String: Place]()
    let locationManager = CLLocationManager()
    var placeType = "restaurants"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        requestLocation()
        let currentCoordinate = locationManager.location?.coordinate
        handlePlaces(coordinate: currentCoordinate!)
    }
    
    func requestLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    }
    func setUp(){
        tableView.dequeueReusableCell(withIdentifier: cellID)
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControl.Event.valueChanged)
        refreshControl!.tintColor = UIColor.white
        self.tableView.addSubview(refreshControl!)
        if placeType == "market"{
            title = "Markets"
        }
        else{
            title = "Restaraunts"
        }
    }
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        if Connectivity.isConnectedToInternet(){
            places.removeAll()
            let currentCoordinate = locationManager.location?.coordinate
            handlePlaces(coordinate: currentCoordinate!)
            self.tableView.reloadData()
        }
        else{
            let alert = UIAlertController(title: "Connect to the Internet", message: "Not connected to the internet", preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        refreshControl.endRefreshing()
    }
    var imageData: Data?
    var imageURL: URL?
    
    func handlePlaces(coordinate: CLLocationCoordinate2D){
        let db = Firestore.firestore()
        let docRef = db.collection(placeType)
        docRef.getDocuments { (snapshot, error) in
            if error != nil{
                print(error!)
            }
            else {
                for document in snapshot!.documents {
                    let id = document.documentID
                    let data = document.data()
                    let name = data["name"]
                    let address = data["address"] ?? ""
                    let tags = data["tags"] ?? [""]
                    self.getCoordinates(address: address as! String) { lat, long, error in
                        if error != nil {
                            print("Error")
                        } else {
                            self.latitude = lat
                            self.longitude = long
                            let currentLoca = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            let distance = CLLocation(latitude: self.latitude!,longitude: self.longitude!).distance(from: currentLoca)
                            let distanceValue = Double(distance / 1609.34)
                            let imagesRef = Storage.storage().reference().child(id).child("main.jpg")
                            if Connectivity.isConnectedToInternet(){
                                imagesRef.downloadURL(completion: { (url, error) in
                                    if error != nil {
                                        let placeDictionary = ["id": id, "name": name as AnyObject, "address": address, "distance": distanceValue as AnyObject, "type": self.placeType, "tags": tags] as [String : Any]
                                        self.places.append(Place(dictionary: placeDictionary as [String : AnyObject]))
                                        self.places.sort(by: { $0.distance! < $1.distance!})
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    }
                                    else{
                                        let placeDictionary = ["id": id, "name": name as AnyObject,"address": address, "distance": distanceValue as AnyObject, "imageURL": url!, "type": self.placeType, "tags": tags] as [String : Any]
                                        self.places.append(Place(dictionary: placeDictionary as [String : AnyObject]))
                                        self.places.sort(by: { $0.distance! < $1.distance!})
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    }
                                })
                            }
                            else{
                                let placeDictionary = ["id": id, "name": name as AnyObject,"address": address, "distance": distanceValue as AnyObject, "type": self.placeType, "tags": tags] as [String : Any]
                                self.places.append(Place(dictionary: placeDictionary as [String : AnyObject]))
                                self.places.sort(by: { $0.distance! < $1.distance!})
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                            }
                            
                            
                        }
                    }
                }
            }
        }
    }
    
    func getCoordinates(address: String, completionHandler: @escaping (_ lat: CLLocationDegrees?, _ long: CLLocationDegrees?, _ error: Error?) -> ()) {
        
        var _:CLLocationDegrees
        var _:CLLocationDegrees
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks: [CLPlacemark]!, error: Error!) in
            
            if error != nil {
                
                print("Geocode failed with error: \(error.localizedDescription)")
                
            } else if placemarks.count > 0 {
                
                let placemark = placemarks[0] as CLPlacemark
                let location = placemark.location
                
                let lat = location?.coordinate.latitude
                let long = location?.coordinate.longitude
                
                completionHandler(lat, long, nil)
            }
        }
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = places[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! RestarauntTableViewCell
        cell.configure(with: place)
        cell.restarauntNameView.text = place.name
        let mileValue = Double(round(10*place.distance!)/10)
        let addressStr = place.address
        let addressArr = addressStr?.split(separator: ",")
        let addressFirstLine = addressArr![0]
        let mileString = String(mileValue) + " mi"
        cell.locationLabel.text = addressFirstLine + " • " + mileString
        let tags = place.tags
        let tagsStr = tags?.joined(separator: " • ")

        cell.tagsLabel.text = tagsStr
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UITableViewCell, let vc = segue.destination as? DetailsFoodViewController{
            let indexPath = tableView.indexPathForSelectedRow?.row
            let place = places[indexPath!]
            let id = place.id
            vc.halalID = id
            vc.placeType = placeType
        }
        

    }
    
}

extension RestarauntTableViewController: CLLocationManagerDelegate{
    
}
class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
