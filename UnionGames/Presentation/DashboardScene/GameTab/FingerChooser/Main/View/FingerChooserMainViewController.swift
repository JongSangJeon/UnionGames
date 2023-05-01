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

let CIRCLE_DIAMETER = 150
let IS_SELECTED = -9999

enum State {
    case began
    case completed
}

class FingerChooserMainViewController: BaseViewController, Stepper, View {
    
    private var state: State = .began
    
    private var fingerCount: Int = 1
    
    lazy var fingerTabView = UIView().then {
        $0.backgroundColor = .white
        $0.isMultipleTouchEnabled = true
    }
    
    lazy var pickerView = UIPickerView()
    
    lazy var circleViews: [CircleView] = .init()
    
    var steps: PublishRelay<Step> = .init()
    
    private var fingerCountRelay = BehaviorRelay<Int>.init(value: 0)
    
    override func layout() {
        self.view.addSubview(fingerTabView)
        fingerTabView.snp.makeConstraints {
            $0.top.trailing.bottom.leading.equalToSuperview()
        }
        
        self.view.addSubview(pickerView)

        pickerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.width.equalTo(300)
            $0.height.equalTo(300)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        switch state {
        case .began:
            makeCircleView(touches)
        case .completed:
            removeAllCircleView()
            makeCircleView(touches)
            state = .began
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let newCount: Int = fingerCountRelay.value + touches.count
        
        fingerCountRelay.accept(newCount)
        makeCircleViewMovedAnimation(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        let newCount: Int = fingerCountRelay.value - touches.count
        
        fingerCountRelay.accept(newCount)
        removeCircleView(touches)
        state = .completed
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        fingerCountRelay.accept(0)
        removeAllCircleView()
        state = .began
    }
    
    func bind(reactor: FingerChooserMainReactor) {
        
        Observable.just(Array(1...4))
            .bind(to: pickerView.rx.itemTitles) { _, number in
                return "\(number)"
            }
            .disposed(by: disposeBag)

        pickerView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let selectedNumber = indexPath.row
                self?.fingerCount = selectedNumber + 1
            })
            .disposed(by: disposeBag)
        
        
        self.fingerCountRelay
            .filter({
                $0 >= self.fingerCount
            })
            .filter({ _ in
                
                if self.circleViews.isEmpty {
                    return false
                }
                
                if let _ = self.circleViews.first(where: {
                    $0.isCompleted == false
                }) {
                    return false
                } else {
                    return true
                }
            })
            .bind { _ in
                
                let uniqueRandomNumbers = self.generateUniqueRandomNumbers(from: 0..<self.circleViews.count, count: self.fingerCount)
                
                uniqueRandomNumbers.forEach { uniqueRandomNumber in
                    let chosenCircleView: CircleView = self.circleViews[uniqueRandomNumber]
                    
                    chosenCircleView.tag = IS_SELECTED
                    chosenCircleView.startShineAnimation()
                }
                
                self.removeAllCircleView(withoutTargetTag: IS_SELECTED)
            }
            .disposed(by: self.disposeBag)
        
    }
}

private extension FingerChooserMainViewController {
    func makeCircleView(_ touches: Set<UITouch>) {
        touches.forEach { touch in
            
            let touchLocation = touch.location(in: self.fingerTabView)
            let circleView = CircleView().then {
                $0.backgroundColor = .white
                $0.layer.cornerRadius = CGFloat(CIRCLE_DIAMETER / 2)
                /*
                 *💡 핵심 부분: 이전에 RxGesture로 하지 못하였던 터치 특정화
                 * cirecleView 특정화를 할 수 있게해준다.
                 * circleView를 특정해야 움직이거나 손가락을 땔때 어느 circleView를 움직이고 제거해야하는지 특정이 가능하다.
                 */
                $0.tag = touch.hashValue
            }
            
            
            UIView.animate(withDuration: 3, animations: {
                circleView.backgroundColor = .blue
            }, completion: { _ in
                circleView.isCompleted = true
            })
            

            self.fingerTabView.addSubview(circleView)

            circleView.snp.makeConstraints {
                $0.leading.equalToSuperview().offset(touchLocation.x - CGFloat(CIRCLE_DIAMETER / 2))
                $0.top.equalToSuperview().offset(touchLocation.y - CGFloat(CIRCLE_DIAMETER / 2))
            }

            self.circleViews.append(circleView)
        }

    }
    
    func makeCircleViewMovedAnimation(_ touches: Set<UITouch>) {
        touches.forEach { touch in
            let touchLocation = touch.location(in: self.fingerTabView)

            if let circleView = self.circleViews.first(where: { $0.tag == touch.hashValue }) {
                circleView.snp.updateConstraints {
                    $0.leading.equalToSuperview().offset(touchLocation.x - CGFloat(CIRCLE_DIAMETER / 2))
                    $0.top.equalToSuperview().offset(touchLocation.y - CGFloat(CIRCLE_DIAMETER / 2))
                    $0.width.height.equalTo(CIRCLE_DIAMETER)
                }
            }
        }
    }

