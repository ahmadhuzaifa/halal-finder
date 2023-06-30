//
//  MenuTableViewController.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 5/24/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import UIKit
import Firebase
import GrowingTextView
class MenuTableViewController: UITableViewController {
    
    var menuItems = [menuItem]()
    var halalID: String?
    let cellID = "menuItems"
        
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMenu()
    }
    func loadMenu(){
        let db = Firestore.firestore()
        let docRef = db.collection("restaurants").document(halalID!).collection("menu")
        docRef.getDocuments { (data, error) in
            if error != nil{
                print(error.debugDescription)
            }
            else{
                let documents = data!.documents
                for document in documents {
                    let data = document.data()
                    let id = document.documentID
                    let name = data["name"]
                    let price = data["price"]
                    let desc = data["desc"]

                    let menuDict = ["id": id, "name": name, "price": price, "desc": desc]
                    self.menuItems.append(menuItem(dictionary: menuDict as [String : AnyObject]))
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuItems.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = menuItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MenuItemsCell
        cell.priceLabel.text = item.price
        cell.nameLabel.text = item.name
        cell.descriptionTextView.text = item.desc
        return cell
    }
}
class MenuItemsCell: UITableViewCell{
    
    @IBOutlet var descriptionTextView: GrowingTextView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
}
