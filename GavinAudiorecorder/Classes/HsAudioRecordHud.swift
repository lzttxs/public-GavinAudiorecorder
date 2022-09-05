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
                self.bgView.backgroundColor = .red
            } else {
                self.cancelIcon.isHidden = true
                self.waves.isHidden = false
                self.desLabel.text = "上滑取消"
                self.bgView.backgroundColor = .lightGray
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
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 15))
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.text = "上滑取消"
        return label
    }()
    
    lazy var countDownLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 15))
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    lazy var bgView: UIView = {
        let temp = UIView(frame: .zero)
        temp.backgroundColor = .lightGray
        temp.backgroundColor = .black
        temp.layer.cornerRadius = 10
        temp.clipsToBounds = true
        temp.alpha = 0.75
        return temp
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.view.addSubview(bgView)
        
        
        
        self.view.addSubview(waves)
       
        
        self.view.addSubview(desLabel)
        
        
        
        self.view.addSubview(countDownLabel)
        
        
        
        self.view.addSubview(cancelIcon)
       
        
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
        
        rootVC.addChildViewController(self)
        rootVC.view.addSubview(self.view)
        self.didMove(toParentViewController: rootVC)
        self.view.frame = CGRect(x: (UIScreen.main.bounds.width - 161)/2, y: (UIScreen.main.bounds.height - 44 - 91)/2, width: 161, height: 91)
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
        self.bgView.backgroundColor = .lightGray
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
            self?.willMove(toParentViewController: rootVC)
            self?.removeFromParentViewController()
            self?.view.removeFromSuperview()
        }
    }
}
