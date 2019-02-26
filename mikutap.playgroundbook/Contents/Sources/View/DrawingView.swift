import UIKit
import MetalKit

class DrawingView: MTKView {
    
    private var animation: CustomizedAnimation?
    
    private var commandQueue: MTLCommandQueue?
    private var rps: MTLRenderPipelineState?
    private var semaphore: DispatchSemaphore!

    private func axisInit() {
        let width: CGFloat = 2.0
        
        let xaxis = UILabel()
        xaxis.backgroundColor = .white
        addSubview(xaxis)
        
        xaxis.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            xaxis.heightAnchor.constraint(equalToConstant: width),
            xaxis.widthAnchor.constraint(equalTo: widthAnchor),
            xaxis.centerXAnchor.constraint(equalTo: centerXAnchor),
            xaxis.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        let yaxis = UILabel()
        yaxis.backgroundColor = .white
        addSubview(yaxis)
        
        yaxis.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            yaxis.widthAnchor.constraint(equalToConstant: width),
            yaxis.heightAnchor.constraint(equalTo: heightAnchor),
            yaxis.centerXAnchor.constraint(equalTo: centerXAnchor),
            yaxis.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        let xlabelr = UILabel()
        xlabelr.text = "  x  \n\n 1.0"
        xlabelr.numberOfLines = 3
        xlabelr.textColor = .white
        xlabelr.sizeToFit()
        addSubview(xlabelr)
        
        xlabelr.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            xlabelr.rightAnchor.constraint(equalTo: rightAnchor),
            xlabelr.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        let xlabell = UILabel()
        xlabell.text = "\n\n -1.0"
        xlabell.numberOfLines = 3
        xlabell.textColor = .white
        xlabell.sizeToFit()
        addSubview(xlabell)
        
        xlabell.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            xlabell.leftAnchor.constraint(equalTo: leftAnchor),
            xlabell.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        let ylabelu = UILabel()
        ylabelu.text = "  y    1.0"
        ylabelu.textColor = .white
        ylabelu.sizeToFit()
        addSubview(ylabelu)
        
        ylabelu.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ylabelu.topAnchor.constraint(equalTo: topAnchor),
            ylabelu.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        let ylabelb = UILabel()
        ylabelb.text = "         -1.0"
        ylabelb.textColor = .white
        ylabelb.sizeToFit()
        addSubview(ylabelb)
        
        ylabelb.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ylabelb.bottomAnchor.constraint(equalTo: bottomAnchor),
            ylabelb.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        let clabel = UILabel()
        clabel.text = "0"
        clabel.textColor = .white
        clabel.sizeToFit()
        addSubview(clabel)
        
        clabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 20.0),
            clabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 20.0)
        ])
    }
    
    private func commonInit() {
        semaphore = DispatchSemaphore(value: 3)
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device!.makeCommandQueue()
        
        translatesAutoresizingMaskIntoConstraints = false
        axisInit()
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
