//
//  GameTabFlow.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import Foundation
import UIKit

import RxFlow
import RxRelay

struct GameTabStepper: Stepper {
    let steps: PublishRelay<Step> = .init()
    
    var initialStep: Step {
        return AppStep.gameTabMainIsRequired
    }
}

final class GameTabFlow: Flow {
    
    // MARK: Property
    
    var root: Presentable {
        return self.rootViewController
    }
    
    let stepper: GameTabStepper
    private let rootViewController = UINavigationController()
    private let dashboardRepository: DashboardRepository
    // MARK: Init
    
    init(
        stepper: GameTabStepper,
        dashboardRepository: DashboardRepository
    ) {
        self.stepper = stepper
        self.dashboardRepository = dashboardRepository
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    // MARK: Navigate
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .gameTabMainIsRequired:
            return coordinateToGameTabMain()
        case .fingerChooserMainIsRequired:
            return coordinateToFingerChooserMain()
        default:
            return .none
        }
    }
}

// MARK: Method

extension GameTabFlow {
    private func coordinateToGameTabMain() -> FlowContributors {
        
        let reactor = GameTabMainReactor(dashboardRepository: dashboardRepository)
        let viewControllerWithStepper: GameTabMainViewController = .init()
        
        viewControllerWithStepper.reactor = reactor
        self.rootViewController.setViewControllers([viewControllerWithStepper], animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewControllerWithStepper,
                                                 withNextStepper: viewControllerWithStepper))
    }
}

// MARK: FingerChooser

extension GameTabFlow {
    private func coordinateToFingerChooserMain() -> FlowContributors {
        
        let reactor = FingerChooserMainReactor(dashboardRepository: dashboardRepository)
        let viewControllerWithStepper: FingerChooserMainViewController = .init()
        
        viewControllerWithStepper.reactor = reactor
        self.rootViewController.hidesBottomBarWhenPushed = true
        self.rootViewController.pushViewController(viewControllerWithStepper, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewControllerWithStepper,
                                                 withNextStepper: viewControllerWithStepper))
    }
}

