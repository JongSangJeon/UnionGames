//
//  GameTabMainViewController.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import UIKit

import ReactorKit
import RxCocoa
import RxFlow
import Then

class GameTabMainViewController: BaseViewController, Stepper, View {
    
    var steps: PublishRelay<Step> = .init()
    
    func bind(reactor: GameTabMainReactor) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.steps.accept(AppStep.fingerChooserMainIsRequired)
    }
    
}
