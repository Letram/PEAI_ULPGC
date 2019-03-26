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

        // Do any additional setup after loading the view.
        customerAddress.text = customerAddressText
        customerName.text = customerNameText
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
