//
//  SceneDelegate.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import UIKit

import RxFlow
import RxSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    // AppDelegate의 UNUserNotificationCenterDelegate에서 푸시 메시지 클릭 시 화면 전환을 위해 private제거
    let coordinator: FlowCoordinator = .init()
    private let appStepper = AppStepper()
    private let disposeBag: DisposeBag = .init()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        coordinatorLogStart()
        
        coordinateToAppFlow(with: windowScene)
    }
}

extension SceneDelegate {
    private func coordinateToAppFlow(with windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        let appFlow = AppFlow(with: window)
        coordinator.coordinate(flow: appFlow, with: appStepper)
        window.makeKeyAndVisible()
    }
    
    private func coordinatorLogStart() {
        coordinator.rx.willNavigate
            .subscribe(onNext: { flow, step in
                let currentFlow = "\(flow)".split(separator: ".").last ?? "no flow"
                print("➡️ will navigate to flow = \(currentFlow) and step = \(step)")
            })
            .disposed(by: disposeBag)
    }
}
