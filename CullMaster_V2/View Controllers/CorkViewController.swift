//
//  CorkViewController.swift
//  CullMaster_V2
//
//  Created by Mark Brady Ingle on 9/28/21.
//

import UIKit
import CoreData
import CoreBluetooth

class CorkViewController: UIViewController {
    
    @IBOutlet weak var cullCorkList: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items:[Fish_Table]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cullCorkList.dataSource = self
        cullCorkList.delegate = self
        
        fetchFish()
        
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func fetchFish() {
        //Fetch fish from the Core Data to display in table view
        // This fetch is pulling all data...review the video for pull data in sort order fro the final app
        do {
            //FILTERING
            /*let request = Fish_Table.fetchRequest() as NSFetchRequest<Fish_Table>
            let pred = NSPredicate(format: "fish_ID CONTAINS 'Green'")
            request.predicate = pred
            self.items = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }*/
            //SORTING
            let request = Fish_Table.fetchRequest() as NSFetchRequest<Fish_Table>
            let sort = NSSortDescriptor(key: "weight", ascending: false)
            request.sortDescriptors = [sort]
            self.items = try context.fetch(request)
            DispatchQueue.main.async {
                self.cullCorkList.reloadData()
            }
        } catch {
            
        }
            
    }
    
}

extension CorkViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FishCell_History", for: indexPath)
        
        let fish = self.items![indexPath.row]
        
        let fish_ID = fish.fish_ID
        let fish_weight = fish.weight!
        let caught_date = fish.date!
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM/dd/yy | hh:mm:ss"
        
        //https://www.brianadvent.com/build-simple-core-data-driven-ios-app/
        
        cell.textLabel?.text = fish_ID! + " | " + "\(String(describing: fish_weight))" + " | " +  dateFormatter.string(from: caught_date)
        print("helo.......)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //Which fish to remove
            let fishToRemove = self.items![indexPath.row]
            
            self.context.delete(fishToRemove)
            
            do {
                try self.context.save()
            }
            catch {
                
            }
            
            self.fetchFish()
        }
            
        // Return the swipe action
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    //  ADD EDIT FUNCTION LATER ON.....
}


