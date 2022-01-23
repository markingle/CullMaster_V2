//
//  ViewController.swift
//  CullMaster_V2
//
//  Created by Mark Brady Ingle on 9/16/21.
//
//www.splinter.com.au/2019/05/18/ios-swift-bluetooth-le/
//github.com/espressif/esp-idf/blob/master/examples/bluetooth/bluedroid/ble/gatt_security_server/tutorial/Gatt_Security_Server_Example_Walkthrough.md
//www.youtube.com/watch?v=TwexLJwdLEw

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
//WEIGHT SCALE CHARACTERISTICS
let Weight_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F5-EA07361B26A6")
let Tare_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B26B7")

//CORK CHARACTERISTICS PREFERRED (One characteristic for all corks.  There are three corks - 1 to 3....Why cant I do this!!!)
let Fish_Weight_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F5-EA07361B26C8")
let Battery_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F5-EA07361B26D9")

//CORK CHARACTERISTICS WORKING (One characteristic for each cork...1 - 1  This doesnt seem right!!!!  :(  )
let Cork1_FlashRGB_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B2611")
let Cork2_FlashRGB_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B2612")
let Cork3_FlashRGB_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B2613")

class ViewController: UIViewController,CBCentralManagerDelegate, CBPeripheralDelegate {
    // MARK: - Core Bluetooth class member variables
    
    // Create instance variables of the
    // CBCentralManager and CBPeripheral so they
    // persist for the duration of the app's life
    // these vars cannot be listed in an extension so place them in the class
    var centralManager: CBCentralManager?
    var WeightScale: CBPeripheral?
    var Cork1: CBPeripheral?
    var Cork2: CBPeripheral?
    var Cork3: CBPeripheral?
    var Cork4: CBPeripheral?
    var Cork5: CBPeripheral?
    
    @IBOutlet weak var weightDataLabel: UITextField!
    @IBOutlet weak var totalWeightLabel: UITextField!
    
    @IBOutlet weak var connectionActivityStatus: UIActivityIndicatorView!
    @IBOutlet weak var bluetoothOffLabel: UILabel!

    @IBOutlet weak var catchHistory: UITabBar!
    
    @IBOutlet weak var cullCorkList: UITabBar!
    
    // Characteristics
    private var WeightData: CBCharacteristic?
    private var TareFlag: CBCharacteristic?
    private var Cork1_FlashRGBFlag: CBCharacteristic?
    private var Cork2_FlashRGBFlag: CBCharacteristic?
    private var Cork3_FlashRGBFlag: CBCharacteristic?
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Get array of data that provides the Data View
    var items:[Fish_Table]?
    var corks:[Cork_Table]?

    
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
                
                //uynguyen.github.io/2020/08/23/Best-practice-Advanced-BLE-scanning-process-on-iOS/
                //www.bluetooth.com/blog/a-new-way-to-debug-iosbluetooth-applications/
                //toscode.gitee.com/pingdan/IOS-CoreBluetooth-Mock/tree/develop
                //Scan for peripherals that we're interested in
                //[Weight_Scale_Service_CBUUID,Cork1_Service_CBUUID, Cork2_Service_CBUUID,Cork3_Service_CBUUID,Cork4_Service_CBUUID,Cork5_Service_CBUUID]
                //centralManager?.scanForPeripherals(withServices: [Cork1_Service_CBUUID, Weight_Scale_Service_CBUUID], options: [CBCentralManagerScanOptionSolicitedServiceUUIDsKey: true])
                //print("Central Manager Looking!!")

                centralManager?.scanForPeripherals(withServices: [Weight_Scale_Service_CBUUID,Cork1_Service_CBUUID,Cork2_Service_CBUUID,Cork3_Service_CBUUID, Cork4_Service_CBUUID,Cork5_Service_CBUUID])
                print("Central Manager Looking!!")
            default: break
            } // END switch
            
        }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
       _ = FriendlyAdvData(rawAdvData: advertisementData, rssi: RSSI, friendlyName: peripheral.name)
        //Use a flag for now
        //TODO: Build setup for storing cull corks in a table
        
        let reset_corks = 1
        
