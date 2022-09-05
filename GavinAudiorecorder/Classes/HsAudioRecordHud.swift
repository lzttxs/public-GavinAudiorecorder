//
//  HsAudioRecordHud.swift
//  MySwift
//
//  Created by li zhi on 2022/5/9.
//

import Foundation
import UIKit

class HsAudioRecordHUD: UIViewController {
    
    var isCancelState: Bool {
        didSet {
            if isCancelState {
                self.desLabel.text = "松开取消"
                self.cancelIcon.isHidden = false
                self.waves.isHidden = true
                self.bgView.backgroundColor = UIColor(hex: 0xFB3636)
            } else {
                self.cancelIcon.isHidden = true
                self.waves.isHidden = false
                self.desLabel.text = "上滑取消"
                self.bgView.backgroundColor = UIColor(hex: 0x373636)
                self.bgView.backgroundColor = .black
            }
        }
    }
    
    
    static let shared = HsAudioRecordHUD(nibName: nil, bundle: nil)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.isCancelState = false
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    lazy var waves: HsSonicWavesView = {
        let temp = HsSonicWavesView(frame: .zero)
        return temp
    }()
    
    lazy var cancelIcon: UIImageView = {
        let temp = UIImageView(image: UIImage(named: "chat_record_cancelIcon"))
        return temp
    }()
    
    lazy var desLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 15))
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.text = "上滑取消"
        return label
    }()
    
    lazy var countDownLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 15))
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    lazy var bgView: UIView = {
        let temp = UIView(frame: .zero)
        temp.backgroundColor = UIColor(hex: 0x373636)
        temp.backgroundColor = .black
        temp.cornerRadius = 10
        temp.clipsToBounds = true
        temp.alpha = 0.75
        return temp
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgView.snp.remakeConstraints { make in
            make.left.right.top.bottom.equalTo(0)
        }
        
        waves.snp.remakeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(15)
            make.height.equalTo(30)
        }
        
        desLabel.snp.remakeConstraints { make in
            make.bottom.equalTo(-25)
            make.left.right.equalTo(0)
        }
        
        countDownLabel.snp.remakeConstraints { make in
            make.bottom.equalTo(-8)
            make.left.right.equalTo(0)
        }
        
        cancelIcon.snp.remakeConstraints { make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(20)
            make.width.height.equalTo(20)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(0)
        }
        
        self.view.addSubview(waves)
        waves.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.top.equalTo(15)
            make.height.equalTo(30)
        }
        
        self.view.addSubview(desLabel)
        desLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-25)
            make.left.right.equalTo(0)
        }
        
        self.view.addSubview(countDownLabel)
        countDownLabel.snp.makeConstraints { make in
            make.bottom.equalTo(-8)
            make.left.right.equalTo(0)
        }
        
        self.view.addSubview(cancelIcon)
        cancelIcon.snp.makeConstraints { make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(20)
            make.width.height.equalTo(20)
        }
    }
    
    static func changeState(isCancel: Bool) {
        HsAudioRecordHUD.shared.isCancelState = isCancel
    }
    
    static func countDown(duration: Int) {
        HsAudioRecordHUD.shared.countDownLabel.text = "还剩\(duration)秒"
    }
    
    static func show() {
        HsAudioRecordHUD.shared.show()
    }
    
    fileprivate func show() {
        guard let keyWindow = UIApplication.shared.keyWindow, let rootVC = keyWindow.rootViewController else { return }
        
        rootVC.addChild(self)
        rootVC.view.addSubview(self.view)
        self.didMove(toParent: rootVC)
        self.view.frame = CGRect(x: (kScreenW - 161)/2, y: (kScreenH - kNavigaH - 91)/2, width: 161, height: 91)
        self.view.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowAnimatedContent) { [weak self] in
            self?.view.alpha = 1
        } completion: { [weak self] result in
            self?.waves.startRecord()
        }
    }
    
    func resetConfig() {
        waves.stopRecord()
        self.desLabel.text = "上滑取消"
        self.countDownLabel.text = ""
        self.bgView.backgroundColor = UIColor(hex: 0x373636)
        bgView.backgroundColor = .black
    }
    
    static func hidden() {
        HsAudioRecordHUD.shared.closeMenu()
    }
    
    fileprivate func closeMenu() {
        self.view.alpha = 1
        UIView.animate(withDuration: 0.2, delay: 0, options: .allowAnimatedContent) { [weak self] in
            self?.view.alpha = 0
        } completion: { [weak self] result in
            self?.resetConfig()
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            self?.willMove(toParent: rootVC)
            self?.removeFromParent()
            self?.view.removeFromSuperview()
        }
    }
}
