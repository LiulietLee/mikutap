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
    private var animationType = [RoundFenceAnimation.self, SquareFenceAnimation.self, ShakeDotAnimation.self, SpiralDotAnimation.self, ScaleAnimation.self, SegmentAnimation.self, ExplosionCircleAnimation.self, ExplosionSquareAnimation.self, CircleAnimation.self,  XAnimation.self, PolygonFillAnimation.self, PolygonStrokeAnimation.self]
    
    private var commandQueue: MTLCommandQueue?
    private var rps: MTLRenderPipelineState?
    private var semaphore: DispatchSemaphore!
    private var backgroundClearColor: MTLClearColor!
    private var mouseCount = 0
    private let audio = Audio.shared
    private var currentAreaID = -1
    
    private var width: CGFloat { return bounds.size.width }
    private var height: CGFloat { return bounds.size.height }

    private func initAnimation() {
        for i in 0..<32 {
            animation.append(animationType[i % animationType.count])
        }
    }
    
    private func initGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(fingerMoved(_:)))
        addGestureRecognizer(pan)
        isUserInteractionEnabled = true
    }
    
    private func initFeedbackView() {
//        print("\(width) \(height)")
        let viewWidth = UIScreen.main.bounds.size.width / 8
        let viewHeight = UIScreen.main.bounds.size.height / 4
        for i in 0..<32 {
            let row = CGFloat(i / 8), col = CGFloat(i % 8)
            let view = FlashView(frame: CGRect(x: col * viewWidth, y: row * viewHeight, width: viewWidth, height: viewHeight))
            feedbackView.append(view)
            addSubview(view)
        }
    }
    
    private func commonInit() {
        semaphore = DispatchSemaphore(value: 3)
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device!.makeCommandQueue()
        
        backgroundClearColor = ColorPool.shared.getCurrentBackgroundColor()
        ongoingAnimation.append(PlaceholderAnimation(device: device!))
//        audio.playBackgroundMusic()
        
        initAnimation()
        initGesture()
        initFeedbackView()
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
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
        for touch in touches {
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
        let currentAnimation = animation[id].init(device: device!, width: width, height: height)
        ongoingAnimation.append(currentAnimation)
//        audio.play(id: id)
        feedbackView[id].flash()
        
        if ongoingAnimation.count >= 13 || mouseCount > 15 {
            if ongoingAnimation.count >= 8 {
                for _ in 0..<ongoingAnimation.count / 2 {
                    ongoingAnimation.removeFirst()
                }
            }
            mouseCount = 0
            ongoingAnimation.insert(TransitionAnimation(device: device!, width: width, height: height), at: 1)
        }
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
                
                commandBuffer?.present(drawable)
                commandBuffer?.addCompletedHandler({ cb in
                    self.semaphore.signal()
                })
                commandBuffer?.commit()
            }
        }
    }
}
