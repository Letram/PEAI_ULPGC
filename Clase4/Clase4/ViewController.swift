//
//  ViewController.swift
//  Clase4
//
//  Created by Alumno on 19/02/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func onButtonPressed(_ sender: UIButton) {
        
        //para internacionalizar tenemos que usar NSLOCALIZEDSTRING y funciona como un diccionario clave-valor. En el caso de que no esté localizada la string (por ejemplo, si no la he añadido en el fichero de idiomas) nos la mostrará completamente en mayúsculas.
        label.text = NSLocalizedString("Button pressed", comment: "Button have been pressed")
    }
    
}

