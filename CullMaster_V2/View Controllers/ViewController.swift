//
//  ViewController.swift
//  CullMaster_V2
//
//  Created by Mark Brady Ingle on 9/16/21.
//
//www.splinter.com.au/2019/05/18/ios-swift-bluetooth-le/
//github.com/espressif/esp-idf/blob/master/examples/bluetooth/bluedroid/ble/gatt_security_server/tutorial/Gatt_Security_Server_Example_Walkthrough.md
//www.youtube.com/watch?v=TwexLJwdLEw
//nspredicate.xyz/coredata.html


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

let RED_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914c")
let GREEN_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914d")
let BLACK_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914e")
let YELLO_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914f")
let WHITE_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c3319141")
//let BLUE_Service_CBUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c3319142")

let GREEN_Battery_Service_CBUUID = CBUUID(string: "180F")
let YELLO_Battery_Service_CBUUID = CBUUID(string: "180F")
let RED_Battery_Service_CBUUID = CBUUID(string: "180F")
let BLACK_Battery_Service_CBUUID = CBUUID(string: "180F")
let WHITE_Battery_Service_CBUUID = CBUUID(string: "180F")




// MARK: - Core Bluetooth characteristic IDs
//WEIGHT SCALE CHARACTERISTICS
let Weight_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F5-EA07361B26A6")
let Tare_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B26B7")

//CORK CHARACTERISTICS PREFERRED (One characteristic for all corks.  There are three corks - 1 to 3....Why cant I do this!!!)
let Fish_Weight_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F5-EA07361B26C8")
let GREEN_Battery_Characteristic_CBUUID = CBUUID(string: "2A19")
let YELLO_Battery_Characteristic_CBUUID = CBUUID(string: "2A20")
let RED_Battery_Characteristic_CBUUID = CBUUID(string: "2A21")
let WHITE_Battery_Characteristic_CBUUID = CBUUID(string: "2A18")
let BLACK_Battery_Characteristic_CBUUID = CBUUID(string: "2A23")

//CORK CHARACTERISTICS WORKING (One characteristic for each cork...1 - 1  This doesnt seem right!!!!  :(  )
let RED_FlashRGB_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B2611")
let GREEN_FlashRGB_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B2612")
let BLACK_FlashRGB_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B2613")
let YELLO_FlashRGB_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B2614")
let WHITE_FlashRGB_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B2615")
//let BLUE_FlashRGB_Characteristic_CBUUID = CBUUID(string: "BEB5483E-36E1-4688-B7F6-EA07361B2616")

class ViewController: UIViewController,CBCentralManagerDelegate, CBPeripheralDelegate {
    // MARK: - Core Bluetooth class member variables
    
    // Create instance variables of the
    // CBCentralManager and CBPeripheral so they
    // persist for the duration of the app's life
    // these vars cannot be listed in an extension so place them in the class
    var centralManager: CBCentralManager?
    var WeightScale: CBPeripheral?
    var RED: CBPeripheral?
    var GREEN: CBPeripheral?
    var BLACK: CBPeripheral?
    var YELLO: CBPeripheral?
    var WHITE: CBPeripheral?
    //var BLUE: CBPeripheral?
    
    @IBOutlet weak var weightDataLabel: UITextField!
    @IBOutlet weak var totalWeightLabel: UITextField!
    
    @IBOutlet weak var REDBatteryInfoText: UITextField!
    @IBOutlet weak var GREENBatteryInfoText: UITextField!
    @IBOutlet weak var YELLOBatteryInfoText: UITextField!
    @IBOutlet weak var BLACKBatteryInfoText: UITextField!
    @IBOutlet weak var WHITEBatteryInfoText: UITextField!
    
    @IBOutlet weak var connectionActivityStatus: UIActivityIndicatorView!
    @IBOutlet weak var bluetoothOffLabel: UILabel!

    @IBOutlet weak var catchHistory: UITabBar!
    
    @IBOutlet weak var cullCorkList: UITabBar!
    
    // SCALE WEIGHT Characteristics
    private var WeightData: CBCharacteristic?
    private var TareFlag: CBCharacteristic?
    
