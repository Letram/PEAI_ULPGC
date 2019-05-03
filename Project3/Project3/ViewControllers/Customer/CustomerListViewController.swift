import UIKit
import CoreData

class CustomerListViewController: UITableViewController {
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBAction func editBtnTapped(_ sender: Any) {
        if(self.tableView.isEditing){
            self.tableView.setEditing(false, animated:true)
            editButton.title = "Edit"
        }else{
            self.tableView.setEditing(true, animated:true)
            editButton.title = "Done"
        }
    }
        
    let customerService = CustomerQueryService()
    var queryResults: [CustomerModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        customerService.delegate = self
        getAll()

    }
    
    //MARK: - Consultas
    func getAll(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        customerService.getAll(){ results, errorMsg in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.refreshCustomers(newCustomers: results as! [CustomerModel])
            if !errorMsg.isEmpty { print("Search error: " + errorMsg) }
            
        }
    }
    
    func insert(address: String, name: String) {
        
        var params: [String: Any] = [:]
        
        params["address"] = address
        params["name"] = name
        
        customerService.insert(params: params){ results, errorMsg in
            self.refreshCustomers(newCustomers: results as! [CustomerModel])
        }
    }
    
    func update(name: String, address: String, idCustomer: Int){
        var params: [String: Any] = [:]
        
        params["name"] = name
        params["address"] = address
        params["IDCustomer"] = idCustomer
        
        customerService.update(params: params){ results, errorMsg in
            self.refreshCustomers(newCustomers: results as! [CustomerModel])
        }
    }

    func delete(IDCustomer: Int){
        let params = ["IDCustomer" : IDCustomer]
        
        customerService.delete(params: params) { results, errorMsg in
            self.refreshCustomers(newCustomers: results as! [CustomerModel])
        }
    }
    
    func refreshCustomers(newCustomers: [CustomerModel]){
        self.queryResults = newCustomers
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPoint.zero, animated: false)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queryResults.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customerCell", for: indexPath)
        // Configure the cell...
        cell.textLabel?.text = queryResults[indexPath.row].name
        cell.detailTextLabel?.text = queryResults[indexPath.row].address
        return cell
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let aux = queryResults[indexPath.row].IDCustomer
            delete(IDCustomer: aux)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as? CustomerDetailsViewController
        switch segue.identifier {
        case "edit":
            let tableIndex = tableView.indexPathForSelectedRow
            vc?.customerNameText = queryResults[(tableIndex?.row)!].name
            vc?.customerAddressText = queryResults[(tableIndex?.row)!].address
            vc?.IDCustomer = queryResults[(tableIndex?.row)!].IDCustomer
            vc?.isForUpdate = true
            break
        default:
            break
        }
    }
    
    @IBAction func unwindInsert(segue: UIStoryboardSegue){
        let vc = segue.source as? CustomerDetailsViewController
        if (vc?.isForUpdate ?? false){
            update(name: (vc?.customerNameText)!, address: (vc?.customerAddressText)!, idCustomer: (vc?.IDCustomer)!)
            vc?.isForUpdate = false
        }else{
            insert(address: (vc?.customerAddressText)!, name: (vc?.customerNameText)!)
        }
    }

}
