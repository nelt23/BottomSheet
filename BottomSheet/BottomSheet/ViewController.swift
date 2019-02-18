//
//  ViewController.swift
//  BottomSheet
//
//  Created by Nuno Martins on 17/02/2019.
//  Copyright © 2019 Nuno Martins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        container.layer.masksToBounds = true
        container.layer.cornerRadius = 15
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BottomSheetViewController {
            vc.bottomSheetDelegate = self
            vc.parentView = container
        }
    }

}

extension ViewController: BottomSheetDelegate {
    
    func updateBottomSheet(frame: CGRect) {
        container.frame = frame
    }
    
}
