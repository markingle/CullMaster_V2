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

//let Cork1_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914c")
//let Cork2_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914d")
//let Cork3_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914e")
//let Cork4_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914f")
//let Cork5_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c3319141")

// MARK: - Core Bluetooth characteristic IDs
let Weight_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F5-EA07361B26A6")
let Tare_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B26B7")

class ViewController: UIViewController,CBCentralManagerDelegate, CBPeripheralDelegate {
    // MARK: - Core Bluetooth class member variables
    
    // Create instance variables of the
    // CBCentralManager and CBPeripheral so they
    // persist for the duration of the app's life
    // these vars cannot be listed in an extension so place them in the class
    var centralManager: CBCentralManager?
    var WeightScale: CBPeripheral?
    //var Cork1: CBPeripheral?
    
    @IBOutlet weak var weightDataLabel: UITextField!
    @IBOutlet weak var totalWeightLabel: UITextField!
    
    @IBOutlet weak var connectionActivityStatus: UIActivityIndicatorView!
    @IBOutlet weak var bluetoothOffLabel: UILabel!
    
    // Characteristics
    private var WeightData: CBCharacteristic?
    private var TareFlag: CBCharacteristic?
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Get array of data that provides the Data View
    var items:[Fish_Table]?
    
    //MARK: - VIEWDIDLOAD
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
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
                /*centralManager?.scanForPeripherals(withServices: [Cork1_Service_CBUUID, Weight_Scale_Service_CBUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                print("Central Manager Looking!!")*/
                centralManager?.scanForPeripherals(withServices: [Weight_Scale_Service_CBUUID])
                print("Central Manager Looking!!")
            default: break
            } // END switch
            
        }
    
    // STEP 4.1: discover what peripheral devices OF INTEREST
    // are available for this app to connect to
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
       /* _ = FriendlyAdvData(rawAdvData: advertisementData, rssi: RSSI, friendlyName: peripheral.name)
        
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
            centralManager?.stopScan()
            centralManager?.connect(WeightScale!)
        }*/
        print("Peripheral Found ",peripheral.name!)
        decodePeripheralState(peripheralState: peripheral.state)
        // STEP 4.2: MUST store a reference to the peripheral in
        // class instance variable
        WeightScale = peripheral
        // STEP 4.3: since ViewController
        // adopts the CBPeripheralDelegate protocol,
        // the SeaArkLivewellTimer must set its
        // delegate property to ViewController
        // (self)
        WeightScale?.delegate = self
        
        // Cork1 = peripheral
        // STEP 4.3: since ViewController
        // adopts the CBPeripheralDelegate protocol,
        // the SeaArkLivewellTimer must set its
        // delegate property to ViewController
        // (self)
        // Cork1?.delegate = self
        
        // STEP 5: stop scanning to preserve battery life;
        // re-scan if disconnected
        centralManager?.stopScan()
        print("Stopped Scanning")
        
        // STEP 6: connect to the discovered peripheral of interest
        centralManager?.connect(WeightScale!)
        
        
    } // END func centralManager(... didDiscover peripheral
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        DispatchQueue.main.async { () -> Void in
            
            self.connectionActivityStatus.backgroundColor = UIColor.green
            self.connectionActivityStatus.stopAnimating()
        }
        
        // STEP 8: look for services of interest on peripheral
        print("Did Connect....Looking for Scale")
        WeightScale?.discoverServices([Weight_Scale_Service_CBUUID])

    } // END func centralManager(... didConnect peripheral
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    
    for service in peripheral.services! {
        
        if service.uuid == Weight_Scale_Service_CBUUID {
            
            print("Service: \(service)")
            
            // STEP 9: look for characteristics of interest
            // within services of interest
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionActivityStatus.backgroundColor = UIColor.black
        connectionActivityStatus.startAnimating()
        centralManager?.scanForPeripherals(withServices: [Weight_Scale_Service_CBUUID])
        print("Central Manager Looking!!")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for characteristic in service.characteristics! {
            
            print("Characteristic: \(characteristic)")
            
            if characteristic.uuid == Weight_Characteristic_CBUUID{
                print("Weight Data")
                WeightData = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
            if characteristic.uuid == Tare_Characteristic_CBUUID{
                print("Tare Flag")
                TareFlag = characteristic
                
            }
        }
    } // END func peripheral(... didDiscoverCharacteristicsFor service
    
    //https://quickbirdstudios.com/blog/read-ble-characteristics-swift/
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print(characteristic)
        
        if characteristic.uuid == Weight_Characteristic_CBUUID {
            
            // We generally have to decode BLE
            // data into human readable format
            
            let weight = characteristic.value!
            print(String(data: weight, encoding: String.Encoding.ascii)!);
            
            DispatchQueue.main.async { () -> Void in
                self.weightDataLabel.text = String(data: weight, encoding: String.Encoding.ascii)

        } // END if characteristic.uuid ==...
        }
        
    } // END func peripheral(... didUpdateValueFor characteristic
    
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
                self.tableView.reloadData()
            }
            totalWeight()
        } catch {
            
        }
            
    }
    
    func totalWeight() -> NSNumber? {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return 1
            }
            
            //1
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //2
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Fish_Table", in: managedContext)
            fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
            
            //3
            let keypathExpression = NSExpression(forKeyPath: "weight")
            let maxExpression = NSExpression(forFunction: "sum:", arguments: [keypathExpression])
            
            let key = "totalweight"
            
            //4
            let expressionDescription = NSExpressionDescription()
            expressionDescription.name = key
            expressionDescription.expression = maxExpression
            expressionDescription.expressionResultType = .decimalAttributeType
            
            //5
            fetchRequest.propertiesToFetch = [expressionDescription]
            
            do {
                let result = try managedContext.fetch(fetchRequest) as! [NSDictionary]
                
                let resultDic = result.first!
                let total_weight = resultDic["totalweight"]!
                    print("Total Weight : \(total_weight)")
                DispatchQueue.main.async { () -> Void in
                    self.totalWeightLabel.text! = "\(total_weight)"
                }
            } catch {
                print("fetch failed")
            }
            return 123
        }
    
    func showsmallest() -> NSNumber? {
            //Fetch fish from the Core Data to display in table view
            // This fetch is pulling all data...review the video for pull data in sort order fro the final app
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return 1
            }
            
            //1
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //2
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Fish_Table", in: managedContext)
            fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
            
            //3
            let keypathExpression = NSExpression(forKeyPath: "weight")
            let maxExpression = NSExpression(forFunction: "min:", arguments: [keypathExpression])
            
            let key = "minweight"
            
            //4
            let expressionDescription = NSExpressionDescription()
            expressionDescription.name = key
            expressionDescription.expression = maxExpression
            expressionDescription.expressionResultType = .decimalAttributeType
            
            //5
            fetchRequest.propertiesToFetch = [expressionDescription]
            
            //var minweight: Float? = nil
            
            do {
                let result = try managedContext.fetch(fetchRequest) as! [NSDictionary]
                
                let resultDic = result.first!
                let numDeals = resultDic["minweight"]!
                    print("Min Weight : \(numDeals)")
            } catch {
                print("fetch failed")
            }
            return 123
        }

    @IBAction func captureWeight(_ sender: Any) {
        //let alert = UIAlertController(title: "Add weight", message: nil, preferredStyle: .alert)
        //alert.addTextField()
        
        //let submitButton = UIAlertAction(title: "Add", style: .default) { (action ) in
            
            
            //https://stackoverflow.com/questions/31922349/how-to-add-textfield-to-uialertcontroller-in-swift
            
            let newFish = Fish_Table(context: self.context)
            newFish.fish_ID = "Green"
            
        let number: NSDecimalNumber = NSDecimalNumber(string: self.weightDataLabel.text ?? "111" )
                    newFish.weight = number
                    newFish.date = Date()
                    
                    do {
                        try self.context.save()
                    }
                    catch {
                        
                    }
                    self.fetchFish()
                    self.showsmallest()
    //}
        
        //alert.addAction(submitButton)
        
       // self.present(alert, animated:true, completion: nil)
    
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
            
            
            let number: NSDecimalNumber = NSDecimalNumber(string: textfield2.text ?? "N/A" )
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
    
    func writeonStateValueToChar( withCharacteristic characteristic: CBCharacteristic, withValue value: Data) {
        if characteristic.properties.contains(.writeWithoutResponse) && WeightScale != nil {
            WeightScale?.writeValue(value, for: characteristic, type:.withoutResponse)
        }
    }
    
    @IBAction func sendTareRequest(_ sender: Any) {
        print("Hello Tare")
        let SwitchState = "1"
        let data = Data(SwitchState.utf8)
        print("data = ", data)
        writeonStateValueToChar(withCharacteristic: TareFlag!, withValue: data)
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
        let fish_weight = fish.weight!
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



