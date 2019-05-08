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
    @IBOutlet weak var scrollView: UIScrollView!
    
    var code: String = ""
    var quantity: Int16 = 0
    var totalPrice: Decimal = 0
    var customer: CustomerModel? = nil {
        didSet{
            updateTexts()
        }
    }
    
    var product: ProductModel? = nil {
        didSet{
            checkStepper()
            updateTexts()
        }
    }
    
    var order: OrderModel? = nil
    
    var date: Date? = nil
    var isForUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup keyboard event
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        datePicker.date = date ?? Date()
        if isForUpdate {
            stepper.minimumValue = Double(quantity)
            stepper.minimumValue = 0
        }
        checkStepper()
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
                vc.setProduct(entity: self.product ?? nil)
                break
            default:
                vc.setFetch(entity: "Customer")
                vc.setCustomer(entity: self.customer ?? nil)
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
        if(product != nil){
            let priceDouble = Double((product?.price)!)
            let decimalAux = NSDecimalNumber(floatLiteral: priceDouble)
            totalPrice = (decimalAux as Decimal) * (NSDecimalNumber(value: quantity) as Decimal)
        }
    }
    
    func saveVars(){
        code = codeField.text!
        date = datePicker.date
        totalPrice = Decimal(string: priceField.text!)!
        quantity = Int16(qField.text!)!
    }
    @IBAction func doneBtnTapped(_ sender: UIBarButtonItem) {
        if(!orderValid()){}
        else{
            code = codeField.text!
            date = datePicker.date
            performSegue(withIdentifier: "unwindToOrderList", sender: self)
        }
    }
    
    func orderValid() -> Bool{
        if(customer == nil || product == nil || codeField.text == "" ){
            return false
        }
        return true
    }
    
    // MARK: - Codificación/Decodificación del estado
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        saveVars()
        
        coder.encode(code, forKey: "ORDER_CODE")
        coder.encode(date, forKey: "ORDER_DATE")
        
        
        //todo: encapsular en una funcion aparte para tenerlo más mono
        let jsonEncoder = JSONEncoder()
        
        do{
            if(customer != nil){
                let jsonData = try jsonEncoder.encode(customer)
                let jsonString: String = String(data: jsonData, encoding: .utf8)!
                print("Encoded customer: \(jsonString)")
                coder.encode(jsonString, forKey: "ORDER_CUSTOMER")
            }
            
            if(product != nil){
                let jsonData = try jsonEncoder.encode(product)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                print("Encoded product: \(jsonString)")
                coder.encode(jsonString, forKey: "ORDER_PRODUCT")
            }
            
            if(order != nil){
                let jsonData = try jsonEncoder.encode(order)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                print("Encoded order: \(jsonString)")
                coder.encode(jsonString, forKey: "ORDER")
            }
            
        } catch let parseError as NSError {
            print("JSONSerialization error: \(parseError.localizedDescription)\n")
        }
 
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
        
        //todo: encapsular en una funcion aparte para tenerlo más mono
        let jsonDecoder = JSONDecoder()
        do {
            var coderData = coder.decodeObject(forKey: "ORDER_CUSTOMER")
            if(coderData != nil){
                let jsonString = coderData as! String
                let jsonData = jsonString.data(using: .utf8)
                
                self.customer = try jsonDecoder.decode(CustomerModel.self, from: jsonData!)
            }
            
            coderData = coder.decodeObject(forKey: "ORDER_PRODUCT")
            if(coderData != nil) {
                let jsonString = coderData as! String
                let jsonData = jsonString.data(using: .utf8)
                
                self.product = try jsonDecoder.decode(ProductModel.self, from: jsonData!)
            }

            coderData = coder.decodeObject(forKey: "ORDER")
            if(coderData != nil){
                let jsonString = coderData as! String
                let jsonData = jsonString.data(using: .utf8)
                
                self.order = try jsonDecoder.decode(OrderModel.self, from: jsonData!)
            }
            
            print("cast succesful")
        } catch let parseError as NSError {
            print("JSONSerialization error: \(parseError.localizedDescription)\n")
        }
        stepper.value = Double(quantity)
        datePicker.date = date!
    }}
