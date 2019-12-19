//
//  CustomButton.swift
//  ARBasketballApp
//
//  Created by Hisham Alsamarrai on 12/18/19.
//  Copyright © 2019 Hisham Alsamarrai. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // Prepares the reciever for service after loaded
    override func awakeFromNib()
    {
        super.awakeFromNib()
        customizeButtons()
    }
    
    // Will customize the buttons shown on the scene
    func customizeButtons()
    {
        // Background color of the buttons
        backgroundColor = UIColor.lightGray
        
        // The radius and with of the buttons
        layer.cornerRadius = 10.0
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
    }
}
