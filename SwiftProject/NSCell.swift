//
//  NSCell.swift
//  SwiftProject
//
//  Created by Fabio Yudi Takahara on 25/05/16.
//  Copyright © 2016 Fabio Takahara. All rights reserved.
//

import Foundation
import UIKit

class NSCell:UICollectionViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //Layout Ajustment
        self.layer.borderColor = UIColor(red: 95.0/255.0, green: 5.0/255.0, blue: 150.0/255.0, alpha: 1.0).CGColor
        self.layer.borderWidth = 1
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        //Layout Ajustment for user image after load cell
        self.userImageView.clipsToBounds = true;
        self.userImageView.layer.cornerRadius = self.userImageView.bounds.width / 2
        self.userImageView.layer.borderColor = UIColor.whiteColor().CGColor
        self.userImageView.layer.borderWidth = 2.0
    }
}