//
//  MetalView.swift
//  mikutap
//
//  Created by Liuliet.Lee on 6/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit
import MetalKit

class MetalView: MTKView {
    
    private var feedbackView = [FlashView]()
    private var ongoingAnimation = [AbstractAnimation]()
    private var animation = [AbstractAnimation.Type]()
    private var animationType = [
        RoundFenceAnimation.self,
        SquareFenceAnimation.self,
        ShakeDotAnimation.self,
        SpiralDotAnimation.self,
        ScaleAnimation.self,
        SegmentAnimation.self,
        ExplosionCircleAnimation.self,
        ExplosionSquareAnimation.self,
        CircleAnimation.self,
        XAnimation.self,
        PolygonFillAnimation.self,
        PolygonStrokeAnimation.self
    ]
    
    private var animationDelegate = [AnimationDelegate.Type]()
    
    private var pauseButton: UIButton!
    private var tipLabel: UILabel!
    private var labelHidden = false
    
    private var commandQueue: MTLCommandQueue?
    private var rps: MTLRenderPipelineState?
    private var semaphore: DispatchSemaphore!
    private var backgroundClearColor: MTLClearColor!
    private var mouseCount = 0
    private let audio = Audio.shared
    private var currentAreaID = -1
    private var customAnimation = false
    private var customAudio = false
    private var withoutAudio = false
    private var isAudioPlaying = true {
        didSet {
            if isAudioPlaying {
                pauseButton.setTitle("ON", for: .normal)
                audio.playBackgroundMusic()
            } else {
                pauseButton.setTitle("OFF", for: .normal)
                audio.stopBackgroundMusic()
            }
        }
    }
    
    private var width: CGFloat { return bounds.size.width }
    private var height: CGFloat { return bounds.size.height }
    
    private func initAnimation() {
        animationType.shuffle()
        for i in 0..<32 {
            animation.append(animationType[i % animationType.count])
        }
    }
    
    func setDelegate(_ delegate: [AnimationDelegate.Type]) {
        if delegate.isEmpty { return }
        customAnimation = true
        let delegate = delegate.shuffled()
        for i in 0..<32 {
            animationDelegate.append(delegate[i % delegate.count])
        }
    }
    
