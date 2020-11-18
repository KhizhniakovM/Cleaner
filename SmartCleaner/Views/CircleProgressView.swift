//
//  CircleProgressView.swift
//  SmartCleaner
//
//  Created by Max Khizhniakov on 15.10.2020.
//  Copyright © 2020 Luchik. All rights reserved.
//
import UIKit
import Foundation

class AppConfig {
    public static let GRADIENT_COLORS: [UIColor] = [
        UIColor(rgb: 0x95EBEE), /// от 0
        UIColor(rgb: 0x7676E6), /// до 50%
        UIColor(rgb: 0x95EBEE)  /// до 100%
    ]
}
class CircleProgressView: UIView{
    /*private var minValue: Double = 0.0
    private var maxValue: Double = 14.0
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private let step: CGFloat = .pi / 400
    private var valueLabel: UILabel?*/
    private var workingWidth: CGFloat = 0.0
    private var workingHeight: CGFloat = 0.0
    private var progressLayers: [CAShapeLayer] = []
    public var value: Int = 65 {
        didSet{
//            createProgress()
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        workingWidth = frame.size.width
        workingHeight = frame.size.height
        //createCircle()
        createProgress()
    }
    
    private func createCircle(){
        let circleLayer = CAShapeLayer()
        circleLayer.path = generateUIBezierPath(workingWidth / 2).cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
//        circleLayer.strokeColor = UIColor(rgb: 0x121313).cgColor
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.lineCap = .round
        circleLayer.lineWidth = 20.0
        layer.addSublayer(circleLayer)
    }
    
    private func createProgress(){
        let step: CGFloat = .pi / 100 ///10000
        for i in 1...100{
            if i / 2 > value{
                return
            }
            let stepLayer = CAShapeLayer()
            let start = -.pi/2 + (step * CGFloat(i - 1))
            let end = -.pi/2 + (step * CGFloat(i)) + 0.001
            stepLayer.path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: workingWidth / 2, startAngle: start, endAngle: end, clockwise: true).cgPath
            stepLayer.lineCap = .round
            stepLayer.lineWidth = 20
            stepLayer.strokeEnd = 1.0
            stepLayer.strokeColor = AppConfig.GRADIENT_COLORS[0].toColor(AppConfig.GRADIENT_COLORS[1], percentage: CGFloat(i)).cgColor
            //progressLayers.append(stepLayer)
            layer.addSublayer(stepLayer)
        }
        for i in 101...200{
            if i / 2 > value{
                return
            }
            let j = i - 100
            let stepLayer = CAShapeLayer()
            let start = .pi/2 + (step * CGFloat(j - 1))
            let end = .pi/2 + (step * CGFloat(j)) + 0.001
            stepLayer.path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: workingWidth / 2, startAngle: start, endAngle: end, clockwise: true).cgPath
            stepLayer.lineCap = .round
            stepLayer.lineWidth = 20.0
            stepLayer.strokeEnd = 1.0
            stepLayer.strokeColor = AppConfig.GRADIENT_COLORS[1].toColor(AppConfig.GRADIENT_COLORS[2], percentage: CGFloat(j)).cgColor
            //progressLayers.append(stepLayer)
            layer.addSublayer(stepLayer)
        }
        /*
        for j in 1...4{
            for i in 1...100{
                let index = 100 * (j - 1) + i
                if index >= maxIndex{
                    return
                }
                let stepLayer = CAShapeLayer()
                stepLayer.path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width + 20.0, y: frame.size.height / 2.0), radius: workingWidth - 50.0, startAngle: .pi / 2 + (step * CGFloat(index - 1)), endAngle:  .pi / 2 + (step * CGFloat(index)) + .pi/400, clockwise: true).cgPath
                stepLayer.lineCap = .butt
                stepLayer.lineWidth = 80.0
                stepLayer.strokeEnd = 1.0
                stepLayer.strokeColor = AppConfig.GRADIENT_COLORS[j - 1].toColor(AppConfig.GRADIENT_COLORS[j], percentage: CGFloat(i)).withAlphaComponent(0.7).cgColor
                progressLayers.append(stepLayer)
                layer.addSublayer(stepLayer)
            }
        }*/
    }
    
    /*func createCircularPath() {
        let circleLayer3 = CAShapeLayer()
        circleLayer3.path = generateUIBezierPath(workingWidth - 90.0).cgPath
        circleLayer3.fillColor = UIColor(rgb: 0xF0EFFF).cgColor
        circleLayer3.lineCap = .butt
        circleLayer3.lineWidth = 10.0
        let circleLayer = CAShapeLayer()
        circleLayer.path = generateUIBezierPath(workingWidth - 30.0).cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = .butt
        circleLayer.lineWidth = 6.0
        circleLayer.strokeEnd = 1.0
        circleLayer.strokeColor = UIColor(rgb: 0xECECEC).cgColor
        let circleLayer2 = CAShapeLayer()
        circleLayer2.path = generateUIBezierPath(workingWidth - 5.0).cgPath
        circleLayer2.fillColor = UIColor.clear.cgColor
        circleLayer2.lineCap = .butt
        circleLayer2.lineWidth = 10.0
        circleLayer2.strokeEnd = 1.0
        circleLayer2.strokeColor = UIColor(rgb: 0xECECEC).cgColor
        //circleLayer2.strokeEnd = 1.0
        //circleLayer2.strokeColor = UIColor(rgb: 0xECECEC).cgColor
        layer.addSublayer(circleLayer)
        layer.addSublayer(circleLayer2)
        layer.addSublayer(circleLayer3)
        
        createProgress()
        
        valueLabel = UILabel(frame: CGRect(x: frame.size.width - 50, y: frame.size.height / 2, width: 50, height: 100))
        valueLabel!.center = CGPoint(x: frame.size.width - 20, y: frame.size.height / 2)
        valueLabel!.text = "\(Int(value))"
        valueLabel!.textAlignment = .center
        valueLabel!.font = UIFont.systemFont(ofSize: 80.0, weight: .semibold)
        addSubview(valueLabel!)
        self.bringSubviewToFront(valueLabel!)
    }
    }
    
    private func createSteps(){
        let step : CGFloat = .pi / 7
        for i in 1...6{
            let radius = workingWidth - 55.0
            let xCenter = frame.size.width + 30.0
            let yCenter = frame.size.height / 2.0
            let x = xCenter - radius * sin(step * CGFloat(i))
            let y = yCenter + radius * cos(step * CGFloat(i))
            let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
            label.center = CGPoint(x: x, y: y)
            label.text = "\(i * 2)"
            label.font = UIFont.systemFont(ofSize: 30.0, weight: .semibold)
            label.textColor = .black
            label.textAlignment = .center
            addSubview(label)
        }
    }*/
    
}
extension CircleProgressView{
    func generateUIBezierPath(_ radius: CGFloat) -> UIBezierPath{
        return UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2, y: frame.size.height / 2.0), radius: radius, startAngle: 0, endAngle:  2 * .pi, clockwise: true)
    }
}
