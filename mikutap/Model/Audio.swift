//
//  Audio.swift
//  mikutap
//
//  Created by Liuliet.Lee on 15/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import AVFoundation
import MediaPlayer

class Audio {
    
    static let shared = Audio()
    
    private var mainAudioPlayer = [AVAudioPlayer]()
    private var trackAudioPlayer: AVAudioPlayer?
    
    let query = MPMediaQuery.songs()
    var mediaPlayer: MPMusicPlayerController? = nil
    var mediaPlayItem: MPMediaItem? = nil {
        didSet {
            if let item = mediaPlayItem {
                let mediacollection = MPMediaItemCollection(items: [item])
                mediaPlayer = MPMusicPlayerController.systemMusicPlayer
                mediaPlayer?.repeatMode = .one
                mediaPlayer?.setQueue(with: mediacollection)
            }
        }
    }
    
    private var register = -1
    private var trackIndex = 0
    private var canPlay = true
    private var timer: Timer?
    
    init() {
        let mainString = mainBase64String
        mainAudioPlayer = mainString.lazy.map { string -> AVAudioPlayer in
            let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters)!
            return try! AVAudioPlayer(data: data)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let e {
            print(e.localizedDescription)
        }
        
        alignmentTimer()
        Timer.scheduledTimer(withTimeInterval: 13.7601875, repeats: true) { _ in
            self.alignmentTimer()
        }
    }
    
    private func alignmentTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.2142, repeats: true) { _ in
            if self.register >= 0 && self.register < 32 {
                let id = self.register
                if self.mainAudioPlayer[id].isPlaying {
                    self.mainAudioPlayer[id].currentTime = 0
                } else {
                    self.mainAudioPlayer[id].play()
                }
                self.register = -1
            }
        }
    }
    
    func playBackgroundMusic() {
        if let mediaPlayer = self.mediaPlayer {
            mediaPlayer.play()
        } else {
            do {
                guard let url = Bundle.main.url(forResource: "bgm", withExtension: "mp3") else { return }
                trackAudioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                trackAudioPlayer?.numberOfLoops = -1
                trackAudioPlayer?.volume = 0.7
                trackAudioPlayer?.play()
            } catch let e {
                print(e.localizedDescription)
            }
        }
    }
    
    func stopBackgroundMusic() {
        if let mediaPlayer = self.mediaPlayer {
            mediaPlayer.stop()
            self.mediaPlayer = nil
        } else {
            trackAudioPlayer?.stop()
            trackAudioPlayer = nil
        }
    }
    
    func play(id: Int) {
        register = id
    }
}
