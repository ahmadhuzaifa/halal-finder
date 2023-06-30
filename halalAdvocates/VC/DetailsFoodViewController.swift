//
//  DetailsFoodViewController.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 4/13/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import CoreLocation
import GrowingTextView
import AlamofireImage
import UICircularProgressRing

class DetailsFoodViewController: UIViewController {
    @IBOutlet weak var detailsFoodView: DetailsFoodView!
    var placeType: String = "restaraunts"
    var halalID: String?
    var name: String?
    var restDescription: String?
    var imageURL: URL?
    var lat: Double?
    var long: Double?
    var phoneNumber: String?
    var websiteURL: String?
    var emailURL: String?
    var address: String?
    var tags: Array<Any>?

    @IBOutlet var foodRatingRing: UICircularProgressRing!
    @IBOutlet var serviceRatingRing: UICircularProgressRing!
    @IBOutlet var ambienceRatingRing: UICircularProgressRing!
    @IBOutlet var averageRatingRing: UICircularProgressRing!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var websiteLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var descriptionTextView: GrowingTextView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        handleDatabase()
    }
    func handleDatabase(){
        let db = Firestore.firestore()
        let docRef = db.collection(placeType).document(halalID!)
        docRef.getDocument { (snapshot, error) in
            if error != nil{
                print(error!)
            }
            else{
                let data = snapshot?.data()
                self.name = data!["name"] as? String
                self.address = data!["address"] as? String
                self.emailURL = data!["email"] as? String
                self.websiteURL = data!["website"] as? String
                self.phoneNumber = data!["phone"] as? String
                self.restDescription = data!["description"] as? String
                self.tags = data!["tags"] as? Array ?? ["error", "loading", "tags"]
                self.tagsCollectionView.reloadData()
                self.tagsCollectionView.delegate = self
                self.tagsCollectionView.dataSource = self
                self.descriptionTextView.text = self.restDescription ?? "Error"
                let imagesRef = Storage.storage().reference().child(self.halalID!).child("main.jpg")
                imagesRef.downloadURL(completion: { (url, error) in
                    if error != nil{
                        print(error!)
                    }
                    self.imageURL = url
                    if self.imageURL != nil{
                        self.imageView.af_setImage(withURL: self.imageURL!)
                    }
                    else{
                        self.imageView.image = #imageLiteral(resourceName: "placeholder")
                    }
                })
                if self.phoneNumber == nil{
                    self.phoneButton.layer.opacity = 0.6
                }
                if self.websiteURL == nil{
                    self.websiteButton.layer.opacity = 0.6
                }
                if self.address == nil{
                    self.locationButton.layer.opacity = 0.6
                }
                
                self.navigationItem.title = self.name
                self.locationLabel.text = self.address
                let s = self.phoneNumber!
//                let s2 = String(format: "%@ (%@) %@ %@ %@",
//                                String(s[..<s.index(s.startIndex, offsetBy: 1)]),
//                                String(s[s.index(s.startIndex, offsetBy: 1) ..< s.index(s.startIndex, offsetBy:  4)]),
//                                String(s[s.index(s.startIndex, offsetBy: 4) ..< s.index(s.startIndex, offsetBy:  7)]),
//                                String(s[s.index(s.startIndex, offsetBy: 7) ..< s.index(s.startIndex, offsetBy:  9)]),
//                                String(s[s.index(s.startIndex, offsetBy: 9) ..< s.index(s.startIndex, offsetBy:  11)]))
                self.phoneNumberLabel.text = self.phoneNumber
                self.getCoordinates(address: self.address!) { lat, long, error in
                    let annotation = MKPointAnnotation()
                    self.lat = lat
                    self.long = long
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
                    annotation.title = self.name
                    self.mapView.addAnnotation(annotation)
                    self.mapView.showAnnotations([annotation], animated: false)
                }
                
                self.ambienceRatingRing.maxValue = 100.0
                self.ambienceRatingRing.innerRingColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.3176470588, alpha: 1)
                self.ambienceRatingRing.innerRingWidth = 5
                self.ambienceRatingRing.outerRingColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                self.ambienceRatingRing.outerRingWidth = 5
                self.ambienceRatingRing.style = .ontop
                self.ambienceRatingRing.font = .systemFont(ofSize: 12)
                self.ambienceRatingRing.startProgress(to: 50.0, duration: 2.0) {
                    print("Done animating!")
                }
                
                
                self.foodRatingRing.maxValue = 100.0
                self.foodRatingRing.innerRingColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.3176470588, alpha: 1)
                self.foodRatingRing.innerRingWidth = 5
                self.foodRatingRing.outerRingColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                self.foodRatingRing.outerRingWidth = 5
                self.foodRatingRing.style = .ontop
                self.foodRatingRing.font = .systemFont(ofSize: 12)
                self.foodRatingRing.startProgress(to: 70.0, duration: 2.0) {
                    print("Done animating!")
                }
                self.serviceRatingRing.maxValue = 100.0
                self.serviceRatingRing.innerRingColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.3176470588, alpha: 1)
                self.serviceRatingRing.innerRingWidth = 5
                self.serviceRatingRing.outerRingColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                self.serviceRatingRing.outerRingWidth = 5
                self.serviceRatingRing.style = .ontop
                self.serviceRatingRing.font = .systemFont(ofSize: 12)
                self.serviceRatingRing.startProgress(to: 67.0, duration: 2.0) {
                    print("Done animating!")
                }
                self.averageRatingRing.maxValue = 100.0
                self.averageRatingRing.innerRingColor = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.3176470588, alpha: 1)
                self.averageRatingRing.innerRingWidth = 5
                self.averageRatingRing.outerRingColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                self.averageRatingRing.outerRingWidth = 5
                self.averageRatingRing.style = .ontop
                self.averageRatingRing.font = .systemFont(ofSize: 12)
                self.averageRatingRing.startProgress(to: 67.0, duration: 2.0) {
                    print("Done animating!")
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
    
    @IBAction func handleCall(_ sender: Any) {
        if phoneNumber != nil{
            guard let number = URL(string: "tel://" + phoneNumber!) else { return }
            UIApplication.shared.open(number)
        }
    }
    @IBAction func handleLocate(_ sender: Any) {
        
        let latitude:CLLocationDegrees =  lat!
        let longitude:CLLocationDegrees =  long!

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.name!)"
        mapItem.openInMaps(launchOptions: options)


        
    }
    @IBAction func handleWebsite(_ sender: Any) {
        if websiteURL != nil{
            if let url = URL(string: websiteURL!){
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    @IBAction func handleMail(_ sender: Any) {
    }
    
    @IBAction func handleShare(_ sender: Any) {
        // text to share
        let text = ("Check out ", name)
        // set up activity view controller
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIButton, let vc = segue.destination as? MenuTableViewController{
            if let id = halalID{
                vc.halalID = id
            }
        }
    }
}

extension DetailsFoodViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagsCollectionView{
            return tags!.count
        }
        else{
            return 1
        }
    }
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = tagsCollectionView.dequeueReusableCell(withReuseIdentifier: "tagsCell", for: indexPath) as! tagCell
        let tag = tags![indexPath.row]
        cell.tagNameLabel.text = tag as? String
        return cell
    }
}

class tagCell: UICollectionViewCell{
    @IBOutlet weak var tagBackgroundView: UIView!
    @IBOutlet weak var tagNameLabel: UILabel!
    
    override func awakeFromNib() {
        tagBackgroundView.layer.cornerRadius = tagBackgroundView.frame.height/2
    }
}

