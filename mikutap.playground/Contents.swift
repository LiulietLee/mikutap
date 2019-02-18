import MetalKit
import PlaygroundSupport

let device = MTLCreateSystemDefaultDevice()!
let frame = CGRect(x: 0, y: 0, width: 800, height: 400)
let view = MetalView(frame: frame, device: device)
PlaygroundPage.current.liveView = view
