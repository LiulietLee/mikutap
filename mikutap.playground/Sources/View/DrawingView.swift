import UIKit
import MetalKit

class DrawingView: MTKView {
    
    private var animation: CustomizedAnimation?
    
    private var commandQueue: MTLCommandQueue?
    private var rps: MTLRenderPipelineState?
    private var semaphore: DispatchSemaphore!

    private func commonInit() {
        semaphore = DispatchSemaphore(value: 3)
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device!.makeCommandQueue()
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setTriangleData(_ triangle: [Triangle]) {
        class InnerDelegate: AnimationDelegate {
            var triangle: [Triangle]
            var duration: Int
            var shaderColor: UIColor
            required init() {
                self.triangle = []
                duration = 4000
                shaderColor = .white
            }
            func update(_ schedule: Float) {}
        }
        animation = CustomizedAnimation(device: device!, width: 1.0, height: 1.0, delegate: InnerDelegate.self)
        animation!.setTriangle(triangle)
    }
    
    override func draw(_ dirtyRect: CGRect) {
        super.draw(dirtyRect)
        
        autoreleasepool {
            semaphore.wait()
            
            if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor {
                rpd.colorAttachments[0].clearColor = MTLClearColor(red: 0.545, green: 0.800, blue: 0.800, alpha: 1.000)
                let commandBuffer = commandQueue!.makeCommandBuffer()
                
                if animation != nil, !animation!.setCommandEncoder(cb: commandBuffer!, rpd: rpd) {
                    animation!.reset()
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
