//
//  DashboardFlow.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import UIKit

import RxFlow

final class DashboardFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: UINavigationController =  .init()
    
    private let dashboardRepository: DashboardRepository
    private let gameTabFlow: GameTabFlow
    
    init() {
        self.dashboardRepository = .init()
        self.gameTabFlow = .init(stepper: .init(), dashboardRepository: self.dashboardRepository)
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
            // Dasboard
        case .dashboardTabBarIsRequired:
            return coordinateToDashboardTabBar()
        default:
            return .none
        }
    }
    
    private func coordinateToDashboardTabBar()-> FlowContributors {
        Flows.use(
            gameTabFlow,
            when: .created
        ) { [unowned self] (root1: UINavigationController) in
            
//            let viewModel = ()
            
            let tabBarController: DashboardTabBarController = .init()
            let gameTabItem: UITabBarItem = .init(title: "게임",
                                                  image: UIImage(systemName: "gamecontroller"),
                                                  selectedImage: UIImage(systemName: "gamecontroller.fill"))
            
            root1.tabBarItem = gameTabItem
            
            self.rootViewController.navigationBar.isHidden = true
            
            tabBarController.setViewControllers([root1], animated: false)
            self.rootViewController.setViewControllers([tabBarController], animated: false)
        }
        
        return .multiple(flowContributors: [
            .contribute(withNextPresentable: gameTabFlow, withNextStepper: gameTabFlow.stepper)
        ])
    }
}
