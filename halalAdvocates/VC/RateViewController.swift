//
//  RateViewController.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 6/13/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import UIKit
import fluid_slider

class RateViewController: UIViewController {
    @IBOutlet var slider: Slider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let font = UIFont.boldSystemFont(ofSize: 20)

        slider.attributedTextForFraction = { fraction in
            let formatter = NumberFormatter()
            formatter.maximumIntegerDigits = 3
            formatter.maximumFractionDigits = 0
            let string = formatter.string(from: (fraction * 5) as NSNumber) ?? ""
            return NSAttributedString(string: string, attributes: [.font: font])
        }

        
        slider.setMinimumLabelAttributedText(NSAttributedString(string: "0", attributes:[.font: font, .foregroundColor: UIColor.white]))

        slider.setMaximumLabelAttributedText(NSAttributedString(string: "5", attributes: [.font: font, .foregroundColor: UIColor.white]))

        
        slider.fraction = 0.5
        slider.contentViewColor = #colorLiteral(red: 0.2824044824, green: 0.5691515803, blue: 0.3236377835, alpha: 1)
        slider.contentViewCornerRadius = 10
        slider.valueViewColor = .white
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
