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
    var customer: Customer? = nil {
        didSet{
            updateTexts()
        }
    }
    
    var product: Product? = nil {
        didSet{
            checkStepper()
            updateTexts()
        }
    }
    
    var order: Order? = nil
    
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
            stepper?.minimumValue = 0
            stepper?.maximumValue = 0
        } else {
            stepper?.maximumValue = 999
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
        priceField?.text = totalPrice.description
        qField?.text = quantity.description
        customerSelected?.text = customer?.name
        productSelected?.text = product?.name
        codeField?.text = code
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
        
        saveVars()
        
        coder.encode(code, forKey: "ORDER_CODE")
        coder.encode(date, forKey: "ORDER_DATE")
        
        let productID = self.product?.objectID
        coder.encode(productID?.uriRepresentation(), forKey: "ORDER_PRODUCT")
        
        let customerID = self.customer?.objectID
        coder.encode(customerID?.uriRepresentation(), forKey: "ORDER_CUSTOMER")
        
        let orderID = self.order?.objectID
        coder.encode(orderID?.uriRepresentation(), forKey: "ORDER")
        
        coder.encode(totalPrice.description, forKey: "ORDER_TOTAL")
        coder.encode(quantity.description, forKey: "ORDER_QUANTITY")
        coder.encode(isForUpdate, forKey: "ORDER_UPDATE")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        code = coder.decodeObject(forKey: "ORDER_CODE") as! String
        date = coder.decodeObject(forKey: "ORDER_DATE") as? Date
        totalPrice = Decimal(string: coder.decodeObject(forKey: "ORDER_TOTAL") as! String) ?? 0
        quantity = Int16(coder.decodeObject(forKey: "ORDER_QUANTITY") as! String) ?? 0
        
        stepper?.minimumValue = Double(quantity)
        stepper?.minimumValue = 0
        isForUpdate = coder.decodeBool(forKey: "ORDER_UPDATE")
        let productURI = coder.decodeObject(forKey: "ORDER_PRODUCT") as? URL
        let customerURI = coder.decodeObject(forKey: "ORDER_CUSTOMER") as? URL
        let orderURI = coder.decodeObject(forKey: "ORDER") as? URL
        
        if productURI != nil {
            let productID = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: productURI!)
            self.context?.perform {
                self.product = self.context?.object(with: productID!) as? Product
            }
        }
        if customerURI != nil {
            let customerID = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: customerURI!)
            self.context?.perform {
                self.customer = self.context?.object(with: customerID!) as? Customer
            }
        }
        if orderURI != nil {
            let orderID = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: orderURI!)
            self.context?.perform {
                self.order = self.context?.object(with: orderID!) as? Order
            }
        }
        datePicker.date = date!
    }}