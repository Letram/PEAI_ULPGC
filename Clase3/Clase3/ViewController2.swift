//
//  ViewController2.swift
//  Clase3
//
//  Created by Alumno on 13/02/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

protocol ViewController2Delegate {
    func endAndReturn(_ result: String, controller: ViewController2)
}

class ViewController2: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    var newValue = "none"
    var delegate: ViewController2Delegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        label.text = newValue
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func segueWithProtocol(_ sender: UIButton) {
        delegate?.endAndReturn("Te mando la string por parámetro", controller: self)
    }
}
