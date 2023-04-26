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
import RxGesture
import Then

let CIRCLE_DIAMETER = 100

class FingerChooserMainViewController: BaseViewController, Stepper, View {
    
    lazy var fingerTabView = UIView().then {
        $0.backgroundColor = .white
    }
    
    lazy var circleViews: [CircleView] = .init()
    
    var steps: PublishRelay<Step> = .init()
    
    override func layout() {
        self.view.addSubview(fingerTabView)
        fingerTabView.snp.makeConstraints {
            $0.top.trailing.bottom.leading.equalToSuperview()
        }
    }
    
    func bind(reactor: FingerChooserMainReactor) {
        self.fingerTabView.isMultipleTouchEnabled = true
        
        let touchDownGesture = fingerTabView.rx.touchDownGesture().share()
        
        touchDownGesture
            .when(.began)
            .bind { [weak self] gesture in
                guard let self = self else { return }
                gesture.name = "\(UUID().hashValue)"
                let touchCount = gesture.numberOfTouches
                let touchLocations = (0..<touchCount).map { index -> CGPoint in
                    return gesture.location(ofTouch: index, in: self.fingerTabView)
                }

//                print("⭕️ --- \(gesture.hashValue)")
                touchLocations.enumerated().forEach { idx, touchLocation in

                    // makeCircleView
                    let circleView = CircleView().then {
                        $0.backgroundColor = .red
                        $0.layer.cornerRadius = CGFloat(CIRCLE_DIAMETER / 2)
                        $0.tag = idx
                    }

                    self.fingerTabView.addSubview(circleView)

                    circleView.snp.makeConstraints {
                        $0.leading.equalToSuperview().offset(touchLocation.x - CGFloat(CIRCLE_DIAMETER / 2))
                        $0.top.equalToSuperview().offset(touchLocation.y - CGFloat(CIRCLE_DIAMETER / 2))
                    }

                    self.circleViews.append(circleView)
                }
            }
            .disposed(by: disposeBag)


        touchDownGesture
            .when(.changed)
            .bind { [weak self] gesture in
                guard let self = self else { return }

                let touchCount = gesture.numberOfTouches
                let touchLocations = (0..<touchCount).map { index -> CGPoint in
                    return gesture.location(ofTouch: index, in: self.fingerTabView)
                }
//                print("❔ --- \(gesture.hashValue)")
                touchLocations.enumerated().forEach { idx, touchLocation in

                    // updateCircleView
                    if let circleView = self.circleViews.first(where: { $0.tag == idx }) {
                        circleView.snp.updateConstraints {
                            $0.leading.equalToSuperview().offset(touchLocation.x - CGFloat(CIRCLE_DIAMETER / 2))
                            $0.top.equalToSuperview().offset(touchLocation.y - CGFloat(CIRCLE_DIAMETER / 2))
                            $0.width.height.equalTo(CIRCLE_DIAMETER)
                        }
                    }
                }

            }
            .disposed(by: disposeBag)

        touchDownGesture
            .when(.ended)
            .bind { [weak self] gesture in
                guard let self = self else { return }

                let touchCount = gesture.numberOfTouches
                let touchLocations = (0..<touchCount).map { index -> CGPoint in
                    return gesture.location(ofTouch: index, in: self.fingerTabView)
                }

//                print("🔆 --- \(gesture.hashValue)")
                touchLocations.enumerated().forEach { idx, touchLocation in

                    // removeCircleView
                    if let circleView = self.circleViews.first(where: { $0.tag == idx }) {

                        self.circleViews = self.circleViews.filter({
                            $0.tag != circleView.tag
                        })

                        UIView.animate(withDuration: 0.3, animations: {
                            circleView.transform = circleView.transform.scaledBy(x: 0.1, y: 0.1)
                        }, completion: { _ in
                            circleView.removeFromSuperview()
                        })
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
