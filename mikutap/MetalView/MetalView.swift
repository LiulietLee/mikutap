//
//  MetalView.swift
//  mikutap
//
//  Created by Liuliet.Lee on 6/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    
    private var animation = [AbstractAnimation]()
    
    private var commandQueue: MTLCommandQueue?
    private var rps: MTLRenderPipelineState?
    private var semaphore: DispatchSemaphore!

    private func commonInit() {
        semaphore = DispatchSemaphore(value: 3)
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device!.makeCommandQueue()
        
        animation.append(PolygonFillAnimation(device: device!))
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        autoreleasepool {
            semaphore.wait()
            
            if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor {
                rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.1, 0.5, 0.7, 1.0)

                let commandBuffer = commandQueue!.makeCommandBuffer()
                if animation.isEmpty {
                    let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
                    commandEncoder?.endEncoding()
                } else {
                    var removeList = [Int]()
                    for i in 0..<animation.count {
                        if !animation[i].setCommandEncoder(cb: commandBuffer!, rpd: rpd) {
                            removeList.append(i)
                            continue
                        }
                        rpd.colorAttachments[0].loadAction = .load
                    }
                    for i in removeList.reversed() {
                        animation.remove(at: i)
                    }
                    // TODO: - animation 数组清空后有概率出现闪屏问题
                    if animation.isEmpty {
                        animation.append(PolygonFillAnimation(device: device!))
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
