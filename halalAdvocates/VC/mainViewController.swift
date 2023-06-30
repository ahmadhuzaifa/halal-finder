//
//  mainViewController.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 6/15/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import FirebaseStorage
import SJFluidSegmentedControl
import Alamofire

class mainViewController: UIViewController {
    let cellID = "NearRestaurantCell"
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var currentLocation: CLLocation?
    var places = [Place]()
    var featuredPlaces = [Place]()

    var placesDictionary = [String: Place]()
    let locationManager = CLLocationManager()
    var selectedIndex = 0
    var placeType = "restaurants"
    @IBOutlet var nearRestarauntsTextView: UITextView!
    @IBOutlet var FeaturedRestarauntsCollectionView: UICollectionView!
    
    @IBOutlet var NearRestarauntsCollectionView: UICollectionView!
    
    @IBOutlet var segmentedControl: SJFluidSegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        requestLocation()
        let currentCoordinate = locationManager.location?.coordinate
        handlePlaces(coordinate: currentCoordinate!)
        handleFeaturedPlaces(coordinate: currentCoordinate!)

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
        segmentedControl.layer.borderWidth = 1
        segmentedControl.layer.borderColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.3176470588, alpha: 1)
    }
    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        if Connectivity.isConnectedToInternet(){
            places.removeAll()
            featuredPlaces.removeAll()
            let currentCoordinate = locationManager.location?.coordinate
            handlePlaces(coordinate: currentCoordinate!)
            handleFeaturedPlaces(coordinate: currentCoordinate!)
            self.NearRestarauntsCollectionView.reloadData()
            self.FeaturedRestarauntsCollectionView.reloadData()
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
    
    func handePlaceGoogleAPI(coordinate:CLLocationCoordinate2D){
        
    }
    
    func handlePlaces(coordinate: CLLocationCoordinate2D){
        if selectedIndex == 0{
            placeType = "restaurants"
        }
        else{
            placeType = "market"
        }
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
                                            self.NearRestarauntsCollectionView.reloadData()
                                            
                                        }
                                    }
                                    else{
                                        let placeDictionary = ["id": id, "name": name as AnyObject,"address": address, "distance": distanceValue as AnyObject, "imageURL": url!, "type": self.placeType, "tags": tags] as [String : Any]
                                        self.places.append(Place(dictionary: placeDictionary as [String : AnyObject]))
                                        self.places.sort(by: { $0.distance! < $1.distance!})
                                        DispatchQueue.main.async {
                                            self.NearRestarauntsCollectionView.reloadData()
                                        }
                                    }
                                })
                            }
                            else{
                                let placeDictionary = ["id": id, "name": name as AnyObject,"address": address, "distance": distanceValue as AnyObject, "type": self.placeType, "tags": tags] as [String : Any]
                                self.places.append(Place(dictionary: placeDictionary as [String : AnyObject]))
                                self.places.sort(by: { $0.distance! < $1.distance!})
                                DispatchQueue.main.async {
                                    self.NearRestarauntsCollectionView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func handleFeaturedPlaces(coordinate: CLLocationCoordinate2D){
        let db = Firestore.firestore()
        let docRef = db.collection("featured")
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
                                        self.featuredPlaces.append(Place(dictionary: placeDictionary as [String : AnyObject]))
                                        self.featuredPlaces.sort(by: { $0.distance! < $1.distance!})
                                        DispatchQueue.main.async {
                                            self.FeaturedRestarauntsCollectionView.reloadData()

                                        }
                                    }
                                    else{
                                        let placeDictionary = ["id": id, "name": name as AnyObject,"address": address, "distance": distanceValue as AnyObject, "imageURL": url!, "type": self.placeType, "tags": tags] as [String : Any]
                                        self.featuredPlaces.append(Place(dictionary: placeDictionary as [String : AnyObject]))
                                        self.featuredPlaces.sort(by: { $0.distance! < $1.distance!})
                                        DispatchQueue.main.async {
                                            self.FeaturedRestarauntsCollectionView.reloadData()
                                        }
                                    }
                                })
                            }
                            else{
                                let placeDictionary = ["id": id, "name": name as AnyObject,"address": address, "distance": distanceValue as AnyObject, "type": self.placeType, "tags": tags] as [String : Any]
                                self.featuredPlaces.append(Place(dictionary: placeDictionary as [String : AnyObject]))
                                self.featuredPlaces.sort(by: { $0.distance! < $1.distance!})
                                DispatchQueue.main.async {
                                    self.FeaturedRestarauntsCollectionView.reloadData()
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UICollectionViewCell, let vc = segue.destination as? DetailsFoodViewController{
            let indexPath = NearRestarauntsCollectionView.indexPathsForSelectedItems?.first?.row
            let place = places[indexPath!]
            let id = place.id
            vc.halalID = id
            vc.placeType = placeType
        }
        
        if let _ = sender as? UIButton, let vc = segue.destination as? RestarauntTableViewController{
            vc.placeType = placeType
        }
        
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? SearchViewController{
            vc.placeType = placeType
        }

    }
}
extension mainViewController: SJFluidSegmentedControlDataSource{
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 2
    }
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          titleForSegmentAtIndex index: Int) -> String?{
        if index == 0{
            return "Dinings"
        }
        if index == 1{
            return "Market"
        }
        else{
            return "3"
        }
    }
}
extension mainViewController: UICollectionViewDelegate{
    
}
extension mainViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == NearRestarauntsCollectionView{
            return places.count
        }
        else{
           return featuredPlaces.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var place: Place?
        if collectionView == NearRestarauntsCollectionView{
            place = places[indexPath.row]
        }
        else{
            place = featuredPlaces[indexPath.row]
        }
        let cell = NearRestarauntsCollectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! RestarauntCollectionViewCell
        cell.configure(with: place!)
        cell.nameLabel.text = place!.name
        let mileValue = Double(round(10*place!.distance!)/10)
        let addressStr = place!.address
        let addressArr = addressStr?.split(separator: ",")
        let addressFirstLine = addressArr![0]
        let mileString = String(mileValue) + " mi"
        cell.subtitleLabel.text = addressFirstLine + " • " + mileString
        let tags = place!.tags
        let tagsStr = tags?.joined(separator: " • ")
        
        cell.tagLabel.text = tagsStr
        return cell
        
        
    }
}

