//
//  HsAudioPlayer.swift
//  MySwift
//
//  Created by li zhi on 2022/5/11.
//

import Foundation
import AVFoundation

enum AudioPlayerState {
    case playing
    case paused
    case stopped
    case failed
}

typealias HsAudioPlayerCallback = (AudioPlayerState)->Void

class HsAudioPlayer: NSObject {
    
    static let shared = HsAudioPlayer()
    
    fileprivate var playCallback: HsAudioPlayerCallback?
    
    fileprivate var player: AVPlayer?
    
    fileprivate var isPlaying = false
    
    override init() {
        super.init()
        //播放结束
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        //播放失败
        NotificationCenter.default.addObserver(self, selector: #selector(playToFailed), name: .AVPlayerItemFailedToPlayToEndTime, object: nil)
        //异常中断通知
        NotificationCenter.default.addObserver(self, selector: #selector(playToStalled), name: .AVPlayerItemPlaybackStalled, object: nil)
        //音频中断通知
        NotificationCenter.default.addObserver(self, selector: #selector(playToStalled), name: AVAudioSession.interruptionNotification, object: nil)
        //音频线路改变（耳机插入、拔出）
        NotificationCenter.default.addObserver(self, selector: #selector(playToPause), name: AVAudioSession.silenceSecondaryAudioHintNotification, object: nil)
    }
    
    func play(url: URL, callback:@escaping HsAudioPlayerCallback) {
        
        if isPlaying {
            player?.pause()
            playCallback?(.paused)
        }
        isPlaying = true
        playCallback = callback
        
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.volume = 1
        player?.play()
    }
    
    func pause()  {
        self.player?.pause()
    }
}
// MARK: - Notification
extension HsAudioPlayer {
    @objc func playToEndTime(){
        isPlaying = false
        playCallback?(.stopped)
    }
    
    @objc func playToFailed(){
        isPlaying = false
        playCallback?(.failed)
    }
    
    @objc func playToStalled(){
        isPlaying = false
        playCallback?(.stopped)
    }
    
    @objc func playToPause(){
        isPlaying = false
        playCallback?(.paused)
        player?.pause()
    }
}

