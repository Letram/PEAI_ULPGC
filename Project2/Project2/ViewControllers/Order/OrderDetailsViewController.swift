//
//  OrderDetailsViewController.swift
//  Project2
//
//  Created by Alumno on 20/03/2019.
//  Copyright © 2019 eii. All rights reserved.
//

import UIKit
import CoreData

class OrderDetailsViewController: UIViewController {

    var context: NSManagedObjectContext? = nil

    @IBOutlet weak var qField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var customerSelected: UITextField!
    @IBOutlet weak var productSelected: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var stepper: UIStepper!
    
    var code: String = ""
    var quantity: Int16 = 0
    var totalPrice: Decimal = 0
    var customer: Customer? = nil
    var product: Product? = nil
    var date: Date? = nil
    var isForUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.date = date ?? Date()
        stepper.value = Double(quantity)
        checkStepper()
        updateTexts()
    }
    
    @IBAction func stepperTapped(_ sender: UIStepper) {
        quantity = Int16(sender.value)
        
        updateTexts()
    }
    
    func checkStepper(){
        if(product == nil){
            stepper.minimumValue = 0
            stepper.maximumValue = 0
        } else {
            stepper.maximumValue = 999
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        saveVars()
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "productSegue" || segue.identifier == "customerSegue"){
            let vc = segue.destination as! SelectViewController
            vc.context = context
            switch segue.identifier {
            case "productSegue":
                vc.setFetch(entity: "Product")
                break
            default:
                vc.setFetch(entity: "Customer")
                break
            }
        }
    }
    
    @IBAction func unwindToOrderDetails(segue: UIStoryboardSegue){
        let vc = segue.source as! SelectViewController
        if(vc.entitySelected == "Customer"){
            customer = vc.customerSelected
        }else{
            product = vc.productSelected
        }
        checkStepper()
        updateTexts()
    }
    
    func updateTexts(){
        checkNewPrice()
        priceField.text = totalPrice.description
        qField.text = quantity.description
        customerSelected.text = customer?.name
        productSelected.text = product?.name
        codeField.text = code
    }
    
    func checkNewPrice(){
        let decimalAux: NSDecimalNumber = product?.price ?? 0
        totalPrice = (decimalAux as Decimal) * (NSDecimalNumber(value: quantity) as Decimal)
    }
    
    func saveVars(){
        code = codeField.text!
        date = datePicker.date
        totalPrice = Decimal(string: priceField.text!)!
        quantity = Int16(qField.text!)!
    }
    @IBAction func doneBtnTapped(_ sender: UIBarButtonItem) {
        code = codeField.text!
        date = datePicker.date
        performSegue(withIdentifier: "unwindToOrderList", sender: self)
    }
    
    // MARK: - Codificación/Decodificación del estado
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(code, forKey: "ORDER_CODE")
        coder.encode(date, forKey: "ORDER_DATE")
        //coder.encode(productPriceText, forKey: "ORDER_CUSTOMER")
        //coder.encode(productPriceText, forKey: "ORDER_PRODUCT")
        coder.encode(totalPrice, forKey: "ORDER_TOTAL")
        coder.encode(quantity, forKey: "ORDER_QUANTITY")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        code = coder.decodeObject(forKey: "ORDER_CODE") as! String
        date = coder.decodeObject(forKey: "ORDER_DATE") as? Date
        totalPrice = coder.decodeObject(forKey: "ORDER_CODE") as! Decimal
        quantity = Int16(coder.decodeInt32(forKey: "ORDER_CODE"))
        //customer
        //product
        updateTexts()
    }}