    private var GREENBatteryInfo: CBCharacteristic?
    private var YELLOBatteryInfo: CBCharacteristic?
    private var REDBatteryInfo: CBCharacteristic?
    private var BLACKBatteryInfo: CBCharacteristic?
    private var WHITEBatteryInfo: CBCharacteristic?
   
    
    // CORK FLASH RGB Characteristics
    private var RED_FlashRGBFlag: CBCharacteristic?
    private var GREEN_FlashRGBFlag: CBCharacteristic?
    private var BLACK_FlashRGBFlag: CBCharacteristic?
    private var YELLO_FlashRGBFlag: CBCharacteristic?
    private var WHITE_FlashRGBFlag: CBCharacteristic?
    //private var BLUE_FlashRGBFlag: CBCharacteristic?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Get array of data that provides the Data View
    var items:[Fish_Table]?
    var corks:[Cork_Table]?

    
    //MARK: - VIEWDIDLOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bluetoothOffLabel.alpha = 1.0
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
                    self.bluetoothOffLabel.alpha = 1.0
                    self.connectionActivityStatus.backgroundColor = UIColor.black
                    self.connectionActivityStatus.startAnimating()
                    
                }
                
                //uynguyen.github.io/2020/08/23/Best-practice-Advanced-BLE-scanning-process-on-iOS/
                //www.bluetooth.com/blog/a-new-way-to-debug-iosbluetooth-applications/
                //toscode.gitee.com/pingdan/IOS-CoreBluetooth-Mock/tree/develop
                //Scan for peripherals that we're interested in
                //[Weight_Scale_Service_CBUUID,RED_Service_CBUUID, GREEN_Service_CBUUID,BLACK_Service_CBUUID,YELLO_Service_CBUUID,WHITE_Service_CBUUID]
                //centralManager?.scanForPeripherals(withServices: [RED_Service_CBUUID, Weight_Scale_Service_CBUUID], options: [CBCentralManagerScanOptionSolicitedServiceUUIDsKey: true])
                //print("Central Manager Looking!!")

                centralManager?.scanForPeripherals(withServices: [Weight_Scale_Service_CBUUID,RED_Service_CBUUID,GREEN_Service_CBUUID,BLACK_Service_CBUUID, YELLO_Service_CBUUID,WHITE_Service_CBUUID])
                print("Central Manager Looking!!")
                
            default: break
            } // END switch
            
        }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
       _ = FriendlyAdvData(rawAdvData: advertisementData, rssi: RSSI, friendlyName: peripheral.name)
        //Use a flag for now
        //TODO: Build setup for storing cull corks in a table
        
        //let connectedPeripherals = centralManager?.retrieveConnectedPeripherals(withServices: [Weight_Scale_Service_CBUUID,RED_Service_CBUUID,GREEN_Service_CBUUID,BLACK_Service_CBUUID, YELLO_Service_CBUUID,WHITE_Service_CBUUID])
                // WILL [] RETURN ALL CONNECTED PERIPHERALS?
       // print("connectedPeripherals are \(String(describing: connectedPeripherals))")
        
        let reset_corks = 1
        
//>>>>>>>>>>>>>>>>>>>>>>>>> CORK 1 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    
        if peripheral.name == "RED"{
            print("Found the peripheral called RED")
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
            RED = peripheral
            RED?.delegate = self
            centralManager?.connect(RED!)
            decodePeripheralState(peripheralState: peripheral.state)
        }
    
//>>>>>>>>>>>>>>>>>>>>>>>>> CORK 2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        if peripheral.name == "GREEN"{
            print("Found the peripheral called GREEN")
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
            GREEN = peripheral
            GREEN?.delegate = self
            centralManager?.connect(GREEN!)
            decodePeripheralState(peripheralState: peripheral.state)
        }

//>>>>>>>>>>>>>>>>>>>>>>>>> CORK 3 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        if peripheral.name == "BLACK"{
            print("Found the peripheral called BLACK")
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
            BLACK = peripheral
            BLACK?.delegate = self
            centralManager?.connect(BLACK!)
            decodePeripheralState(peripheralState: peripheral.state)
        }

