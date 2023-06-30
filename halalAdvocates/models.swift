//
//  models.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 4/20/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import Foundation



class Place: NSObject {
    var id: String?
    var name: String?
    var address: String?
    var imageData: Data?
    var imageURL: URL?
    var location: Double?
    var distance: Double?
    var type: String?
    var tags: Array<String>?
    init(dictionary: [String: AnyObject]) {
        self.name = dictionary["name"] as? String
        self.distance = dictionary["distance"] as? Double
        self.id =  dictionary["id"] as? String
        self.address =  dictionary["address"] as? String
        self.imageData =  dictionary["imageData"] as? Data
        self.imageURL =  dictionary["imageURL"] as? URL
        self.type =  dictionary["type"] as? String
        self.tags =  dictionary["tags"] as? Array
    }
}
class menuItem: NSObject {
    var id: String?
    var name: String?
    var price: String?
    var desc: String?

 
    init(dictionary: [String: AnyObject]) {
        self.name = dictionary["name"] as? String
        self.id =  dictionary["id"] as? String
        self.price =  dictionary["price"] as? String
        self.desc =  dictionary["desc"] as? String
    }
}
