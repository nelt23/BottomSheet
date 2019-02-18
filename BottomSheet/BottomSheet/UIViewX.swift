//
//  UIViewX.swift
//  BottomSheet
//
//  Created by Nuno Martins on 17/02/2019.
//  Copyright © 2019 Nuno Martins. All rights reserved.
//

import UIKit

@IBDesignable
class UIViewX: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }   

}
