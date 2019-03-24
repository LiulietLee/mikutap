import MetalKit
import MediaPlayer
import PlaygroundSupport

let device = MTLCreateSystemDefaultDevice()!
let frame = CGRect(x: 0, y: 0, width: 800, height: 400)

public func start(withAnimations animations: [AnimationDelegate.Type] = [], withoutAudio: Bool = false, customBGM: Bool = false) {
    stopBGM()
    let view = MetalView(frame: frame, device: device, withoutAudio: withoutAudio, customAudio: customBGM)
    view.setDelegate(animations)
    PlaygroundPage.current.liveView = view
}

public func draw(_ triangles: [Triangle]) {
    stopBGM()
    if triangles.isEmpty { return }
    let view = DrawingView(frame: frame, device: device)
    view.setTriangleData(triangles)
    PlaygroundPage.current.liveView = view
}

public func stopBGM() {
    let mediaPlayer = MPMusicPlayerController.systemMusicPlayer
    mediaPlayer.stop()
}
