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
    // relay도 쓰고...했었는데 의미없었다.
//
    var beganCount = 0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.beganCount += 1
        
        touches.forEach { touch in
            
            let touchLocation = touch.location(in: self.fingerTabView)
            let circleView = CircleView().then {
                $0.backgroundColor = .red
                $0.layer.cornerRadius = CGFloat(CIRCLE_DIAMETER / 2)
                $0.tag = touch.hashValue // 💡 핵심 부분: 이전에 RxGesture로 하지 못하였던 터치 특정화 -> cirecleView 특정화를 할 수 있게해준다.circleView를 특정해야 움직이거나 손가락을 땔때 어느 circleView를 움직이고 제거해야하는지 특정이 가능하다.
            }
            
            
            UIView.animate(withDuration: 3, animations: {
                circleView.backgroundColor = .blue
            }, completion: { _ in
    //            UIView.animate(withDuration: 0.1, animations: {
    //                circleView.transform = originalTransform
    //            })
            })
            

            self.fingerTabView.addSubview(circleView)

            circleView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(touchLocation.x - CGFloat(CIRCLE_DIAMETER / 2))
                $0.top.equalToSuperview().offset(touchLocation.y - CGFloat(CIRCLE_DIAMETER / 2))
            }

            self.circleViews.append(circleView)
        }
    }
//
    var movedCount = 0
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        self.movedCount += 1
        touches.forEach { touch in
            let touchLocation = touch.location(in: self.fingerTabView)

            // updateCircleView
            if let circleView = self.circleViews.first(where: { $0.tag == touch.hashValue }) {
                circleView.snp.updateConstraints {
                    $0.leading.equalToSuperview().offset(touchLocation.x - CGFloat(CIRCLE_DIAMETER / 2))
                    $0.top.equalToSuperview().offset(touchLocation.y - CGFloat(CIRCLE_DIAMETER / 2))
                    $0.width.height.equalTo(CIRCLE_DIAMETER)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
//           removeCircleView
        touches.forEach { touch in
            if let circleView = self.circleViews.first(where: { $0.tag == touch.hashValue }) {
                
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
    
    var cancelledCount = 0
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.circleViews.forEach {
            $0.removeFromSuperview()
        }
        
        self.circleViews = .init()
        
    }
    
    func bind(reactor: FingerChooserMainReactor) {
        self.fingerTabView.isMultipleTouchEnabled = true
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
    
    // 여기서 터치 move부터하려했으나 안됨 -> 터치 이벤트를 circleview에 전달 할 수가 없음 -> 하려면 손가락을 한번 때고 circleview를 눌러야 함 -> 결국 circleview tag에 hash박아서 특정화한다음 처리해야함
}
