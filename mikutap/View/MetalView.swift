//
//  MetalView.swift
//  mikutap
//
//  Created by Liuliet.Lee on 6/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class MetalView: MTKView, NSWindowDelegate {
    
    private var ongoingAnimation = [AbstractAnimation]()
    private var animationType = [RoundFenceAnimation.self, SquareFenceAnimation.self, ShakeDotAnimation.self, SpiralDotAnimation.self, ScaleAnimation.self, SegmentAnimation.self, ExplosionCircleAnimation.self, ExplosionSquareAnimation.self, CircleAnimation.self,  XAnimation.self, PolygonFillAnimation.self, PolygonStrokeAnimation.self]
    private var animation = [AbstractAnimation.Type]()
    
    private var commandQueue: MTLCommandQueue?
    private var rps: MTLRenderPipelineState?
    private var semaphore: DispatchSemaphore!
    private var backgroundColor: MTLClearColor!
    private var mouseCount = 0
    private let audio = Audio.shared
    private var currentAreaID = -1
    
    private var width: CGFloat { return bounds.size.width }
    private var height: CGFloat { return bounds.size.height }
    private var aspect: CGFloat { return height / width }

    private func initAnimation() {
        for i in 0..<32 {
            animation.append(animationType[i % animationType.count])
        }
    }
    
    private func commonInit() {
        semaphore = DispatchSemaphore(value: 3)
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device!.makeCommandQueue()
        
        backgroundColor = ColorPool.shared.getCurrentBackgroundColor()
        ongoingAnimation.append(PlaceholderAnimation(device: device!))
        audio.playBackgroundMusic()
        initAnimation()
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func inBound(_ pos: NSPoint) -> Bool {
        return 0 < pos.x && pos.x < width && 0 < pos.y && pos.y < height
    }
    
    private func getTouchedAreaID(position pos: NSPoint) -> Int {
        if !inBound(pos) { return currentAreaID }
        let row = Int(pos.y / (height / 4))
        let col = Int(pos.x / (width / 8))
        return row * 8 + col
    }
    
    private func getPoint(from event: NSEvent) -> NSPoint {
        return convertToLayer(convert(event.locationInWindow, from: nil))
    }
    
    private func addAnimation(withID id: Int = -1) {
        let id = id == -1 ? currentAreaID : id
        let currentAnimation = animation[id].init(device: device!, aspect: aspect)
        ongoingAnimation.append(currentAnimation)
        audio.play(id: id)
        
        if ongoingAnimation.count >= 13 || mouseCount > 15 {
            if ongoingAnimation.count >= 8 {
                for _ in 0..<ongoingAnimation.count / 2 {
                    ongoingAnimation.removeFirst()
                }
            }
            mouseCount = 0
            ongoingAnimation.insert(TransitionAnimation(device: device!, aspect: aspect), at: 1)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        let areaID = getTouchedAreaID(position: getPoint(from: event))
        if areaID != currentAreaID {
            currentAreaID = areaID
            addAnimation()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        mouseCount += 1
        currentAreaID = getTouchedAreaID(position: getPoint(from: event))
        addAnimation()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        autoreleasepool {
            semaphore.wait()
            
            if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor {
                rpd.colorAttachments[0].clearColor = backgroundColor

                let commandBuffer = commandQueue!.makeCommandBuffer()
                if ongoingAnimation.isEmpty {
                    let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
                    commandEncoder?.endEncoding()
                } else {
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
                            backgroundColor = ColorPool.shared.getCurrentBackgroundColor()
                        }
                        ongoingAnimation.remove(at: i)
                    }
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
