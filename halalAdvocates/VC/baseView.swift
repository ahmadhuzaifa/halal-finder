//
//  baseView.swift
//  halalAdvocates
//
//  Created by Huzaifa Ahmed on 4/13/19.
//  Copyright © 2019 Huzaifa Ahmad. All rights reserved.
//

import UIKit


@IBDesignable class BaseView: UIView{
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()

    }
    func configure(){
        
    }
}
