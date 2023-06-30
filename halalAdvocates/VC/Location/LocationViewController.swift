//
//  LocationViewController.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 4/13/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class LocationViewController: UIViewController {

    
    
    @IBOutlet weak var locationView: LocationView!
    
    var locationService: LocationService?

    override func viewDidLoad() {
        super.viewDidLoad()
        locationView.didTapAllow = { [weak self] in
            self?.locationService?.requestLocationAuthorization()
        }
        // Do any additional setup after loading the view.
        locationService?.didChangeStatus = { [weak self] success in
            if success{
                self?.locationService?.getLocation()
            }
        }
        locationService?.newLocation = { [weak self] result in
            switch result {
            case .success(let location):
                print(location)
            case .failure(let error):
                assertionFailure("Error getting location \(error)")
            }
        }
    }

    @IBAction func later(_ sender: Any) {
        
//        present(<#T##viewControllerToPresent: UIViewController##UIViewController#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
