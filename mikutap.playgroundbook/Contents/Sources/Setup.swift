import MetalKit
import PlaygroundSupport

let device = MTLCreateSystemDefaultDevice()!
let frame = CGRect(x: 0, y: 0, width: 800, height: 400)

public func start(withAnimations animations: [AnimationDelegate.Type] = [], withoutAudio: Bool = false) {
    let view = MetalView(frame: frame, device: device, withoutAudio: withoutAudio)
    view.setDelegate(animations)
    PlaygroundPage.current.liveView = view
}

public func draw(_ triangles: [Triangle]) {
    if triangles.isEmpty { return }
    let view = DrawingView(frame: frame, device: device)
    view.setTriangleData(triangles)
    PlaygroundPage.current.liveView = view
}

public func set(backgroundMusic bgm: String) {
    let audio = Audio.shared
    audio.setBGM(withFileName: bgm)
}

public func set(audioFiles: [String], interval: Double = 0.2132) {
    let audio = Audio.shared
    audio.setAudio(withFileNames: audioFiles, andTimeInterval: interval)
}