extension mainViewController: SJFluidSegmentedControlDelegate{
    @objc func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                                didChangeFromSegmentAtIndex fromIndex: Int,
                                toSegmentAtIndex toIndex:Int){
        if toIndex == 0{
            selectedIndex = 0
            nearRestarauntsTextView.text = "Amazing Restaraunts Near you"
            places.removeAll()
            featuredPlaces.removeAll()
            requestLocation()
            let currentCoordinate = locationManager.location?.coordinate
            handlePlaces(coordinate: currentCoordinate!)
            handleFeaturedPlaces(coordinate: currentCoordinate!)
        }
        if toIndex == 1{
            selectedIndex = 1
            //            title = "Markets"
            nearRestarauntsTextView.text = "Amazing Halal Markets Near you"
            places.removeAll()
            featuredPlaces.removeAll()

            requestLocation()
            let currentCoordinate = locationManager.location?.coordinate
            handlePlaces(coordinate: currentCoordinate!)
            handleFeaturedPlaces(coordinate: currentCoordinate!)

        }
    }
}
extension mainViewController: CLLocationManagerDelegate{
    
}

class RestarauntCollectionViewCell: UICollectionViewCell{
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    
    
    override func awakeFromNib() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
    }
    func configure(with place: Place) {
        if place.imageURL != nil{
            imageView.af_setImage(withURL: place.imageURL!)
        }else{
            imageView.image = #imageLiteral(resourceName: "placeholder")
        }
        
    }
}

class RoundedBorderedButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderWidth = 1.0
        layer.borderColor = tintColor.cgColor
        layer.cornerRadius = frame.height/2
        clipsToBounds = true
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        setTitleColor(tintColor, for: .normal)
        setTitleColor(UIColor.white, for: .highlighted)
    }
}
