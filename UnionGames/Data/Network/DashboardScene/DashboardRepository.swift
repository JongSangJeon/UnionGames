//
//  DashboardRepository.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import Foundation

import Moya

import RxCocoa
import RxSwift

protocol DashboardRepositoryProtocol {
//    func getSearchAppStoreData(request: GetSearchAppStoreDataRequest) -> Observable<GetSearchAppStoreDataResponse>
}

final class DashboardRepository: DashboardRepositoryProtocol {
    
//    private let dashboardProvider = MoyaProvider<DashboardAPIService>()
//
//    // 앱 검색 리스트 가져오기
//    func getSearchAppStoreData(request: GetSearchAppStoreDataRequest) -> Observable<GetSearchAppStoreDataResponse> {
//
//        return dashboardProvider.rx.request(.getSearchAppStoreData(request: request))
//            .map(GetSearchAppStoreDataResponse.self)
//            .asObservable()
//            .do(onError: { print("setInbodyData - Error = \($0)") })
//    }
}

