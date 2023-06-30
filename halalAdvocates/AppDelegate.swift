//
//  AppDelegate.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 4/13/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let window =  UIWindow()
    let locationService = LocationService()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
//        Instabug.start(withToken: "bba273977ea9e5af54afb477afcf3991", invocationEvents: [.shake, .screenshot])

        switch locationService.status {
        case .notDetermined, .denied, .restricted:
            let locationVC = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as? LocationViewController
            locationVC?.locationService = locationService
            window.rootViewController = locationVC
        default:
            let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC") 
//            mainVC?.locationService = locationService
            window.rootViewController = mainVC
//            assertionFailure()
        }
        window.makeKeyAndVisible()
        return true
    }
    
}

