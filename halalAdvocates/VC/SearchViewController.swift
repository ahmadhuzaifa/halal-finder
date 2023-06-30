//
//  SearchViewController.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 4/23/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class SearchViewController: UIViewController {

    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var currentLocation: CLLocation?
    var places = [Place]()
    var placesDictionary = [String: Place]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPlaces = [Place]()
    var placeType = "restaurants"
    
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
//    let place = [Place]()
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
   
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredPlaces = places.filter({( place : Place) -> Bool in
            return place.name!.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup the Search Controller
        handlePlaces()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Places"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        definesPresentationContext = true

        tableView.delegate = self
        tableView.dataSource = self
        tableView.dequeueReusableCell(withIdentifier: "Cell")
    }
    
    func handlePlaces(){
        let db = Firestore.firestore()
        let docRef = db.collection(placeType)
        docRef.getDocuments { (snapshot, error) in
            if error != nil{
                print(error!)
            }
            else {
                for document in snapshot!.documents {
                    let id = document.documentID
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let name = data["name"]
                    let address = data["address"] ?? ""
                    self.getCoordinates(address: address as! String) { lat, long, error in
                        if error != nil {
                            print("Error")
                        } else {
                            self.latitude = lat
                            self.longitude = long
                            let currentLoca = CLLocation(latitude: 38.633250, longitude: -121.371060)
                            let distance = CLLocation(latitude: self.latitude!,longitude: self.longitude!).distance(from: currentLoca)
                            let distanceValue = Double(distance / 1609.34)
                            print(distanceValue)
                            let placeDictionary = ["id": id, "name": name as AnyObject,"address": address as AnyObject, "distance": distanceValue as AnyObject] as [String : Any]
                            self.places.append(Place(dictionary: placeDictionary as [String : AnyObject]))
                            self.places.sort(by: { $0.distance! < $1.distance!})
                            self.tableView.reloadData()
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
        if let _ = sender as? UITableViewCell, let vc = segue.destination as? DetailsFoodViewController{
            let indexPath = tableView.indexPathForSelectedRow?.row
            let place = places[indexPath!]
            let id = place.id
            vc.halalID = id
            vc.placeType = placeType
        }
    }

}
extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredPlaces.count
        }
        
        return places.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! searchCell
        let searchedPlace: Place
        if isFiltering() {
            searchedPlace = filteredPlaces[indexPath.row]
        } else {
            searchedPlace = places[indexPath.row]
        }
        cell.titleLabel!.text = searchedPlace.name
        cell.addressLabel!.text = searchedPlace.address

        //        cell.detailTextLabel!.text = place.category
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
class searchCell: UITableViewCell{
    @IBOutlet var photoView: UIImageView!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        photoView.layer.masksToBounds = true
        photoView.layer.cornerRadius = 5
        
    }
}
