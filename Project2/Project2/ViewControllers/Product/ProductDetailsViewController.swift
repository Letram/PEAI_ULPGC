//
//  ProductDetailsViewController.swift
//  Project2
//
//  Created by Alumno on 20/03/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

class ProductDetailsViewController: UIViewController {

    var productNameText: String = ""
    var productDescriptionText: String = ""
    var productPriceText: String = ""
    var isForUpdate = false

    
    //TODO disable the button until all the data is filled.
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    @IBOutlet weak var productNameField: UITextField!
    @IBOutlet weak var productDescriptionField: UITextField!
    @IBOutlet weak var productPriceField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateTexts()
    }
    
    func updateTexts(){
        productPriceField.text = productPriceText
        productDescriptionField.text = productDescriptionText
        productNameField.text = productNameText
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
/*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 */
    @IBAction func doneBtnTapped(_ sender: Any) {
        productNameText = productNameField.text!
        productDescriptionText = productDescriptionField.text!
        productPriceText = productPriceField.text!
        performSegue(withIdentifier: "unwindToProductList", sender: self)
    }
    
    // MARK: - Codificación/Decodificación del estado
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(productNameText, forKey: "PRODUCT_NAME")
        coder.encode(productDescriptionText, forKey: "PRODUCT_DESCRIPTION")
        coder.encode(productPriceText, forKey: "PRODUCT_PRICE")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        productNameText = coder.decodeObject(forKey: "PRODUCT_NAME") as! String
        productDescriptionText = coder.decodeObject(forKey: "PRODUCT_DESCRIPTION") as! String
        productPriceText = coder.decodeObject(forKey: "PRODUCT_PRICE") as! String
        
        updateTexts()
    }
}
