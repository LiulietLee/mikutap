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
    private var player: AVAudioPlayer?
    
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
    }
    
    func playBackgroundMusic() {
        do {
            guard let url = Bundle.main.url(forResource: "bgm", withExtension: "mp3") else { return }
            trackAudioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            trackAudioPlayer?.numberOfLoops = -1
            trackAudioPlayer?.play()
        } catch let e {
            print(e.localizedDescription)
        }
    }
    
    func play(id: Int) {
        DispatchQueue.global(qos: .userInteractive).async {
            if self.canPlay {
                self.canPlay = false
                if self.mainAudioPlayer[id].isPlaying {
                    self.mainAudioPlayer[id].currentTime = 0
                } else {
                    self.mainAudioPlayer[id].play()
                }
                DispatchQueue.main.async {
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false, block: { _ in
                        self.canPlay = true
                    })
                }
            }
        }
    }
}
