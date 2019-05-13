import UIKit
import CoreData

class OrderListViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBAction func editBtnTapped(_ sender: UIBarButtonItem) {
        if(self.tableView.isEditing){
            self.tableView.setEditing(false, animated:true)
            editBtn.title = "Edit"
        }else{
            self.tableView.setEditing(true, animated:true)
            editBtn.title = "Done"
        }
    }
    var context: NSManagedObjectContext? = nil
    
    let orderService = OrderQueryService()
    var queryResults: [CustomerOrders] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAll()
    }
    
    //MARK: - Consultas
    func getAll(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        orderService.getAll(){ results, errorMsg in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.refreshProducts(newOrders: results as! [CustomerOrders])
            if !errorMsg.isEmpty { print("Search error: " + errorMsg) }
            
        }
    }
    
    func insert(code: String, date: String, idProduct: Int, idCustomer: Int, quantity: Int) {
        var params: [String: Any] = [:]
        
        params["code"] = code
        params["date"] = date
        params["IDProduct"] = idProduct
        params["IDCustomer"] = idCustomer
        params["quantity"] = quantity
        
        orderService.insert(params: params){ results, errorMsg in
            self.refreshProducts(newOrders: results as! [CustomerOrders])
        }
    }
    
    func update(code: String, date: String, idProduct: Int, idCustomer: Int, idOrder: Int, quantity: Int){
        var params: [String: Any] = [:]
        
        params["code"] = code
        params["date"] = date
        params["IDProduct"] = idProduct
        params["IDCustomer"] = idCustomer
        params["IDOrder"] = idOrder
        params["quantity"] = quantity
        
        orderService.update(params: params){ results, errorMsg in
            self.refreshProducts(newOrders: results as! [CustomerOrders])
        }
    }
    
    func delete(IDOrder: Int){
        let params = ["IDOrder" : IDOrder]
        
        orderService.delete(params: params) { results, errorMsg in
            self.refreshProducts(newOrders: results as! [CustomerOrders])
        }
    }
    
    func refreshProducts(newOrders: [CustomerOrders]){
        self.queryResults = newOrders
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //since we are not grouping customers we are grouping them in only 1 group
        return queryResults.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryResults[section].customerOrders.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath)

        // Configure the cell...
        if(indexPath.section < queryResults.count && indexPath.row < queryResults[indexPath.section].customerOrders.count){
            cell.textLabel!.text = queryResults[indexPath.section].customerOrders[indexPath.row].code
            cell.detailTextLabel?.text = queryResults[indexPath.section].customerOrders[indexPath.row].product.name
        }

        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return queryResults[section].customerName
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            delete(IDOrder: queryResults[indexPath.section].customerOrders[indexPath.row].IDOrder)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! OrderDetailsViewController
        if(segue.identifier == "create" || segue.identifier == "edit"){
            vc.context = context
            if(segue.identifier == "edit"){
                let currentOrder = queryResults[(tableView.indexPathForSelectedRow?.section)!].customerOrders[(tableView.indexPathForSelectedRow?.row)!]
                vc.code = currentOrder.code
                vc.date = currentOrder.date
                vc.quantity = Int16(currentOrder.quantity)
                let price: Float = Float(currentOrder.quantity) * currentOrder.product.price
                vc.totalPrice = Decimal(Double(price))
                vc.customer = currentOrder.customer
                vc.product = currentOrder.product
                vc.order = currentOrder
                vc.isForUpdate = true
            }
        }
    }

    @IBAction func unwindToOrderList(segue: UIStoryboardSegue){
        let vc = segue.source as! OrderDetailsViewController
        if(!vc.isForUpdate){
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd"
            
            insert(code: vc.code, date: dateFormat.string(from: vc.date!), idProduct: vc.product!.IDProduct, idCustomer: vc.customer!.IDCustomer, quantity: Int(vc.quantity))
        } else {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyyy-MM-dd"
            update(code: vc.code, date: dateFormat.string(from: vc.date!), idProduct: (vc.product?.IDProduct)!, idCustomer: (vc.customer?.IDCustomer)!, idOrder: (vc.order?.IDOrder)!, quantity: Int(vc.quantity))
            vc.isForUpdate = false
        }
    }

}
