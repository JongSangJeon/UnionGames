//
//  FingerChooserMainViewController.swift
//  UnionGames
//
//  Created by jeonjongsang on 2023/04/23.
//

import UIKit

import ReactorKit
import RxCocoa
import RxFlow
import Then

class FingerChooserMainViewController: BaseViewController, Stepper, View {
    
    lazy var fingerTabView = UIView().then {
        $0.backgroundColor = .white
    }
    
    lazy var circleViews: [CircleView] = {
        var views: [CircleView] = []
        for _ in 0..<5 {
            let circleView = CircleView().then {
                $0.backgroundColor = .red
                $0.layer.cornerRadius = 15
            }
            views.append(circleView)
        }
        return views
    }()
    
    
    var steps: PublishRelay<Step> = .init()
    
    override func layout() {
        self.view.addSubview(fingerTabView)
        fingerTabView.snp.makeConstraints {
            $0.top.trailing.bottom.leading.equalToSuperview()
        }
        circleViews.enumerated().forEach {
            
            let idx = $0.offset
            let circleView = $0.element
            circleView.tag = idx
            
            fingerTabView.addSubview(circleView)
            circleView.snp.makeConstraints {
                $0.top.leading.equalToSuperview()
            }
            addCircleViewMoveAnimation(circleView: circleView)
        }
    }
    
    func bind(reactor: FingerChooserMainReactor) {
        fingerTabView.rx.touchDownGesture()
            .when(.began, .changed)
            .bind { [weak self] gesture in
                let touchCount = min(gesture.numberOfTouches, 5)
                let touchLocations = (0..<touchCount).map { index -> CGPoint in
                    return gesture.location(ofTouch: index, in: self?.fingerTabView)
                }
                
                touchLocations.enumerated().forEach {
                    let idx = $0.offset
                    let touchLocation = $0.element
                    let circleView = self?.circleViews[idx]
                    
//                    if let circleView = self?.circleViews.first(where: { $0.tag == idx }) {
                    
                    circleView?.snp.updateConstraints {
                        $0.leading.equalToSuperview().offset(touchLocation.x)
                        $0.top.equalToSuperview().offset(touchLocation.y)
                        $0.width.height.equalTo(30)
                    }
//                    }
                }
                
            }
            .disposed(by: disposeBag)
    }
}

private extension FingerChooserMainViewController {
    func makeCircleViewScaleAnimation(circleView: CircleView) {
        let originalTransform = fingerTabView.transform
        let scaledTransform = originalTransform.scaledBy(x: 0.9, y: 0.9)
        
        UIView.animate(withDuration: 0.1, animations: {
            circleView.transform = scaledTransform
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                circleView.transform = originalTransform
            })
        })
    }
    
    func addCircleViewMoveAnimation(circleView: CircleView) {
        circleView.rx.panGesture()
            .when(.changed)
            .map { gesture in
                gesture.location(in: gesture.view)
            }
            .bind { touchLocation in
                
                circleView.snp.updateConstraints {
                    $0.leading.equalToSuperview().offset(touchLocation.x)
                    $0.top.equalToSuperview().offset(touchLocation.y)
                    $0.width.height.equalTo(30)
                }
            }.disposed(by: disposeBag)
    }
    
//    func makeCircleViewMoveAnimation(circleView: CircleView, locations: ) {
//
//        let leadingOffset: CGFloat = locations[0]
//        let topOffset: CGFloat = locations[1]
//
//        circleView.snp.updateConstraints {
//            $0.leading.equalToSuperview().offset(leadingOffset)
//            $0.top.equalToSuperview().offset(topOffset)
//        }
//    }
}

class CircleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func setupView() {
        self.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
    }
}
