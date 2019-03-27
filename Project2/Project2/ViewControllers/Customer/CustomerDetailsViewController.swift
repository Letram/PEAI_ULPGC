//
//  CustomerDetailsViewController.swift
//  Project2
//
//  Created by Alumno on 20/03/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

class CustomerDetailsViewController: UIViewController {

    var customerNameText = ""
    var customerAddressText = ""
    var isForUpdate = false
    
    @IBAction func doneBtnPressed(_ sender: UIBarButtonItem) {
        customerNameText = customerName.text!
        customerAddressText = customerAddress.text!
        performSegue(withIdentifier: "unwindInsertWithSegue", sender: self)
    }
    @IBOutlet weak var customerAddress: UITextField!
    @IBOutlet weak var customerName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTexts()
    }
    
    func updateTexts(){
        customerAddress.text = customerAddressText
        customerName.text = customerNameText
    }
    
    // MARK: - Codificación/Decodificación del estado
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(customerNameText, forKey: "CUSTOMER_NAME")
        coder.encode(customerAddressText, forKey: "CUSTOMER_ADDRESS")

    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        customerNameText = coder.decodeObject(forKey: "CUSTOMER_NAME") as! String
        customerAddressText = coder.decodeObject(forKey: "CUSTOMER_ADDRESS") as! String

        updateTexts()
    }
}
