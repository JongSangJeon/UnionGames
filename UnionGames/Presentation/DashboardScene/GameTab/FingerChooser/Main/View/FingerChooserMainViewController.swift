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

let CIRCLE_DIAMETER = 100

class FingerChooserMainViewController: BaseViewController, Stepper, View {
    
    lazy var fingerTabView = UIView().then {
        $0.backgroundColor = .white
    }
    
    lazy var circleViews: [CircleView] = (0..<5).map { idx in
        CircleView().then {
            $0.backgroundColor = .red
            $0.layer.cornerRadius = 15
            $0.tag = idx
        }
    }
    
    var steps: PublishRelay<Step> = .init()
    
    override func layout() {
        self.view.addSubview(fingerTabView)
        fingerTabView.snp.makeConstraints {
            $0.top.trailing.bottom.leading.equalToSuperview()
        }
        circleViews.forEach {
            let circleView = $0
            fingerTabView.addSubview(circleView)
            circleView.snp.makeConstraints {
                $0.top.leading.equalToSuperview()
            }
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
//                    let circleView = self?.circleViews[idx]
                    
                    if let circleView = self?.circleViews.first(where: { $0.tag == idx }) {
                        circleView.snp.updateConstraints {
                            $0.centerX.equalToSuperview().offset(touchLocation.x)
                            $0.centerY.equalToSuperview().offset(touchLocation.y)
                            $0.width.height.equalTo(CIRCLE_DIAMETER)
                        }
                    }
                }
                
            }
            .disposed(by: disposeBag)
        
        fingerTabView.rx.touchDownGesture()
            .when(.ended)
            .bind { [weak self] gesture in
                let touchCount = min(gesture.numberOfTouches, 5)
                let touchLocations = (0..<touchCount).map { index -> CGPoint in
                    return gesture.location(ofTouch: index, in: self?.fingerTabView)
                }
                
                touchLocations.enumerated().forEach {
                    let idx = $0.offset
                    let touchLocation = $0.element
//                    let circleView = self?.circleViews[idx]
                    
                    if let circleView = self?.circleViews.first(where: { $0.tag == idx }) {
//                        circleView.snp.removeConstraints()
//                        self?.removeCircleAnimation(circleView: circleView)
                    }
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
    
    func removeCircleAnimation(circleView: CircleView) {
        
        let originalTransform = fingerTabView.transform
        let scaledTransform = originalTransform.scaledBy(x: 0, y: 0)
        
        UIView.animate(withDuration: 0.1, animations: {
            circleView.transform = scaledTransform
        }, completion: { _ in
//            UIView.animate(withDuration: 0.1, animations: {
//                circleView.transform = originalTransform
//            })
        })
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
            $0.width.height.equalTo(CIRCLE_DIAMETER)
        }
    }
}
