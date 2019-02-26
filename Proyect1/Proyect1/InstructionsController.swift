//
//  InstrucctionsController.swift
//  Proyect1
//
//  Created by Alumno on 26/02/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

class InstructionsController: UIViewController {

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = segue.destination as! GameController
    }
    
    @IBAction func unwindToInstructions(for unwindSegue: UIStoryboardSegue) {}
}
