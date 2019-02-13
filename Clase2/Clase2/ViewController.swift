//
//  ViewController.swift
//  Clase2
//
//  Created by Alumno on 12/02/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //Diferenciacion por propiedades
    @IBAction func buttonPressed(_ sender: UIButton) {
        textLabel.text = "\(sender.titleLabel?.text ?? "default value button") pressed"
    }
    
    //Diferenciacion por tags
    @IBAction func buttonPressedByTag(_ sender: UIButton) {
        textLabel.text = "Button \(sender.tag) pressed"
        if textField.text != "" {
            textLabel.text = textField.text
        }
    }
    
    //comentamos los touch para que los tap se vean bien, hay que tener en cuenta que los gestos predominan sobre los touch (tap > touch)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textLabel.text = "Touch at \(touches.first!.location(in: self.view))"
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        textLabel.text = "Touch moving to \(touches.first!.location(in: self.view))"
    }

    @IBAction func tapGestureDone(_ sender: UITapGestureRecognizer) {
        textLabel.text = "Tap done at \(sender.location(in: self.view))"
    }
    
    //Podemos saber también el estado del tap programáticamente
    @IBAction func tapGestureDone2(_ sender: UITapGestureRecognizer) {
        var text = ""
        if sender.state == .ended{
            text = "Tap ended at \(sender.location(in: self.view)) with 2 taps"
            textLabel.text = text
        }
    }
    
    //También se pueden detecar qué tipos de movimientos hacemos con el dispositivo.
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            textLabel.text = "SHAKING"
        }
    }
}

