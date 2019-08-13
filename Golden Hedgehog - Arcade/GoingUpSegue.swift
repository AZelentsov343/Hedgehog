//
//  GoingUpSegue.swift
//  Golden Hedgehog - Arcade
//
//  Created by Alexey Zelentsov on 08/08/2019.
//  Copyright © 2019 Alexey Zelentsov. All rights reserved.
//

import UIKit

class GoingUpSegue: UIStoryboardSegue {

    override func perform() {
    
        
        self.goUp()
    }
    
    private func goUp() {
        let vcFrom = self.source
        let vcTo = self.destination
        
        let window = vcFrom.view.superview
        
        vcTo.view.transform = CGAffineTransform(translationX: 0, y: -window!.frame.height)
        if vcFrom is ViewController {
            window?.addSubview(vcTo.view)
        } else if vcFrom is SecondViewController {
            window?.insertSubview(vcTo.view, at: 0)
        }
        
        UIView.animate(withDuration: 2.0, animations: {
            vcFrom.view.transform = CGAffineTransform(translationX: 0, y: window!.frame.height)
            vcTo.view.transform = CGAffineTransform.identity
        }) { (finish) in
            if vcFrom is ViewController {
                vcFrom.present(vcTo, animated: false, completion: nil)
                if let svc = vcTo as? SecondViewController {
                    svc.startGame()
                }
            } else if vcFrom is SecondViewController {
                vcFrom.dismiss(animated: false, completion: nil)
                if let svc = vcTo as? ViewController {
                    svc.startGame()
                }
            }
        }
    }
    
}
