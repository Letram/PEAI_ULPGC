import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var clock: UIView!
    let motionManager = CMMotionManager()
    let operationQueue = OperationQueue()
    
    var maxAnimationSpeed = 1.5
    var minAnimationSpeed = 0.5
    //screen dimensions
    var bounds: [CGFloat] = [0, 0, UIScreen.main.bounds.width, UIScreen.main.bounds.height]
    
    //new values of position
    var newX: CGFloat = 0.0
    var newY: CGFloat = 0.0
    
    //last increment added to the position
    var xIncrement: CGFloat = 0.0
    var yIncrement: CGFloat = 0.0
    
    //last rotation to add to the image using accelerometer (newrot) and gravity (radians)
    var accRot: CGFloat = 0.0
    var graRot: CGFloat = 0.0
    
    //limits of the values in which we are using accelerometer instead of gravity. It usually happens when the device is on a table or in horizontal position
    var minTol: CGFloat = -0.025
    var maxTol: CGFloat = 0.025
    
    //limits of the speed of the image.
    var minSpeed: CGFloat = 0.3
    var maxSpeed: CGFloat = 1
    
    var acceleration: CGFloat = 0.002
    
    let maxVertivalInclination: Double = Double.pi/2
    let maxHorizontalInclination: Double = Double.pi
    var verticalInclinationAlpha: Double = 0.0
    var horizontalInclinationAlpha: Double = 0.0
    
    var inclinationAlpha: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.motionManager.isDeviceMotionAvailable {
            
            self.motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: self.operationQueue, withHandler: { (data: CMDeviceMotion?, error: Error?) in
                if error == nil {
                    self.updatePosition(xValue: CGFloat((data?.attitude.roll)!) ,yValue: CGFloat((data?.attitude.pitch)!))
                    self.graRot = CGFloat(atan2((data?.gravity.x)!, (data?.gravity.y)!) - Double.pi)
                    //self.graRot = CGFloat((data?.gravity.z)!)
                    self.accRot = CGFloat((data?.attitude.yaw)!)
                    self.perform(#selector(ViewController.refresh), on: Thread.main, with: nil, waitUntilDone: false)
                }
            })
        }
    }
    
    override open var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updatePosition(xValue: CGFloat, yValue: CGFloat){
        xIncrement = xValue
        yIncrement = yValue
        
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
        
        var xPosition = self.clock.center.x + xIncrement*acceleration
        var yPosition = self.clock.center.y + yIncrement*acceleration
        
        print("incrementX: \(xIncrement*acceleration) - incrementY: \(yIncrement*acceleration) - acceleration: \(acceleration)")
        
        acceleration = acceleration + 0.00125
        acceleration = clamp(value: acceleration, limits: [minSpeed, maxSpeed])
        
        print("cceleration: \(acceleration)")
        if xPosition < (bounds[0] + self.clock.bounds.width/2) {
            xPosition = bounds[0] + self.clock.bounds.width/2
        }
        if xPosition > (bounds[2] - self.clock.bounds.width/2) {
            xPosition = bounds[2] - self.clock.bounds.width/2
        }
        if yPosition < (bounds[1] + self.clock.bounds.height/2) {
            yPosition = bounds[1] + self.clock.bounds.height/2
            acceleration = minSpeed
        }
        if yPosition > (bounds[3] - self.clock.bounds.height/2) {
            yPosition = bounds[3] - self.clock.bounds.height/2
            acceleration = minSpeed
        }
        
        newX = xPosition
        newY = yPosition
        
        self.clock.center.x = self.newX
        self.clock.center.y = self.newY
        
        verticalInclinationAlpha = Double(abs(yIncrement))/maxVertivalInclination
        horizontalInclinationAlpha = Double(abs(xIncrement))/maxHorizontalInclination
        
        inclinationAlpha = Double.squareRoot((verticalInclinationAlpha * verticalInclinationAlpha) + (2*horizontalInclinationAlpha * 2*horizontalInclinationAlpha))()
        
        //print("inclination: \(inclinationAlpha), vertical: \(verticalInclinationAlpha), horizontal: \(horizontalInclinationAlpha)")

        if(isTolerated(values: [xIncrement, yIncrement], tol: [minTol, maxTol])){
            animateRotation(rotation: self.accRot)
        }
        else {
            animateRotation(rotation: self.graRot)
        }
    }
    
    func isTolerated(values: [CGFloat], tol: [CGFloat]) -> Bool {
        if(values[0] < tol[0] || values[0] > tol[1]) {return false}
        if(values[1] < tol[0] || values[1] > tol[1]) {return false}
        return true
    }
    
    func degrees(radians:Double) -> Double {
        return 180 / Double.pi * radians
    }

    func animateRotation(rotation: CGFloat){
        //modified animation duration
        let animationDuration = clamp(value: CGFloat(Double(maxAnimationSpeed) * (1-inclinationAlpha)), limits: [CGFloat(minAnimationSpeed),CGFloat(maxAnimationSpeed)])
        //print("duration: \(animationDuration) - alpha: \(inclinationAlpha)")
        UIView.animate(
            withDuration: Double(animationDuration),
            animations: {
                self.clock.transform = CGAffineTransform(rotationAngle: rotation)
            }
        )
    }
}

