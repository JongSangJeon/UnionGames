//
//  FingerChooserMainReactor.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import UIKit

import ReactorKit
import RxSwift

final class FingerChooserMainReactor: Reactor {
    
    let initialState: State
    private var disposeBag = DisposeBag()
    
    private let dashboardRepository: DashboardRepositoryProtocol
    
    enum Action {
        
    }
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    init(dashboardRepository: DashboardRepositoryProtocol) {
        initialState = State()
        self.dashboardRepository = dashboardRepository
    }
    
}

extension FingerChooserMainReactor {
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
}

extension FingerChooserMainReactor {
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}

