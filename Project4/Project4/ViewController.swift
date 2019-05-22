import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var clock: UIView!
    let motionManager = CMMotionManager()
    let operationQueue = OperationQueue()
    var newX: CGFloat = 0.0
    var newY: CGFloat = 0.0
    
    var bounds: [CGFloat] = [0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height]
    
    var newValues: [CGFloat] = [0,0]
    var newRot: CGFloat = 0.0
    var radians: CGFloat = 0.0
    let tolerance: [CGFloat] = [-0.02, 0.02]
    let translationalSpeed: [CGFloat] = [0.002, 0.75]
    var movSpeed: CGFloat = 0.002
    
    let rotationalSpeed = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.motionManager.isDeviceMotionAvailable {
            
            self.motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: self.operationQueue, withHandler: { (data: CMDeviceMotion?, error: Error?) in
                if error == nil {
                    self.updatePosition(xValue: CGFloat((data?.attitude.roll)!) ,yValue: CGFloat((data?.attitude.pitch)!))
                    self.radians = CGFloat(atan2((data?.gravity.x)!, (data?.gravity.y)!) - Double.pi)
                    self.newRot = CGFloat((data?.attitude.yaw)!)
                    self.perform(#selector(ViewController.refresh), on: Thread.main, with: nil, waitUntilDone: false)
                }
            })
        }
    }
    
    func updatePosition(xValue: CGFloat, yValue: CGFloat){
        
        let x: CGFloat = self.clock.center.x
        let y: CGFloat = self.clock.center.y
        
        var xPosition = x + xValue*movSpeed
        var yPosition = y + yValue*movSpeed
        
        //print("xValue: \(xValue)- yValue: \(yValue) - radians: \(self.radians)")
        
        movSpeed = movSpeed + 0.001
        movSpeed = clamp(value: movSpeed, limits: translationalSpeed)
                
        if xPosition < (bounds[0] + self.clock.bounds.width/2) {
            xPosition = bounds[0] + self.clock.bounds.width/2
            movSpeed = translationalSpeed[0]
        }
        if xPosition > (bounds[2] - self.clock.bounds.width/2) {
            xPosition = bounds[2] - self.clock.bounds.width/2
            movSpeed = translationalSpeed[1]
        }
        if yPosition < (bounds[1] + self.clock.bounds.height/2) { yPosition = bounds[1] + self.clock.bounds.height/2 }
        if yPosition > (bounds[3] - self.clock.bounds.height/2) { yPosition = bounds[3] - self.clock.bounds.height/2 }
        
        newValues[0] = xPosition
        newValues[1] = yPosition
    }
    
    func clamp (value: CGFloat, limits: [CGFloat]) -> CGFloat {
        if (value < limits[0]){return limits[0]}
        if (value > limits[1]){return limits[1]}
        return value
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    @objc func refresh() {
        self.clock.center.x = self.newValues[0]
        self.clock.center.y = self.newValues[1]
        //let clockRotation: CGFloat = CGFloat(atan2f(Float(self.clock.transform.b), Float(self.clock.transform.a)))
        //print("Clock rotation: \(clockRotation) - new rotation: \(self.newRot)")
        
        //print("newRot: \(self.newRot) - radiansRot: \(self.radians)")
        
        //todo cuando está puesto en horizontal(sobre la mesa) los valores de esto hacen cosas raras. mirar cuándo es más fiable el newRot (para horizontal) y el radians (para cualquier otra parte)
        if(isTolerated(values: newValues, tol: tolerance)){
            print("newRot")
            self.clock.transform = CGAffineTransform(rotationAngle: self.newRot)
        }
        else {
            print("Radians")
            self.clock.transform = CGAffineTransform(rotationAngle: self.radians)
        }
    }
    
    //TODO NO MANDAR LOS NEWVALUES SINO EL XVALUE E YVALUE
    func isTolerated(values: [CGFloat], tol: [CGFloat]) -> Bool {
        if(values[0] < tol[0] || values[0] > tol[1]) {return false}
        if(values[1] < tol[0] || values[1] > tol[1]) {return false}
        return true
    }
    
    func degrees(radians:Double) -> Double {
        return 180 / Double.pi * radians
    }


}

