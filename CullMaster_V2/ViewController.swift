//
//  ViewController.swift
//  CullMaster_V2
//
//  Created by Mark Brady Ingle on 9/16/21.
//

import UIKit
import CoreData
import CoreBluetooth
// MARK: - Core Bluetooth service IDs
let Weight_Scale_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")

let Cork1_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914c")
let Cork2_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914d")
let Cork3_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914e")
let Cork4_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914f")
let Cork5_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c3319141")

// MARK: - Core Bluetooth characteristic IDs
let Weight_Characteristic_CBUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a6")
let Tare_Characteristic_CBUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a7")

class ViewController: UIViewController,CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var connectionActivityStatus: UIActivityIndicatorView!
    @IBOutlet weak var bluetoothOffLabel: UILabel!
        // Create instance variables of the
        // CBCentralManager and CBPeripheral so they
        // persist for the duration of the app's life
        // these vars cannot be listed in an extension so place them in the class
        var centralManager: CBCentralManager?
        var WeightScale: CBPeripheral?
        var Cork1: CBPeripheral?
        
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
            case .unknown:
                print("Bluetooth status is UNKNOWN")
                bluetoothOffLabel.alpha = 1.0
            case .resetting:
                print("Bluetooth status is RESETTING")
                bluetoothOffLabel.alpha = 1.0
            case .unsupported:
                print("Bluetooth status is UNSUPPORTED")
                bluetoothOffLabel.alpha = 1.0
            case .unauthorized:
                print("Bluetooth status is UNAUTHORIZED")
                bluetoothOffLabel.alpha = 1.0
            case .poweredOff:
                print("Bluetooth status is POWERED OFF")
                bluetoothOffLabel.alpha = 1.0
            case .poweredOn:
                print("Bluetooth status is POWERED ON")
                DispatchQueue.main.async { () -> Void in
                    self.bluetoothOffLabel.alpha = 0.0
                    self.connectionActivityStatus.backgroundColor = UIColor.black
                    self.connectionActivityStatus.startAnimating()
                    
                }
                
                //https://uynguyen.github.io/2020/08/23/Best-practice-Advanced-BLE-scanning-process-on-iOS/
                //https://www.bluetooth.com/blog/a-new-way-to-debug-iosbluetooth-applications/
                // Scan for peripherals that we're interested in
                //[Weight_Scale_Service_CBUUID,Cork1_Service_CBUUID, Cork2_Service_CBUUID,Cork3_Service_CBUUID,Cork4_Service_CBUUID,Cork5_Service_CBUUID]
                centralManager?.scanForPeripherals(withServices: [Cork1_Service_CBUUID, Weight_Scale_Service_CBUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                print("Central Manager Looking!!")
            default: break
            } // END switch
            
        }
    
    // STEP 4.1: discover what peripheral devices OF INTEREST
    // are available for this app to connect to
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        _ = FriendlyAdvData(rawAdvData: advertisementData, rssi: RSSI, friendlyName: peripheral.name)
        
        if peripheral.name == "CORK1"{
            print("Found the peripheral called CORK1")
            decodePeripheralState(peripheralState: peripheral.state)
            Cork1 = peripheral
            Cork1?.delegate = self
            centralManager?.connect(Cork1!)
        }
        if peripheral.name == "WSALE"{
            print("Found the peripheral called WSALE")
            decodePeripheralState(peripheralState: peripheral.state)
            WeightScale = peripheral
            WeightScale?.delegate = self
            centralManager?.connect(WeightScale!)
        }
        print("Peripheral Found ",peripheral.name!)
        //decodePeripheralState(peripheralState: peripheral.state)
        // STEP 4.2: MUST store a reference to the peripheral in
        // class instance variable
        // WeightScale = peripheral
        // STEP 4.3: since ViewController
        // adopts the CBPeripheralDelegate protocol,
        // the SeaArkLivewellTimer must set its
        // delegate property to ViewController
        // (self)
        //WeightScale?.delegate = self
        
        // Cork1 = peripheral
        // STEP 4.3: since ViewController
        // adopts the CBPeripheralDelegate protocol,
        // the SeaArkLivewellTimer must set its
        // delegate property to ViewController
        // (self)
        // Cork1?.delegate = self
        
        // STEP 5: stop scanning to preserve battery life;
        // re-scan if disconnected
        //centralManager?.stopScan()
        //print("Stopped Scanning")
        
        // STEP 6: connect to the discovered peripheral of interest
        
        
        
    } // END func centralManager(... didDiscover peripheral
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        DispatchQueue.main.async { () -> Void in
            
            self.connectionActivityStatus.backgroundColor = UIColor.green
            self.connectionActivityStatus.stopAnimating()
        }
        
        // STEP 8: look for services of interest on peripheral
        print("Did Connect....Looking for Scale")
        WeightScale?.discoverServices([Weight_Scale_Service_CBUUID])
        print("Did Connect....Looking for Cork")
        Cork1?.discoverServices([Cork1_Service_CBUUID])

    } // END func centralManager(... didConnect peripheral
    
    func decodePeripheralState(peripheralState: CBPeripheralState) {
        
        switch peripheralState {
            case .disconnected:
                print("Peripheral state: disconnected")
            case .connected:
                print("Peripheral state: connected")
            case .connecting:
                print("Peripheral state: connecting")
            case .disconnecting:
                print("Peripheral state: disconnecting")
        default: break
        }
        
    } // END func decodePeripheralState(peripheralState
   
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Get array of data that provides the Data View
    var items:[Fish_Table]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bluetoothOffLabel.alpha = 0.0
        tableView.dataSource = self
        tableView.delegate = self
        
        fetchFish()
        print("Creating Central Manager")
        
        // Create a concurrent background queue for the central
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.iosbrain.centralQueueName", attributes: .concurrent)
        
        // Create a central to scan for, connect to,
        // manage, and collect data from peripherals
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
            
    }
    
    func fetchFish() {
        //Fetch fish from the Core Data to display in table view
        // This fetch is pulling all data...review the video for pull data in sort order fro the final app
        do {
            self.items = try context.fetch(Fish_Table.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } catch {
            
        }
            
    }

    
    @IBAction func addTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Add Fish", message: "What is the cork color and fish weight", preferredStyle: .alert)
        alert.addTextField()
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action ) in
            
            let textfield1 = alert.textFields![0]
            let textfield2 = alert.textFields![1]
            
            //https://stackoverflow.com/questions/31922349/how-to-add-textfield-to-uialertcontroller-in-swift
            
            let newFish = Fish_Table(context: self.context)
            newFish.fish_ID = textfield1.text
            
            let number: Float = Float(textfield2.text ?? "N/A" ) ?? 1.0
            newFish.weight = number
            newFish.date = Date()
            
            do {
                try self.context.save()
            }
            catch {
                
            }
            self.fetchFish()
        
           
    }
        
        alert.addAction(submitButton)
        
        self.present(alert, animated:true, completion: nil)
    
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FishCell", for: indexPath)
        
        let fish = self.items![indexPath.row]
        
        let fish_ID = fish.fish_ID
        let fish_weight = String(fish.weight)
        let caught_date = fish.date!
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM/dd/yy | hh:mm:ss"
        
        //https://www.brianadvent.com/build-simple-core-data-driven-ios-app/
        
        cell.textLabel?.text = fish_ID! + " | " + "\(String(describing: fish_weight))" + " | " +  dateFormatter.string(from: caught_date)
        
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



