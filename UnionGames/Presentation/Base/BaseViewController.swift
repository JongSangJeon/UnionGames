//
//  BaseViewController.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import UIKit

import RxCocoa
import RxGesture
import RxSwift

import SnapKit

class BaseViewController: UIViewController {

    // Framework에서 사용하는 config나 attribute Label처리 등을 작성
    func attribute() {
        
    }

    func font() {
        
    }

    func layout() {
        
    }
    
    var disposeBag: DisposeBag = .init()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        attribute()
        font()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
}
