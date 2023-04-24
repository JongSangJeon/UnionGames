//
//  AppStep.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import UIKit

import RxFlow

enum AppStep: Step {
    // Global
    case networkFailPopUpIsRequired
    
    // MARK: DashboardScene
    case dashboardTabBarIsRequired
    
    // GameTab
    case gameTabMainIsRequired
    case fingerChooserMainIsRequired
    
    // MARK: None: 각 ViewModel의 초기 step값
    case none
}