    func removeCircleView(_ touches: Set<UITouch>) {
        touches.forEach { touch in
            if let circleView = self.circleViews.first(where: { $0.tag == touch.hashValue }) {
                
                self.circleViews = self.circleViews.filter({
                    $0.tag != circleView.tag
                })
                
                circleView.removeFromSuperview()
            }
        }
    }

    func removeAllCircleView(withoutTargetTag: Int? = nil) {
        if let withoutTargetTag {
            
            self.circleViews.filter({
                $0.tag != withoutTargetTag
            }).forEach {
                $0.removeFromSuperview()
            }
            
        } else {
            fingerTabView.subviews.forEach {
                if $0 is CircleView {
                    $0.removeFromSuperview()
                }
            }
        }
        
        self.circleViews = .init()
    }
}

extension FingerChooserMainViewController {
    func generateUniqueRandomNumbers(from range: Range<Int>, count: Int) -> [Int] {
        var numbers = Set<Int>()
        
        while numbers.count < count {
            let randomNumber = Int.random(in: range)
            numbers.insert(randomNumber)
        }
        
        return Array(numbers)
    }

}

















class CircleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupShineButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        setupShineButton()
    }

    var isCompleted: Bool = false
    
    private var shineButton: WCLShineButton!
    
    private func setupShineButton() {
        shineButton = WCLShineButton(frame: CGRect(x: 0, y: 0, width: CIRCLE_DIAMETER, height: CIRCLE_DIAMETER))
        shineButton.image = .init(named: "rec")!
        let imageColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        let imageColor2 = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        shineButton.color = imageColor
        shineButton.fillColor = imageColor2
        let shineCount: Int = .random(in: 15...30)
        
        var param1 = WCLShineParams()
        param1.bigShineColor = #colorLiteral(red: 1, green: 0.8, blue: 0.8, alpha: 1)
        param1.shineCount = shineCount
        param1.smallShineColor = #colorLiteral(red: 0.6, green: 0.4, blue: 0.6, alpha: 1)
        param1.shineTurnAngle = 50
        param1.smallShineOffsetAngle = 50
        param1.animDuration = 2
        
        var param2 = WCLShineParams()
        param2.enableFlashing = true
        param2.bigShineColor = #colorLiteral(red: 1, green: 0.3725490196, blue: 0.3490196078, alpha: 1)
        param2.smallShineColor = #colorLiteral(red: 0.8470588235, green: 0.5960784314, blue: 0.5803921569, alpha: 1)
        param2.shineCount = shineCount
        param2.animDuration = 2
        param2.smallShineOffsetAngle = -5
        
        var param3 = WCLShineParams()
        param3.bigShineColor = #colorLiteral(red: 1, green: 1, blue: 0.6, alpha: 1)
        param3.smallShineColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        param2.shineCount = shineCount
        param3.allowRandomColor = true
        param3.animDuration = 2
        
        var param4 = WCLShineParams()
        param4.enableFlashing = true
        param4.bigShineColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        param4.smallShineColor = #colorLiteral(red: 1, green: 1, blue: 0.6, alpha: 1)
        param4.shineCount = shineCount
        param4.shineTurnAngle = 50
        param4.smallShineOffsetAngle = 50
        param4.animDuration = 2
        
        var param5 = WCLShineParams()
        param5.enableFlashing = true
        param5.bigShineColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        param5.smallShineColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        param5.shineCount = shineCount
        param5.shineTurnAngle = 50
        param5.smallShineOffsetAngle = 50
        param5.animDuration = 2
        
        let randomCount: Int = .random(in: 0..<5)
        let shineParams: WCLShineParams = [param1, param2, param3, param4, param5][randomCount]
        
        shineButton.params = shineParams
        
        addSubview(shineButton)
    }
    
    func setupView() {
        self.clipsToBounds = false
        self.snp.makeConstraints {
            $0.width.height.equalTo(CIRCLE_DIAMETER)
        }
    }
    
    func startShineAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.shineButton.setClicked(!self.shineButton.isSelected, animated: true)
        })
    }
    
    func translateButtonColor() {
        let imageColor2 = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        shineButton.fillColor = imageColor2
    }
    // 여기서 터치 move부터하려했으나 안됨 -> 터치 이벤트를 circleview에 전달 할 수가 없음 -> 하려면 손가락을 한번 때고 circleview를 눌러야 함 -> 결국 circleview tag에 hash박아서 특정화한다음 처리해야함
}
