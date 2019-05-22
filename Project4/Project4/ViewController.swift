import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var ball: UIImageView!
    
    let motionManager = CMMotionManager()
    let operationQueue = OperationQueue()
    var newX: CGFloat = 0.0
    var newY: CGFloat = 0.0
    
    var bounds: [CGFloat] = [0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height]
    
    var newValues: [CGFloat] = [0,0]
    var newRot: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.motionManager.isDeviceMotionAvailable {
            
            self.motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: self.operationQueue, withHandler: { (data: CMDeviceMotion?, error: Error?) in
                if error == nil {
                    self.updatePosition(xValue: CGFloat((data?.attitude.roll)!) ,yValue: CGFloat((data?.attitude.pitch)!))
                    self.newRot = CGFloat((data?.attitude.yaw)!)
                    self.perform(#selector(ViewController.refresh), on: Thread.main, with: nil, waitUntilDone: false)
                }
            })
        }
    }
    
    func updatePosition(xValue: CGFloat, yValue: CGFloat){
        
        var xPosition = self.ball.center.x + xValue
        var yPosition = self.ball.center.y + yValue
        
        if xPosition < (bounds[0] + self.ball.bounds.width/2) { xPosition = bounds[0] + self.ball.bounds.width/2 }
        if xPosition > (bounds[2] - self.ball.bounds.width/2) { xPosition = bounds[2] - self.ball.bounds.width/2 }
        if yPosition < (bounds[1] + self.ball.bounds.height/2) { yPosition = bounds[1] + self.ball.bounds.height/2 }
        if yPosition > (bounds[3] - self.ball.bounds.height/2) { yPosition = bounds[3] - self.ball.bounds.height/2 }
        
        newValues[0] = xPosition
        newValues[1] = yPosition
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    @objc func refresh() {
        self.ball.center.x = self.newValues[0]
        self.ball.center.y = self.newValues[1]
        self.ball.transform = CGAffineTransform(rotationAngle: self.newRot)
    }
    
    func degrees(radians:Double) -> Double {
        return 180 / Double.pi * radians
    }


}

