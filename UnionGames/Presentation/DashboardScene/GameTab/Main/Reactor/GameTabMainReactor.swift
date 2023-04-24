//
//  GameTabMainReactor.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import UIKit

import ReactorKit
import RxSwift

final class GameTabMainReactor: Reactor {
    
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

extension GameTabMainReactor {
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
}

extension GameTabMainReactor {
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
