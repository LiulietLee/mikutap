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
    
    private var register = -2
    private var trackIndex = 0
    private var canPlay = true
    private var timer: Timer?
    private var alignment: Timer?
    
    private var interval = 0.2132
    
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
    }
    
    private func alignmentTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if self.register == -2 || (self.register >= 0 && self.register < 32) {
                let id = self.register
                if id == -2 {
                    self.mainAudioPlayer[0].volume = 0.0
                    self.mainAudioPlayer[0].play()
                } else {
                    self.mainAudioPlayer[id].volume = 1.0
                    if self.mainAudioPlayer[id].isPlaying {
                        self.mainAudioPlayer[id].currentTime = 0
                    } else {
                        self.mainAudioPlayer[id].play()
                    }
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
        
        alignmentTimer()
        alignment = Timer.scheduledTimer(withTimeInterval: 13.72, repeats: true) { _ in
            self.alignmentTimer()
        }
    }
    
    func stopBackgroundMusic() {
        if let mediaPlayer = self.mediaPlayer {
            mediaPlayer.stop()
        } else {
            trackAudioPlayer?.stop()
            trackAudioPlayer = nil
        }
        alignment?.invalidate()
    }
    
    func play(id: Int) {
        register = id
    }
}
