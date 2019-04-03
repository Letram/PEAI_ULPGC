//
//  ProductDetailsViewController.swift
//  Project2
//
//  Created by Alumno on 20/03/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

extension String{
    func matches(_ regex: String) -> Bool{
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

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
        if(!productValid()){
            
        }
        else{
            productNameText = productNameField.text!
            productDescriptionText = productDescriptionField.text!
            productPriceText = productPriceField.text!
            performSegue(withIdentifier: "unwindToProductList", sender: self)
        }
    }
    
    func productValid() -> Bool{
        if(productNameField.text == "" || productDescriptionField.text == "" || !numeric(value: productPriceField.text!) || productPriceField.text == ""){
            return false
        }
        return true
    }
    
    func numeric(value: String) -> Bool{
        return value.matches("[0-9]*(,.){0,1}[0-9]?")
    }

    // MARK: - Codificación/Decodificación del estado
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(productNameField.text, forKey: "PRODUCT_NAME")
        coder.encode(productDescriptionField.text, forKey: "PRODUCT_DESCRIPTION")
        coder.encode(productPriceField.text, forKey: "PRODUCT_PRICE")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        productNameText = coder.decodeObject(forKey: "PRODUCT_NAME") as! String
        productDescriptionText = coder.decodeObject(forKey: "PRODUCT_DESCRIPTION") as! String
        productPriceText = coder.decodeObject(forKey: "PRODUCT_PRICE") as! String
        
        updateTexts()
    }
}