//>>>>>>>>>>>>>>>>>>>>>>>>> CORK 1 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
        if peripheral.name == "CORK1"{
            print("Found the peripheral called CORK1")
            if reset_corks == 1 {
                let name = peripheral.name
                let newCork = Cork_Table(context: self.context)
                newCork.name = name
                newCork.mAC = "11-11-11-11-11-11"
                newCork.used = 0
                do {
                    try self.context.save()
                    }
                catch {
                }
            }
            
            decodePeripheralState(peripheralState: peripheral.state)
            Cork1 = peripheral
            Cork1?.delegate = self
            centralManager?.connect(Cork1!)
            decodePeripheralState(peripheralState: peripheral.state)
        }
    
//>>>>>>>>>>>>>>>>>>>>>>>>> CORK 2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        if peripheral.name == "CORK2"{
            print("Found the peripheral called CORK2")
            if reset_corks == 1 {
                let name = peripheral.name
                let newCork = Cork_Table(context: self.context)
                newCork.name = name
                newCork.mAC = "22-22-22-22-22-22"
                newCork.used = 0
                do {
                    try self.context.save()
                    }
                catch {
                }
            }
            
            decodePeripheralState(peripheralState: peripheral.state)
            Cork2 = peripheral
            Cork2?.delegate = self
            centralManager?.connect(Cork2!)
            decodePeripheralState(peripheralState: peripheral.state)
        }

//>>>>>>>>>>>>>>>>>>>>>>>>> CORK 3 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        if peripheral.name == "CORK3"{
            print("Found the peripheral called CORK3")
            if reset_corks == 1 {
                let name = peripheral.name
                let newCork = Cork_Table(context: self.context)
                newCork.name = name
                newCork.mAC = "33-33-33-33-33-33"
                newCork.used = 0
                do {
                    try self.context.save()
                    }
                catch {
                }
            }
            
            decodePeripheralState(peripheralState: peripheral.state)
            Cork3 = peripheral
            Cork3?.delegate = self
            centralManager?.connect(Cork3!)
            decodePeripheralState(peripheralState: peripheral.state)
        }

