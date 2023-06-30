//
//  RestarauntTableViewCell.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 4/13/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import UIKit
import Firebase
import AlamofireImage

class RestarauntTableViewCell: UITableViewCell {
    
    
    @IBOutlet var tagsLabel: UILabel!
    @IBOutlet weak var restarauntImageView: UIImageView!
    @IBOutlet weak var restarauntNameView: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet var containerView: UIView!
    let cornerRadius: CGFloat = 7
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        containerView.layer.cornerRadius = cornerRadius
//        containerView.layer.shadowColor = UIColor.darkGray.cgColor
//        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//        containerView.layer.shadowRadius = 5.0
//        containerView.layer.shadowOpacity = 0.9
//
                restarauntImageView.layer.cornerRadius = cornerRadius

        restarauntImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(with place: Place) {
        if place.imageURL != nil{
            restarauntImageView.af_setImage(withURL: place.imageURL!)
        }else{
             restarauntImageView.image = #imageLiteral(resourceName: "placeholder")
        }
      
    }

}