//>>>>>>>>>>>>>>>>>>>>>>>>> CORK 4 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

                if peripheral.name == "YELLO"{
                    print("Found the peripheral called YELLO")
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
                    YELLO = peripheral
                    YELLO?.delegate = self
                    centralManager?.connect(YELLO!)
                    decodePeripheralState(peripheralState: peripheral.state)
                }
        
        
//>>>>>>>>>>>>>>>>>>>>>>>>> CORK 5 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

                        if peripheral.name == "WHITE"{
                            print("Found the peripheral called WHITE")
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
                            WHITE = peripheral
                            WHITE?.delegate = self
                            centralManager?.connect(WHITE!)
                            decodePeripheralState(peripheralState: peripheral.state)
                        }

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
        if peripheral == RED {
            print("Did Connect....Looking for RED Service")
            RED?.discoverServices([RED_Service_CBUUID,RED_Battery_Service_CBUUID])
        }
        
        
        decodePeripheralState(peripheralState: peripheral.state)
        if peripheral == GREEN {
            print("Did Connect....Looking for GREEN Service")
            GREEN?.discoverServices([GREEN_Service_CBUUID,GREEN_Battery_Service_CBUUID])
        }
        
        
        decodePeripheralState(peripheralState: peripheral.state)
        if peripheral == BLACK {
            print("Did Connect....Looking for BLACK Service")
            BLACK?.discoverServices([BLACK_Service_CBUUID, BLACK_Battery_Service_CBUUID])
        }
        
        
        decodePeripheralState(peripheralState: peripheral.state)
        if peripheral == YELLO {
            print("Did Connect....Looking for YELLOW Service")
            YELLO?.discoverServices([YELLO_Service_CBUUID,YELLO_Battery_Service_CBUUID])
        }
        
        
        decodePeripheralState(peripheralState: peripheral.state)
        if peripheral == WHITE {
            print("Did Connect....Looking for WHITE Service")
            WHITE?.discoverServices([WHITE_Service_CBUUID,WHITE_Battery_Service_CBUUID])
        }
        
    } // END func centralManager(... didConnect peripheral
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        //print("Peripheral: \(peripheral)")
    
    for service in peripheral.services! {
        
        if service.uuid == Weight_Scale_Service_CBUUID {
            
            print("Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == RED_Service_CBUUID {
            
            print("Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == RED_Battery_Service_CBUUID {
            
            print("RED Battery Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == GREEN_Service_CBUUID {
            
            print("GREEN Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == GREEN_Battery_Service_CBUUID {
            
            print("GREEN Battery Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == BLACK_Service_CBUUID {
            
            print("Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == BLACK_Battery_Service_CBUUID {
            
            print("BLACK Battery Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == YELLO_Service_CBUUID {
            
            print("YELLO Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == YELLO_Battery_Service_CBUUID {
            
            print("YELLO Battery Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == WHITE_Service_CBUUID {
            
            print("Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        if service.uuid == WHITE_Battery_Service_CBUUID {
            
            print("WHITE Battery Service: \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
            
        }
        
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        DispatchQueue.main.async { () -> Void in
            self.connectionActivityStatus.backgroundColor = UIColor.black
            self.connectionActivityStatus.startAnimating()
        }
        
        centralManager?.scanForPeripherals(withServices: [Weight_Scale_Service_CBUUID,RED_Service_CBUUID,GREEN_Service_CBUUID,BLACK_Service_CBUUID, YELLO_Service_CBUUID,WHITE_Service_CBUUID])
        print("Peripheral disconnect.....Central Manager Looking!!")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        
        //print("Service didDiscoverChar: \(service)")
        
        for characteristic in service.characteristics! {
            
            print("Characteristic: \(characteristic)")
            
            if characteristic.uuid == Weight_Characteristic_CBUUID{
                print("Weight Data")
                WeightData = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                //peripheral.readValue(for: characteristic)
            }
            
            if characteristic.uuid == Tare_Characteristic_CBUUID{
                print("Tare Flag")
                self.TareFlag = characteristic
            }
            
            if characteristic.uuid == RED_FlashRGB_Characteristic_CBUUID{
                print("Flash RED RBG Flag")
                self.RED_FlashRGBFlag = characteristic
            }
            
            if characteristic.uuid == RED_Battery_Characteristic_CBUUID{
                print("RED Battery Info")
                REDBatteryInfo = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                //peripheral.readValue(for: characteristic)
            }
            
            if characteristic.uuid == GREEN_FlashRGB_Characteristic_CBUUID{
                print("Flash GREEN RBG Flag")
                self.GREEN_FlashRGBFlag = characteristic
            }
            
            if characteristic.uuid == GREEN_Battery_Characteristic_CBUUID{
                print("GREEN Battery Info")
                GREENBatteryInfo = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                //peripheral.readValue(for: characteristic)
            }
            
            if characteristic.uuid == BLACK_FlashRGB_Characteristic_CBUUID{
                print("Flash BLACK RBG Flag")
                self.BLACK_FlashRGBFlag = characteristic
            }
            
            if characteristic.uuid == BLACK_Battery_Characteristic_CBUUID{
                print("BLACK Battery Info")
                BLACKBatteryInfo = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                //peripheral.readValue(for: characteristic)
            }
            
            if characteristic.uuid == YELLO_FlashRGB_Characteristic_CBUUID{
                print("Flash YELLO RBG Flag")
                self.YELLO_FlashRGBFlag = characteristic
            }
            
            if characteristic.uuid == YELLO_Battery_Characteristic_CBUUID{
                print("YELLO Battery Info")
                YELLOBatteryInfo = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                //peripheral.readValue(for: characteristic)
            }
            
            if characteristic.uuid == WHITE_FlashRGB_Characteristic_CBUUID{
                print("Flash WHITE RBG Flag")
                self.WHITE_FlashRGBFlag = characteristic
            }
            
            if characteristic.uuid == WHITE_Battery_Characteristic_CBUUID{
                print("WHITE Battery Info")
                WHITEBatteryInfo = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                //peripheral.readValue(for: characteristic)
            }
        }
    } // END func peripheral(... didDiscoverCharacteristicsFor service
    
    //https://quickbirdstudios.com/blog/read-ble-characteristics-swift/
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        //print(characteristic)
        //print(peripheral)
     
        if characteristic.uuid == Weight_Characteristic_CBUUID {
            
            let weight = characteristic.value!
            print(String(data: weight, encoding: String.Encoding.ascii)!);
            
            DispatchQueue.main.async { () -> Void in
                self.weightDataLabel.text = String(data: weight, encoding: String.Encoding.ascii)

            } // END if characteristic for Weight
        }
        
        if  (GREEN?.name == "GREEN") && (characteristic.uuid == GREEN_Battery_Characteristic_CBUUID){
            
            //print("GREEN Battery:", characteristic.value![0])
            
            DispatchQueue.main.async { () -> Void in
                self.GREENBatteryInfoText.text = "\(characteristic.value![0])%"

            } // END if characteristic.uuid for GREEN Battery Info
        }
        
        
        if (YELLO?.name == "YELLO") && (characteristic.uuid == YELLO_Battery_Characteristic_CBUUID) {
            
            //print("YELLO Battery:", characteristic.value![0])
            
            DispatchQueue.main.async { () -> Void in
                self.YELLOBatteryInfoText.text = "\(characteristic.value![0])%"

            } // END if characteristic.uuid for YELLO Battery Info
        }
        
        if (RED?.name == "RED") && (characteristic.uuid == RED_Battery_Characteristic_CBUUID) {
            
            //print("RED Battery:", characteristic.value![0])
            
            DispatchQueue.main.async { () -> Void in
                self.REDBatteryInfoText.text = "\(characteristic.value![0])%"

            } // END if characteristic.uuid for RED Battery Info
        }
        
        if (BLACK?.name == "BLACK") && (characteristic.uuid == BLACK_Battery_Characteristic_CBUUID) {
            
            //print("BLACK Battery:", characteristic.value![0])
            
            DispatchQueue.main.async { () -> Void in
                self.BLACKBatteryInfoText.text = "\(characteristic.value![0])%"

            } // END if characteristic.uuid for BLACK Battery Info
        }
        
        if (WHITE?.name == "WHITE") && (characteristic.uuid == WHITE_Battery_Characteristic_CBUUID) {
            
            //print("WHITE Battery:", characteristic.value![0])
            
            DispatchQueue.main.async { () -> Void in
                self.WHITEBatteryInfoText.text = "\(characteristic.value![0])%"

            } // END if characteristic.uuid for WHITE Battery Info
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
            
        case "RED":
            
            let FlashState = flag
            let data = Data(FlashState.utf8)
            print("data = ", data)
            RED?.writeValue(data, for: RED_FlashRGBFlag!, type: .withoutResponse)
            
        case "GREEN":
            
            let FlashState = flag
            let data = Data(FlashState.utf8)
            print("data = ", data)
            GREEN?.writeValue(data, for: GREEN_FlashRGBFlag!, type: .withoutResponse)
            
        case "BLACK":
            
            let FlashState = flag
            let data = Data(FlashState.utf8)
            print("data = ", data)
            BLACK?.writeValue(data, for: BLACK_FlashRGBFlag!, type: .withoutResponse)
            
        case "YELLO":
            
            let FlashState = flag
            let data = Data(FlashState.utf8)
            print("data = ", data)
            YELLO?.writeValue(data, for: YELLO_FlashRGBFlag!, type: .withoutResponse)
        
        case "WHITE":
            
            let FlashState = flag
            let data = Data(FlashState.utf8)
            print("data = ", data)
            WHITE?.writeValue(data, for: WHITE_FlashRGBFlag!, type: .withoutResponse)
            
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
            request.fetchLimit = 5
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
                request.fetchLimit = 5         //CHANGE THIS BACK TO 5 WHEN YOU GET MORE TinyPICO
                self.items = try context.fetch(request)
                let minitem = self.items?.first!
                let minweight = minitem?.weight
                print("Min Weight : \(String(describing: minweight))")
                let Cork = minitem?.fish_ID  ?? "---"
                let alert = UIAlertController(title: "Cull \(Cork) @ \(minweight ?? 000)", message: "CullMaster Weight \(assign_capturedWeight)", preferredStyle: .alert)
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
            alert.addAction(UIAlertAction(title: "Dont Cull Fish", style: .default) { (alertAction) in
                self.sendFlashRGB(cork_to_flag: Cork, flag: "0")  // <-- Stop flashing the RGB on the Cork
            })
            self.present(alert, animated:true, completion: nil)
            
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
                    let alertController = UIAlertController(title: "Weight Captured \(capturedWeight ) ", message:"Cork \(Cork ?? "No Cork")", preferredStyle: .alert)
                    // add the actions (buttons)
                    alertController.addAction (UIAlertAction(title: "Cork Attached?", style: .default) { (alertAction) in
                    self.sendFlashRGB(cork_to_flag: Cork ?? "---", flag: "0")  // <-- Stop flashing the RGB on the Cork
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
                    })
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { (alertAction) in self.sendFlashRGB(cork_to_flag: Cork ?? "---", flag: "0")  })// <-- Stop flashing the RGB on the Cork
                    self.present(alertController, animated:true, completion: nil)
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

    
    @IBAction func resetCorks(_ sender: Any) {
        

        let entity =  NSEntityDescription.entity(forEntityName: "Cork_Table", in: context)!
        let updateRequest = NSBatchUpdateRequest(entity: entity)

        // only update one record or remove this line if you want to update all records
        //updateRequest.predicate = NSPredicate(format: "money < %i", 10000)

        // update the money to 10000, can add more attribute name and value to the hash if you want
        updateRequest.propertiesToUpdate = ["used" : 0]

        // return the number of updated objects for the result
        updateRequest.resultType = .updatedObjectsCountResultType

        do {
          let result = try context.execute(updateRequest) as! NSBatchUpdateResult
          print("\(result.result ?? 0) objects updated")
          
        } catch let error as NSError {
          print("Could not batch update. \(error), \(error.userInfo)")
        }
    }
    
    
    
    @IBAction func corkList(){
        guard let vc = storyboard!.instantiateViewController(withIdentifier: "Cork_VC_ID") as? CorkViewController else {
            return
        }
                present(vc, animated: true)
    }
    
    @IBAction func catchListView(){
        guard let vc = storyboard!.instantiateViewController(withIdentifier: "Battery_VC_ID") as? BatteryViewController else {
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
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textColor = UIColor.green
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        
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



