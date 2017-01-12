//
//  DB5ViewController.swift
//  DB5Demo-Swift
//
//  Created by Hon Cheng Muh on 12/1/17.
//  Copyright © 2017 Clean Shaven Apps Pte. Ltd. All rights reserved.
//

import UIKit

class DB5ViewController: UIViewController {

    var theme: Theme
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, theme: Theme) {
        self.theme = theme
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = self.theme.color(forKey: "backgroundColor")
        
        let square = self.theme.view(withViewSpecifierKey: "square")
        self.view.addSubview(square)
        
        let label = self.theme.label(
            withText: "DB5 Demo App",
            specifierKey: "label",
            sizeAdjustment: 0)
        self.view.addSubview(label)
        
        self.theme.animate(withAnimationSpecifierKey: "labelAnimation", animations: { 
            
            var rLabel = label.frame
            rLabel.origin = self.theme.point(forKey: "labelFinalPosition")
            label.frame = rLabel
            
        }) { (finished) in
            print("Ran an animation")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
