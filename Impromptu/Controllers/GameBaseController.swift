//
//  GameBaseController.swift
//  TPG
//
//  Created by Shane on 7/9/24.
//

import Foundation
import UIKit

class GameBaseController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.Colors.primary
        
        navigationItem.leftBarButtonItems = []
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.titleTextAttributes = [
            .font: Theme.Fonts.Style.main(weight: .bold).font.withSize(24.0),
            .foregroundColor: UIColor.white
        ]
    }
}