    private func initGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(fingerMoved(_:)))
        addGestureRecognizer(pan)
        isUserInteractionEnabled = true
    }
    
    private func initFeedbackView() {
        var cons = [NSLayoutConstraint]()
        for i in 0..<32 {
            let row = CGFloat(i / 8), col = CGFloat(i % 8)
            let view = FlashView()
            feedbackView.append(view)
            addSubview(view)
            
            if row != 0 || col != 0 {
                cons.append(contentsOf: [
                    view.widthAnchor.constraint(equalTo: feedbackView[0].widthAnchor),
                    view.heightAnchor.constraint(equalTo: feedbackView[0].heightAnchor)
                    ])
            }
            
            cons.append(view.topAnchor.constraint(equalTo: row == 0 ? topAnchor : feedbackView[i - 8].bottomAnchor))
            cons.append(view.leadingAnchor.constraint(equalTo: col == 0 ? leadingAnchor : feedbackView[i - 1].trailingAnchor))
            
            if row == 3 {
                cons.append(view.bottomAnchor.constraint(equalTo: bottomAnchor))
            }
            if col == 7 {
                cons.append(view.trailingAnchor.constraint(equalTo: trailingAnchor))
            }
        }
        NSLayoutConstraint.activate(cons)
    }
    
    private func initTipLabel() {
        tipLabel = UILabel()
        tipLabel.text = "TOUCH & SWIPE!"
        tipLabel.font = UIFont(name: "Avenir", size: 34.0)
        tipLabel.textColor = .white
        addSubview(tipLabel)
        
        tipLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tipLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            tipLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
    }
    
    private func initSongSelector() {
        let selector = SongSelector()
        addSubview(selector)
        
        selector.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selector.centerXAnchor.constraint(equalTo: centerXAnchor),
            selector.centerYAnchor.constraint(equalTo: centerYAnchor),
            selector.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            selector.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8)
            ])
    }
    
    private func initPauseButton() {
        pauseButton = UIButton()
        pauseButton.backgroundColor = .white
        pauseButton.layer.masksToBounds = true
        pauseButton.layer.cornerRadius = 24.0
        pauseButton.alpha = 0.618
        pauseButton.setTitleColor(.darkGray, for: .normal)
        pauseButton.setTitle("ON", for: .normal)
        pauseButton.addTarget(self, action: #selector(changeAudioState), for: .touchUpInside)
        addSubview(pauseButton)
        bringSubviewToFront(pauseButton)
        
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pauseButton.widthAnchor.constraint(equalToConstant: 48.0),
            pauseButton.heightAnchor.constraint(equalTo: pauseButton.widthAnchor),
            pauseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
            pauseButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20.0)
            ])
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        semaphore = DispatchSemaphore(value: 3)
        commandQueue = device!.makeCommandQueue()

        backgroundClearColor = ColorPool.shared.getCurrentBackgroundColor()
        ongoingAnimation.append(PlaceholderAnimation(device: device!))

        initAnimation()
        initGesture()
        initFeedbackView()
        initTipLabel()
        
        if !withoutAudio {
            initPauseButton()
        }
        
        if customAudio {
            initSongSelector()
        } else if !withoutAudio {
            audio.playBackgroundMusic()
        }
    }
    
    init(frame frameRect: CGRect, device: MTLDevice, withoutAudio: Bool = false, customAudio: Bool = false) {
        super.init(frame: frameRect, device: device)
        self.withoutAudio = withoutAudio
        self.customAudio = customAudio
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    @objc private func changeAudioState() {
        isAudioPlaying = !isAudioPlaying
    }
    
    private func inBound(_ pos: CGPoint) -> Bool {
        return 0 < pos.x && pos.x < width && 0 < pos.y && pos.y < height
    }
    
    private func getTouchedAreaID(position pos: CGPoint) -> Int {
        if !inBound(pos) { return currentAreaID }
        let row = Int(pos.y / (height / 4))
        let col = Int(pos.x / (width / 8))
        return row * 8 + col
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        mouseCount += 1
        if let touch = touches.first {
            currentAreaID = getTouchedAreaID(position: touch.location(in: self))
            addAnimation()
        }
    }
    
    @objc private func fingerMoved(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            let areaID = getTouchedAreaID(position: sender.location(in: self))
            if areaID != currentAreaID {
                currentAreaID = areaID
                addAnimation()
            }
        default:
            break
        }
    }
    
    private func addAnimation(withID id: Int = -1) {
        let id = id == -1 ? currentAreaID : id
        let currentAnimation =
            customAnimation
                ? CustomizedAnimation.init(device: device!, width: width, height: height, delegate: animationDelegate[id])
                : animation[id].init(device: device!, width: width, height: height)
        ongoingAnimation.append(currentAnimation)
        
        if !withoutAudio {
            audio.play(id: id)
        }
        
        feedbackView[id].flash()
        
        if !labelHidden {
            hideTipLabel()
        }
        
        if !customAnimation && (ongoingAnimation.count >= 13 || mouseCount > 15) {
            if ongoingAnimation.count >= 13 {
                for _ in 0..<ongoingAnimation.count * 2 / 3 {
                    ongoingAnimation.remove(at: 1)
                }
            }
            mouseCount = 0
            ongoingAnimation.insert(TransitionAnimation(device: device!, width: width, height: height), at: 1)
        }
    }
    
    private func hideTipLabel() {
        UIView.transition(with: tipLabel, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.tipLabel.textColor = .clear
            self.labelHidden = true
        }, completion: nil)
    }
    
    private func showTipLabel() {
        UIView.transition(with: tipLabel, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.tipLabel.textColor = .white
            self.labelHidden = false
        }, completion: nil)
    }
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        autoreleasepool {
            semaphore.wait()
            
            if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor {
                rpd.colorAttachments[0].clearColor = backgroundClearColor
                let commandBuffer = commandQueue!.makeCommandBuffer()
                
                var removeList = [Int]()
                for i in 0..<ongoingAnimation.count {
                    if !ongoingAnimation[i].setCommandEncoder(cb: commandBuffer!, rpd: rpd) {
                        removeList.append(i)
                        continue
                    }
                    rpd.colorAttachments[0].loadAction = .load
                }
                for i in removeList.reversed() {
                    if ongoingAnimation[i] is TransitionAnimation {
                        backgroundClearColor = ColorPool.shared.getCurrentBackgroundColor()
                    }
                    ongoingAnimation.remove(at: i)
                }
                if ongoingAnimation.count == 1, labelHidden {
                    showTipLabel()
                }
                
                commandBuffer?.present(drawable)
                commandBuffer?.addCompletedHandler({ cb in
                    self.semaphore.signal()
                })
                commandBuffer?.commit()
            }
        }
    }
}
