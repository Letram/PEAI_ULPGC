import UIKit
import CoreData

class ProductListViewController: UITableViewController {
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBAction func editBtnTapped(_ sender: Any) {
        if(self.tableView.isEditing){
            self.tableView.setEditing(false, animated:true)
            editBtn.title = NSLocalizedString("Edit", comment: "")
        }else{
            self.tableView.setEditing(true, animated:true)
            editBtn.title = NSLocalizedString("Done", comment: "")
        }
    }
    
    let productService = ProductQueryService()
    var queryResults: [ProductModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        productService.delegate = self
        getAll()

    }

    //MARK: - Consultas
    func getAll(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        productService.getAll(){ results, errorMsg in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.refreshProducts(newProducts: results as! [ProductModel])
            if !errorMsg.isEmpty { print("Search error: " + errorMsg) }
            
        }
    }
    
    func insert(description: String, name: String, price: Float) {
        
        var params: [String: Any] = [:]
        
        params["description"] = description
        params["name"] = name
        params["price"] = price
        
        productService.insert(params: params){ results, errorMsg in
            self.refreshProducts(newProducts: results as! [ProductModel])
        }
    }
    
    func update(name: String, description: String, idProduct: Int, price: Float){
        var params: [String: Any] = [:]
        
        params["name"] = name
        params["description"] = description
        params["IDProduct"] = idProduct
        params["price"] = price
        
        productService.update(params: params){ results, errorMsg in
            self.refreshProducts(newProducts: results as! [ProductModel])
        }
    }
    
    func delete(IDProduct: Int){
        let params = ["IDProduct" : IDProduct]
        
        productService.delete(params: params) { results, errorMsg in
            self.refreshProducts(newProducts: results as! [ProductModel])
        }
    }
    
    func refreshProducts(newProducts: [ProductModel]){
        self.queryResults = newProducts
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = queryResults[indexPath.row].name
        cell.detailTextLabel?.text = queryResults[indexPath.row].price.description
        
        return cell
    }
     
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let aux = queryResults[indexPath.row].IDProduct
            delete(IDProduct: aux)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as? ProductDetailsViewController
        switch segue.identifier {
        case "edit":
            let tableIndex = tableView.indexPathForSelectedRow
            vc?.productNameText = queryResults[(tableIndex?.row)!].name
            vc?.productDescriptionText = queryResults[(tableIndex?.row)!].description
            vc?.productPriceText = queryResults[(tableIndex?.row)!].price.description
            vc?.productID = queryResults[(tableIndex?.row)!].IDProduct
            vc?.isForUpdate = true
            break
        default:
            break
        }

    }
    
    
    @IBAction func unwindToProductList(source: UIStoryboardSegue){
        let vc = source.source as! ProductDetailsViewController
        if(vc.isForUpdate){
            update(name: vc.productNameText, description: vc.productDescriptionText, idProduct: vc.productID!, price: Float(vc.productPriceText)!)
            vc.isForUpdate = false
        }else{
            insert(description: vc.productDescriptionText, name: vc.productNameText, price: Float(vc.productPriceText)!)
            vc.isForUpdate = false
        }
    }

}
