//
//  CustomerDetailsViewController.swift
//  Project2
//
//  Created by Alumno on 20/03/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit

class CustomerDetailsViewController: UIViewController, UITextFieldDelegate {

    var customerNameText = ""
    var customerAddressText = ""
    var IDCustomer: Int?
    var isForUpdate = false
    
    @IBAction func doneBtnPressed(_ sender: UIBarButtonItem) {
        if(!customerValid()){
        }
        else{
            customerNameText = customerName.text!
            customerAddressText = customerAddress.text!
            performSegue(withIdentifier: "unwindInsertWithSegue", sender: self)
        }
    }
    @IBOutlet weak var customerAddress: UITextField!
    @IBOutlet weak var customerName: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup keyboard event
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        customerAddress.delegate = self
        updateTexts()
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

    
    func updateTexts(){
        customerAddress.text = customerAddressText
        customerName.text = customerNameText
    }
    
    //Preguntar por el first responder y manejarlo
    func customerValid() -> Bool{
        if(customerName.text! == "" || customerAddress.text! == ""){
            return false
        }
        return true
    }
    // MARK: - Codificación/Decodificación del estado
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(customerName.text, forKey: "CUSTOMER_NAME")
        coder.encode(customerAddress.text, forKey: "CUSTOMER_ADDRESS")
        coder.encode(IDCustomer, forKey: "CUSTOMER_ID")
        coder.encode(isForUpdate, forKey: "FOR_UPDATE")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        customerNameText = coder.decodeObject(forKey: "CUSTOMER_NAME") as! String
        customerAddressText = coder.decodeObject(forKey: "CUSTOMER_ADDRESS") as! String
        isForUpdate = coder.decodeBool(forKey: "FOR_UPDATE")
        IDCustomer = coder.decodeObject(forKey: "CUSTOMER_ID") as? Int

        updateTexts()
    }
}
