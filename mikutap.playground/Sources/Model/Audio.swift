//
//  Audio.swift
//  mikutap
//
//  Created by Liuliet.Lee on 15/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import AVFoundation

class Audio {
    
    static let shared = Audio()
    
    private var mainAudioPlayer = [AVAudioPlayer]()
    private var trackAudioPlayer: AVAudioPlayer?

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
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
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
        timer = Timer.scheduledTimer(withTimeInterval: 0.2132, repeats: true) { _ in
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
    
    func stopBackgroundMusic() {
        trackAudioPlayer?.stop()
        trackAudioPlayer = nil
    }
    
    func play(id: Int) {
        register = id
    }
}
