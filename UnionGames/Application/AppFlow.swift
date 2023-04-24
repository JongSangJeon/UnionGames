//
//  AppFlow.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import UIKit

import RxCocoa
import RxFlow
import RxSwift

struct AppStepper: Stepper {
    let steps: PublishRelay<Step> = .init()
    private let disposeBag: DisposeBag = .init()
    
    func readyToEmitSteps() {
        self.steps.accept(AppStep.dashboardTabBarIsRequired)
    }
}

// Flow는 AnyObject를 준수하므로 class로 선언해주어야 한다.
final class AppFlow: Flow {
    var root: Presentable {
        return self.rootWindow
    }
    
    private let rootWindow: UIWindow
    private var dashboardFlow: DashboardFlow
    
    init(
        with window: UIWindow
    ) {
        self.rootWindow = window
        self.dashboardFlow = .init()
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .dashboardTabBarIsRequired:
            return coordinateToDashboard()
            
        default:
            return .none
        }
    }
    
    
    private func coordinateToDashboard() -> FlowContributors {

        Flows.use(self.dashboardFlow, when: .created) { [unowned self] root in
            rootWindow.rootViewController = root
        }

        let nextStep = OneStepper(withSingleStep: AppStep.dashboardTabBarIsRequired)

        return .one(flowContributor: .contribute(withNextPresentable: dashboardFlow,
                                                 withNextStepper: nextStep))
    }
}
