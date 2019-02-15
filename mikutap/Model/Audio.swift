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
    private var trackAudioPlayer = [AVAudioPlayer]()
    private var beatAudioPlayer = [[AVAudioPlayer]]()
    private var player: AVAudioPlayer?
    
    private var timer = Timer()
    private var trackIndex = 0
    private var canPlay = true
    
    init() {
        let mainString = mainBase64String
        for string in mainString {
            let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters)!
            mainAudioPlayer.append(try! AVAudioPlayer(data: data))
        }
        
        var playSequence = [Int]()
        for i in [3, 5, 7, 9] {
            for _ in 0..<4 {
                playSequence.append(contentsOf: [i, i + 1, i + 1])
            }
            playSequence.append(contentsOf: [i, i + 1, i, i + 1])
        }
        
        let trackString = trackBase64String
        for index in playSequence {
            let data = Data(base64Encoded: trackString[index], options: .ignoreUnknownCharacters)!
            trackAudioPlayer.append(try! AVAudioPlayer(data: data))
        }
        
        let data = [
            Data(base64Encoded: trackString[0], options: .ignoreUnknownCharacters)!,
            Data(base64Encoded: trackString[1], options: .ignoreUnknownCharacters)!,
            Data(base64Encoded: trackString[2], options: .ignoreUnknownCharacters)!
        ]
        
        beatAudioPlayer = [
            [try! AVAudioPlayer(data: data[0])],
            [try! AVAudioPlayer(data: data[0]), try! AVAudioPlayer(data: data[1])],
            [try! AVAudioPlayer(data: data[0]), try! AVAudioPlayer(data: data[2])],
            [try! AVAudioPlayer(data: data[0]), try! AVAudioPlayer(data: data[1])]
        ]
    }
    
    func playBackgroundMusic() {
        Timer.scheduledTimer(withTimeInterval: 0.215, repeats: true, block: { _ in
            self.trackAudioPlayer[self.trackIndex].play()
            let beatIndex = self.trackIndex % 4
            for player in self.beatAudioPlayer[beatIndex] {
                player.volume = 0.3
                player.play()
            }
            self.trackIndex = (self.trackIndex + 1) % self.trackAudioPlayer.count
        })
    }
    
    func play(id: Int) {
//        if canPlay {
//            canPlay = false
//            player?.stop()
            player = mainAudioPlayer[id]
            player?.play()
//            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
//                print(Int.random(in: 0...10000000))
//                self.canPlay = true
//            }
//        }
    }
}
