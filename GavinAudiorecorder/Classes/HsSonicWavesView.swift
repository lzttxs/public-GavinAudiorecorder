//
//  HsSonicWavesView.swift
//  RedLive
//
//  Created by li zhi on 2022/5/9.
//  Copyright © 2022 小屁孩. All rights reserved.
//

import Foundation
import UIKit

class HsSonicWavesView: UIView {

    let lineWidth: CGFloat = 2
    
    let marginBetweenLines: CGFloat = 0.5
    
    private var isSuspended = true
    
    private lazy var timer: DispatchSourceTimer = {
        let t: DispatchSourceTimer = DispatchSource.makeTimerSource(flags: .strict, queue: DispatchQueue.main)
        t.schedule(deadline: .now(), repeating: .milliseconds(100))
        t.setEventHandler { [weak self] in
            self?.updateProgress()
        }
        return t
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clearsContextBeforeDrawing = true
        self.backgroundColor = .clear
        self.isOpaque = true
        defaultPoint() //后期有时间换成真正的音频采样数据音量值更真实
    }
    
    func defaultPoint() {
        let array = (0..<1000).map { _ in
            CGFloat( Float.random(in: 0.02...0.2))
        }
        wavePoints = array
    }
    
    private func updateProgress() {
        if progress > 0.8 {
            progress = 0
        } else {
//            progress = (progress + 0.01).rounded(numberOfDecimalPlaces: 2, rule: .awayFromZero)
        }
    }
    
    func startRecord() {
        if isSuspended {
            timer.resume()
        }
        isSuspended = false
    }
   
    func stopRecord() {
        if isSuspended {
            return
        }
        isSuspended = true
        timer.suspend()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var wavePoints: [CGFloat] = [] {
        didSet {
            setNeedsDisplay()
        }
    }

    var progress: Float = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let topWavePath = UIBezierPath()
        let bottomWavePath = UIBezierPath()

        topWavePath.lineWidth = lineWidth
        bottomWavePath.lineWidth = lineWidth

        let xStep: CGFloat = lineWidth + marginBetweenLines

        let playedPoints = Int(Float(wavePoints.count) * progress)

        topWavePath.move(to: CGPoint(x: 0, y: rect.height / 2))
        bottomWavePath.move(to: CGPoint(x: 0, y: rect.height / 2))

        for point in wavePoints[playedPoints...] {
            let nextPoint = CGPoint(x: topWavePath.currentPoint.x + xStep,
                                    y: topWavePath.currentPoint.y)

            topWavePath.move(to: nextPoint)
            bottomWavePath.move(to: nextPoint)

            topWavePath.addLine(to: CGPoint(x: topWavePath.currentPoint.x,
                                            y: topWavePath.currentPoint.y - point * rect.height))

            bottomWavePath.addLine(to: CGPoint(x: bottomWavePath.currentPoint.x,
                                               y: bottomWavePath.currentPoint.y + point * rect.height))
            topWavePath.close()
            bottomWavePath.close()
        }

//        #colorLiteral(red: 0, green: 0.5936083198, blue: 0.8936790824, alpha: 1).set()
        #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).set()
        topWavePath.lineCapStyle = .round
        topWavePath.lineJoinStyle = .round
        topWavePath.stroke()
        topWavePath.fill()

        #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).set()
        bottomWavePath.lineCapStyle = .round
        bottomWavePath.lineJoinStyle = .round
        bottomWavePath.stroke()
        bottomWavePath.fill()
    }
}
