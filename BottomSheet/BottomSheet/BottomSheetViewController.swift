//
//  BottomSheetViewController.swift
//  BottomSheet
//
//  Created by Nuno Martins on 17/02/2019.
//  Copyright © 2019 Nuno Martins. All rights reserved.
//

import UIKit

enum SheetLevel{
    case top, bottom, middle
}

protocol BottomSheetDelegate {
    func updateBottomSheet(frame: CGRect)
}

class BottomSheetViewController: UIViewController {

    @IBOutlet var panView: UIView!
    @IBOutlet weak var rubberBandView: UIView!
    
    var bottomSheetDelegate: BottomSheetDelegate?
    var parentView: UIView!
    
    var lastY: CGFloat = 0
    var pan: UIPanGestureRecognizer!

    var panRubberBand: UIPanGestureRecognizer!
    var rubberBandBool = false

    
    var initalFrame: CGRect!
    var topY: CGFloat! //change this in viewWillAppear for top position
    var middleY: CGFloat! //change this in viewWillAppear to decide if animate to top or bottom
    var bottomY: CGFloat! //no need to change this
    let bottomOffset: CGFloat = 64 //sheet height on bottom position
    var lastLevel: SheetLevel = .middle //choose inital position of the sheet

    override func viewDidLoad() {
        super.viewDidLoad()

        pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        self.panView.addGestureRecognizer(pan)
        
        panRubberBand = UIPanGestureRecognizer(target: self, action: #selector(handlePanRubberBand(_:)))
        panRubberBand.delegate = self
        self.rubberBandView.addGestureRecognizer(panRubberBand)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initalFrame = UIScreen.main.bounds
        self.topY = round(initalFrame.height * 0.05)
        self.middleY = initalFrame.height * 0.6
        self.bottomY = initalFrame.height - bottomOffset
        self.lastY = self.middleY

        bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))
    }

    // just to give the RubberBand efect
    @objc func handlePanRubberBand(_ recognizer: UIPanGestureRecognizer){
        
        let dy = recognizer.translation(in: self.parentView).y

        switch recognizer.state {
            
        case .began:
            
            if self.lastY == self.topY {
                rubberBandBool = true
            }
            
        case .changed:
            
            // create limits for top and bottom
            let maxY = max(topY, lastY + dy)
            var y = min(bottomY, maxY)

            if topY > lastY + dy && logConstraintValueForYPoisition(yPosition: lastY + dy) > 5 {
                y = logConstraintValueForYPoisition(yPosition: lastY + dy)

                bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: y))
            } else if topY < lastY + dy{
                bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: y))
            }
        
        case .failed, .ended, .cancelled:
            rubberBandBool = false

        default:
            break
            
        }
        
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer){

        let dy = recognizer.translation(in: self.parentView).y
        
        switch recognizer.state {
            
        case .changed:

            // if we are not using the rubberBand efect
            if rubberBandBool == false {
                // create limits for top and bottom
                let maxY = max(topY, lastY + dy)
                let y = min(bottomY, maxY)
            
                bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: y))
            }
            
        case .failed, .ended, .cancelled:
            
            self.panView.isUserInteractionEnabled = false
            self.lastLevel = self.nextLevel(recognizer: recognizer, lastY: self.parentView.frame.minY)

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.9, options: .curveEaseOut, animations: {
                
                switch self.lastLevel{
                case .top:
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.topY))
                case .middle:
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.middleY))
                case .bottom:
                    self.bottomSheetDelegate?.updateBottomSheet(frame: self.initalFrame.offsetBy(dx: 0, dy: self.bottomY))
                }
                
            }) { (_) in
                self.panView.isUserInteractionEnabled = true
                self.lastY = self.parentView.frame.minY
            }
            
        default:
            break
        }
    }

    func nextLevel(recognizer: UIPanGestureRecognizer, lastY: CGFloat) -> SheetLevel {
        
        let y = lastY
        let velY = recognizer.velocity(in: self.view).y
        
        // up
        if velY < -200 {
            return y > middleY ? .middle : .top
        // down
        } else if velY > 200 {
            return y < (middleY + 1) ? .middle : .bottom
        } else {
            // near to bottom
            if y > middleY {
                return (y - middleY) < (bottomY - y) ? .middle : .bottom
            // near to top
            } else {
                return (y - topY) < (middleY - y) ? .top : .middle
            }
        }
    }
    
    func logConstraintValueForYPoisition(yPosition : CGFloat) -> CGFloat {
        return topY * (1 + 0.2 * log10((yPosition/topY)))
    }
    
}

extension BottomSheetViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