//>>>>>>>>>>>>>>>>>>>>>>>>> CORK 4 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
/*
                if peripheral.name == "CORK4"{
                    print("Found the peripheral called CORK4")
                    if reset_corks == 1 {
                        let name = peripheral.name
                        let newCork = Cork_Table(context: self.context)
                        newCork.name = name
                        newCork.mAC = "44-44-44-44-44-44"
                        newCork.used = 0
                        do {
                            try self.context.save()
                            }
                        catch {
                        }
                    }
                    
                    decodePeripheralState(peripheralState: peripheral.state)
                    Cork4 = peripheral
                    Cork4?.delegate = self
                    centralManager?.connect(Cork4!)
                    decodePeripheralState(peripheralState: peripheral.state)
                }
        
        
//>>>>>>>>>>>>>>>>>>>>>>>>> CORK 5 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                       
                        if peripheral.name == "CORK5"{
                            print("Found the peripheral called CORK5")
                            if reset_corks == 1 {
                                let name = peripheral.name
                                let newCork = Cork_Table(context: self.context)
                                newCork.name = name
                                newCork.mAC = "55-55-55-55-55-55"
                                newCork.used = 0
                                do {
                                    try self.context.save()
                                    }
                                catch {
                                }
                            }
                            
                            decodePeripheralState(peripheralState: peripheral.state)
                            Cork5 = peripheral
                            Cork5?.delegate = self
                            centralManager?.connect(Cork5!)
                            decodePeripheralState(peripheralState: peripheral.state)
                        }
*/
//>>>>>>>>>>>>>>>>>>>>>>>>> WSCALE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
       
        if peripheral.name == "WSALE"{
            print("Found the peripheral called WSALE")
            
            decodePeripheralState(peripheralState: peripheral.state)
            WeightScale = peripheral
            WeightScale?.delegate = self
            centralManager?.connect(WeightScale!)
            decodePeripheralState(peripheralState: peripheral.state)
        }
        
} // END func centralManager(... didDiscover peripheral
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
       //print("Stopping Scan for Peripherals")
       //centralManager?.stopScan()
        
        DispatchQueue.main.async { () -> Void in
            
            self.connectionActivityStatus.backgroundColor = UIColor.green
            self.connectionActivityStatus.stopAnimating()
        }
        
        // STEP 8: look for services of interest on peripheral
        
        decodePeripheralState(peripheralState: peripheral.state)
        if peripheral == WeightScale {
            print("Did Connect....Looking for Scale Service")
            WeightScale?.discoverServices([Weight_Scale_Service_CBUUID])
        }
        
        decodePeripheralState(peripheralState: peripheral.state)
        if peripheral == Cork1 {
            print("Did Connect....Looking for Cork1 Service")
            Cork1?.discoverServices([Cork1_Service_CBUUID])
        }
        
        
        decodePeripheralState(peripheralState: peripheral.state)
        if peripheral == Cork2 {
            print("Did Connect....Looking for Cork2 Service")
            Cork2?.discoverServices([Cork2_Service_CBUUID])
        }
        
        
        decodePeripheralState(peripheralState: peripheral.state)
        if peripheral == Cork3 {
            print("Did Connect....Looking for Cork3 Service")
            Cork3?.discoverServices([Cork3_Service_CBUUID])
        }
        
        
        decodePeripheralState(peripheralState: peripheral.state)
        if peripheral == Cork4 {
            print("Did Connect....Looking for Cork4 Service")
            Cork4?.discoverServices([Cork4_Service_CBUUID])
        }
        
        
        decodePeripheralState(peripheralState: peripheral.state)
        if peripheral == Cork5 {
            print("Did Connect....Looking for Cork5 Service")
            Cork5?.discoverServices([Cork5_Service_CBUUID])
        }
        
    } // END func centralManager(... didConnect peripheral
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    
    for service in peripheral.services! {
        
        if service.uuid == Weight_Scale_Service_CBUUID {
            
            print("Service: \(service)")
            
            // STEP 9: look for characteristics of interest
            // within services of interest
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == Cork1_Service_CBUUID {
            
            print("Service: \(service)")
            
            // STEP 9: look for characteristics of interest
            // within services of interest
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == Cork2_Service_CBUUID {
            
            print("Service: \(service)")
            
            // STEP 9: look for characteristics of interest
            // within services of interest
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == Cork3_Service_CBUUID {
            
            print("Service: \(service)")
            
            // STEP 9: look for characteristics of interest
            // within services of interest
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == Cork4_Service_CBUUID {
            
            print("Service: \(service)")
            
            // STEP 9: look for characteristics of interest
            // within services of interest
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        if service.uuid == Cork5_Service_CBUUID {
            
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
        centralManager?.scanForPeripherals(withServices: [Weight_Scale_Service_CBUUID,Cork1_Service_CBUUID,Cork2_Service_CBUUID,Cork3_Service_CBUUID, Cork4_Service_CBUUID,Cork5_Service_CBUUID])
        print("Peripheral disconnect.....Central Manager Looking!!")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        
        print("Service didDiscoverChar: \(service)")
        
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
                self.TareFlag = characteristic
            }
            
            if characteristic.uuid == Cork1_FlashRGB_Characteristic_CBUUID{
                print("Flash RBG Flag")
                self.Cork1_FlashRGBFlag = characteristic
            }
            
            if characteristic.uuid == Cork2_FlashRGB_Characteristic_CBUUID{
                print("Flash RBG Flag")
                self.Cork2_FlashRGBFlag = characteristic
            }
            
            if characteristic.uuid == Cork3_FlashRGB_Characteristic_CBUUID{
                print("Flash RBG Flag")
                self.Cork3_FlashRGBFlag = characteristic
            }
        }
    } // END func peripheral(... didDiscoverCharacteristicsFor service
    
    //https://quickbirdstudios.com/blog/read-ble-characteristics-swift/
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        //print(characteristic)
        
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
    
    func sendFlashRGB(cork_to_flag: String, flag: String) {
        print("Sending Flash RGB")
        
        switch cork_to_flag {
            
        case "CORK1":
            
            let FlashState = flag
            let data = Data(FlashState.utf8)
            print("data = ", data)
            Cork1?.writeValue(data, for: Cork1_FlashRGBFlag!, type: .withoutResponse)
            
        case "CORK2":
            
            let FlashState = flag
            let data = Data(FlashState.utf8)
            print("data = ", data)
            Cork2?.writeValue(data, for: Cork2_FlashRGBFlag!, type: .withoutResponse)
            
        case "CORK3":
            
            let FlashState = flag
            let data = Data(FlashState.utf8)
            print("data = ", data)
            Cork3?.writeValue(data, for: Cork3_FlashRGBFlag!, type: .withoutResponse)
            
        default:
            print("NO CORK TO SEND.....")
    }
    }
    
    
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
            request.fetchLimit = 3         //CHANGE THIS BACK TO 5 WHEN YOU GET MORE TinyPICO
            self.items = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            totalWeight()
        } catch {
            
        }
            
    }
    
    
    //docs.swift.org/swift-book/LanguageGuide/Functions.html
    
    func totalWeight() {
            //1
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Fish_Table", in: context)
            fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
            
            //2
            let keypathExpression = NSExpression(forKeyPath: "weight")
            let maxExpression = NSExpression(forFunction: "sum:", arguments: [keypathExpression])
            
            let key = "totalweight"
            
            //3
            let expressionDescription = NSExpressionDescription()
            expressionDescription.name = key
            expressionDescription.expression = maxExpression
            expressionDescription.expressionResultType = .decimalAttributeType
            
            //4
            fetchRequest.propertiesToFetch = [expressionDescription]
            
            do {
                let result = try context.fetch(fetchRequest) as! [NSDictionary]
                
                let resultDic = result.first!
                let total_weight = resultDic["totalweight"]!
                    print("Total Weight : \(total_weight)")
                DispatchQueue.main.async { () -> Void in
                    self.totalWeightLabel.text! = "\(total_weight)"
                }
            } catch {
                print("fetch failed")
            }
    }
    
    func deleteMinWeight(min_cork: String){
        print("Cork to cull :\(min_cork)")
        
        do {
        // Cast the result returned from the fetchRequest as Person class
        let minfetchRequest = Fish_Table.fetchRequest() as NSFetchRequest<Fish_Table>

        // Sort using these properties, can put in mulitple sort descriptor here
        let minsort = NSSortDescriptor(key: "weight", ascending: true)
        minfetchRequest.sortDescriptors = [minsort]
        self.items = try context.fetch(minfetchRequest)
        let minitem = self.items?.first!
        //let minweight = (minitem?.weight)!
        context.delete(minitem!)
    } catch {
        print("min sort fetch failed")
        }
    }
    
    func showsmallest(assign_capturedWeight: NSDecimalNumber) {
            
            /*//1
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Fish_Table", in: context)
            fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
            
            //2
            let keypathExpression = NSExpression(forKeyPath: "weight")
            let maxExpression = NSExpression(forFunction: "min:", arguments: [keypathExpression])
            
            let key = "minweight"
            
            //3
            let expressionDescription = NSExpressionDescription()
            expressionDescription.name = key
            expressionDescription.expression = maxExpression
            expressionDescription.expressionResultType = .decimalAttributeType
       
            //4
            fetchRequest.propertiesToFetch = [expressionDescription,"fish_ID"]
            */
        
            do {
                let request = Fish_Table.fetchRequest() as NSFetchRequest<Fish_Table>
                let sort = NSSortDescriptor(key: "weight", ascending: true)
                request.sortDescriptors = [sort]
                //request.fetchLimit = 3         //CHANGE THIS BACK TO 5 WHEN YOU GET MORE TinyPICO
                self.items = try context.fetch(request)
                let minitem = self.items?.first!
                let minweight = minitem?.weight
                print("Min Weight : \(String(describing: minweight))")
                let Cork = minitem?.fish_ID  ?? "---"
                let alert = UIAlertController(title: "Cull \(Cork) @ \(minweight ?? 000)", message: "", preferredStyle: .alert)
                sendFlashRGB(cork_to_flag: Cork, flag: "1") // <-- Start flashing the RGB on the Cork
                alert.addAction (UIAlertAction(title: "Cull Fish", style: .default) { (alertAction) in
                    
                    //TODO: WRITE RECORD TO HISTORY TABLE BEFORE OF DELETE
                    
                    self.deleteMinWeight(min_cork: Cork)
                    
                    let newFish = Fish_Table(context: self.context)
                    newFish.fish_ID = minitem?.fish_ID
                    newFish.weight = assign_capturedWeight
                    newFish.date = Date()
                            
                    do {
                        try self.context.save()
                    }catch {
                                    
                    }
                    self.fetchFish()
                    self.sendFlashRGB(cork_to_flag: Cork, flag: "0")  // <-- Stop flashing the RGB on the Cork
                    
                })
            
            
            //Cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (alertAction) in })
            self.present(alert, animated:true, completion: nil)
            //self.sendFlashRGB(cork_to_flag: Cork, flag: "0")  // <-- Stop flashing the RGB on the Cork
        } catch {
        print("fetch failed")
    }
}

    @IBAction func captureWeight(_ sender: Any) {
        //let alert = UIAlertController(title: "Add weight", message: nil, preferredStyle: .alert)
        //alert.addTextField()
        
        //let submitButton = UIAlertAction(title: "Add", style: .default) { (action ) in
            
        //stackoverflow.com/questions/31922349/how-to-add-textfield-to-uialertcontroller-in-swift
        
        //var selectedCork = "Temp"
        
        let capturedWeight = NSDecimalNumber(string: self.weightDataLabel.text!)
        
        print("test \(String(describing: capturedWeight))")
        
        do {
            let request = Cork_Table.fetchRequest() as NSFetchRequest<Cork_Table>
            let pred = NSPredicate(format: "used = %i", 0)
            request.predicate = pred
            request.fetchLimit = 1
    
            let results = try context.fetch(request)
            
            if results.count != 0 {
                for data in results as [NSManagedObject] {
                    
                    print(data.value(forKey: "name") as! String)
                    //selectedCork = data.value(forKey: "name") as! String
                    
                    results.first?.used = 1
                    
                    let Cork = results.first?.name
                    self.sendFlashRGB(cork_to_flag: Cork ?? "---", flag: "1")  // <-- Start flashing the RGB on the Cork
                    print("Init Cork \(String(describing: Cork))")
                    let alertController = UIAlertController(title: "Weight Captured", message:"", preferredStyle: .alert)
                    // add the actions (buttons)
                    alertController.addAction (UIAlertAction(title: "Cork Attached?", style: .default) { (alertAction) in
                    self.sendFlashRGB(cork_to_flag: Cork ?? "---", flag: "0")  // <-- Start flashing the RGB on the Cork
                    })
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { (alertAction) in })
                    self.present(alertController, animated:true, completion: nil)
                    
                    let newFish = Fish_Table(context: self.context)
                    newFish.fish_ID = results.first!.name
                    newFish.weight = capturedWeight
                    newFish.date = Date()
                                
                    do {
                        try self.context.save()
                    }catch {
                        print("Save Failed.........")
                    }
                    self.fetchFish()
                    //self.sendFlashRGB(cork_to_flag: "CORK1", flag: "0")  // <-- Stop flashing the RGB on the Cork
                }
            } else {
                    self.showsmallest(assign_capturedWeight: capturedWeight)
                }
            //DispatchQueue.main.async {
            //    self.tableView.reloadData()
            //}
            
        } catch {
            print("Cork Sort for unused failed")
        }
            
        
    //}
        
        //alert.addAction(submitButton)
        
       // self.present(alert, animated:true, completion: nil)
    
    }
    
    @IBAction func corkList(){
        guard let vc = storyboard!.instantiateViewController(withIdentifier: "Cork_VC_ID") as? CorkViewController else {
            return
        }
                present(vc, animated: true)
    }
    
    @IBAction func catchListView(){
        guard let vc = storyboard!.instantiateViewController(withIdentifier: "Cork_VC_ID") as? CorkViewController else {
            return
        }
                present(vc, animated: true)
    }
    
    @IBAction func configCullCorks(){
        let alert = UIAlertController(title: "Cork Setup", message: "Are you sure you want to setup new corks?" , preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                print("Run Cork Setup")
        }))
        
        self.present(alert, animated: true)
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



