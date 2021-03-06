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
    var productID: Int?
    var isForUpdate = false

    
    //TODO disable the button until all the data is filled.
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var productNameField: UITextField!
    @IBOutlet weak var productDescriptionField: UITextField!
    @IBOutlet weak var productPriceField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // setup keyboard event
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
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
        productPriceField.text = productPriceText
        productDescriptionField.text = productDescriptionText
        productNameField.text = productNameText
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    @IBAction func doneBtnTapped(_ sender: Any) {
        if(!productValid()){
            showAlert()
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
    
    func showAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Data entered is not valid", comment: ""), message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func numeric(value: String) -> Bool{
        if(!value.matches("^[0-9]+\\.?[0-9]*$")){
            let alert = UIAlertController(title: NSLocalizedString("Price must be a number", comment: ""), message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return false
        }
        return true
    }

    // MARK: - Codificación/Decodificación del estado
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        coder.encode(productNameField.text, forKey: "PRODUCT_NAME")
        coder.encode(productDescriptionField.text, forKey: "PRODUCT_DESCRIPTION")
        coder.encode(productPriceField.text, forKey: "PRODUCT_PRICE")
        coder.encode(productID, forKey: "PRODUCT_ID")
        coder.encode(isForUpdate, forKey: "FOR_UPDATE")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        productNameText = coder.decodeObject(forKey: "PRODUCT_NAME") as! String
        productDescriptionText = coder.decodeObject(forKey: "PRODUCT_DESCRIPTION") as! String
        productPriceText = coder.decodeObject(forKey: "PRODUCT_PRICE") as! String
        productID = coder.decodeObject(forKey: "PRODUCT_ID") as? Int
        isForUpdate = coder.decodeBool(forKey: "FOR_UPDATE")
        updateTexts()
    }
}
