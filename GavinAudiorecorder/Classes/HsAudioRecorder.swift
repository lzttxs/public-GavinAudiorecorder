//
//  HsAudioRecorder.swift
//  MySwift
//
//  Created by li zhi on 2022/5/9.
//

import Foundation
import AVFoundation

enum Directories {
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}


class HsAudioRecorder: NSObject {
    
    private var recordFilePath = Directories.documentsDirectory.appendingPathComponent("voice.caf")
    
    private var audioRecorder: AVAudioRecorder?
    
    private var displayLink: CADisplayLink?
    
    private var completion: ((Result) -> Void)?
    
    private var recordDurationProgress: ((TimeInterval, TimeInterval, Float) -> Void)?

    private let settings = [AVFormatIDKey: Int(kAudioFormatLinearPCM),
                            AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 1,
                            AVLinearPCMBitDepthKey: 16,
                            AVAudioFileTypeKey: Int(kAudioFileWAVEType),
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]

    private let maxDuration: TimeInterval = 120
    
    private var isCanceled = false
    
    func startRecording(with completion: @escaping (Result) -> Void, recordDurationProgress: @escaping (TimeInterval, TimeInterval, Float) -> Void) -> Bool {
        let permission = AVAudioSession.sharedInstance().recordPermission
        guard permission == .granted else {
            if permission == .undetermined {
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                }
            } else {
                guard let keyWindow = UIApplication.shared.keyWindow, let rootVC = keyWindow.rootViewController else { return false}
                let alert = UIAlertController(title: "无法访问麦克风", message: "开启麦克风权限才能发送语音消息", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "以后再说", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "去开启", style: .default, handler: { action in
                    guard let url = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }))
                rootVC.present(alert, animated: true)
            }
            return false
        }
        
        
        recordFilePath = Directories.documentsDirectory.appendingPathComponent("records/\(UUID().uuidString).wav")
        
        self.completion = completion
        self.recordDurationProgress = recordDurationProgress
        isCanceled = false

//        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                self.audioRecorder = try AVAudioRecorder(url: self.recordFilePath, settings: self.settings)
                self.audioRecorder?.isMeteringEnabled = true
                self.audioRecorder?.prepareToRecord()
                self.audioRecorder?.delegate = self
            } catch {
                completion(.failure(error))
                return false
            }

            AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    self.audioRecorder?.record(forDuration: self.maxDuration)
                    self.displayLink = CADisplayLink(target: self, selector: #selector(self.udateDuration))
                    self.displayLink?.preferredFramesPerSecond = 5;
                    self.displayLink?.add(to: .main, forMode: .common)
                } else {
                    self.completion?(.failure(Error.permissionDenied))
                }
            }
//        }
        return true
    }

    func stopRecording() {
        audioRecorder?.stop()
    }

    func cancel() {
        if audioRecorder?.isRecording == true {
            isCanceled = true
            audioRecorder?.stop()
            audioRecorder?.deleteRecording()
        }
    }

    @objc private func udateDuration() {
       
        guard let recorder = audioRecorder else { return }
//        let power = computePower() //效果不好，不用这种方式
        
        var duration = recorder.currentTime
        duration = duration > maxDuration ? maxDuration : duration
        if duration == maxDuration {
            stopRecording()
        }
        recordDurationProgress?(duration, maxDuration - duration, 0.0)
    }
    
    func computePower() -> Float {
        guard let recorder = audioRecorder else { return 0.0}
        recorder.updateMeters()
        let decibels = recorder.averagePower(forChannel: 0)
//        let decibels = recorder.peakPower(forChannel: 0)
        let minDecibels = -60.0
        var level: Float = 0.0
        if decibels < -60 {
            level = 0.0
        } else if decibels >= 0.0 {
            level = 1.0
        } else {
            let root = 5.0 //modified level from 2.0 to 5.0 is neast to real test
            let minAmp = powf(10.0, Float(0.05 * minDecibels))
            let inverseAmpRange = 1.0 / (1.0 - minAmp)
            let amp = powf(10.0, 0.05 * decibels)
            let adjAmp = (amp - minAmp) * inverseAmpRange
            level = powf(adjAmp, Float(1.0/root));
        }
        
        return level
    }
    
}

extension HsAudioRecorder: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        handleFinish()
        guard !isCanceled else {
            completion?(.canceled)
            return
        }

        if flag {
            
            completion?(.success(recordFilePath))
        } else {
            completion?(.failure(Error.failedToEncodeAudio))
        }
    }

    var documentURL: URL {
        let root = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: root).appendingPathComponent("下载")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
    
    func getDocumentRelativePath(_ url: URL) -> String {
        return url.relativePath.replacingOccurrences(of: documentURL.relativePath + "/", with: "")
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Swift.Error?) {
        handleFinish()
        if let error = error {
            completion?(.failure(error))
        } else {
            completion?(.failure(Error.failedToEncodeAudio))
        }
    }

    private func handleFinish() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        displayLink?.invalidate()
        displayLink = nil
        audioRecorder = nil
    }
}

extension HsAudioRecorder {
    enum Result {
        case success(URL)
        case failure(Swift.Error)
        case canceled
    }

    enum Error: LocalizedError {
        case failedToEncodeAudio
        case permissionDenied

        var errorDescription: String? {
            switch self {
            case .failedToEncodeAudio:
                return "Failed to encode audio"
            case .permissionDenied:
                return "Permission denied. Please, allow access to micro in settings"
            }
        }
    }
}
