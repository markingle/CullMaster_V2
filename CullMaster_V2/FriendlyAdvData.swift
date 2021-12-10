//
//  FriendlyAdvData.swift
//  CullMaster_V2
//
//  Created by Mark Brady Ingle on 9/18/21.
//
//

import Foundation
import CoreBluetooth

public struct FriendlyAdvData: CustomStringConvertible{
    public var connectable: Bool?
    public var manufacturerData: Data?
    public var overflowServiceUUIDs: [CBUUID]?
    public var serviceData: [CBUUID: NSData]?
    public var services: [CBUUID]?
    public var solicitedServiceUUIDs: [CBUUID]?
    public var transmitPowerLevel: NSNumber?
    public var localName: String?
    public var rssi: Int?
    public var timeStamp: Date?
    public var seen: Int = 0
    public var advIntervalEstimate: Double?
    public var company: String = ""
    
    public init(rawAdvData: [String : Any], rssi RSSI: NSNumber, friendlyName: String?) {
        //print("Raw \(rawAdvData)")
        let connectable             = rawAdvData["kCBAdvDataIsConnectable"] as? NSNumber
        self.connectable            = connectable == 1 ? true : false
        let manufacturerData        = rawAdvData["kCBAdvDataManufacturerData"] as? Data
        self.manufacturerData       = manufacturerData
        let overflowServiceUUIDs    = rawAdvData["kCBAdvDataOverflowServiceUUIDs"] as? [CBUUID]
        self.overflowServiceUUIDs   = overflowServiceUUIDs
        let serviceData             = rawAdvData["kCBAdvDataServiceData"] as? [CBUUID : NSData]
        self.serviceData            = serviceData
        let services                = rawAdvData["kCBAdvDataServiceUUIDs"] as? [CBUUID]
        self.services               = services
        let solicitedServiceUUIDs   = rawAdvData["kCBAdvDataSolicitedServiceUUIDs"] as? [CBUUID]
        self.solicitedServiceUUIDs  = solicitedServiceUUIDs
        let txPowerLevel            = rawAdvData["kCBAdvDataTxPowerLevel"] as? NSNumber
        self.transmitPowerLevel     = txPowerLevel
        let localName               = rawAdvData["kCBAdvDataLocalName"] as? String
        if let name = friendlyName {
            self.localName = name
        }
        else if let name = localName{
            self.localName = name
        }
        else{
            self.localName = "Unamed"
        }
        
        self.rssi = RSSI as? Int
        self.timeStamp = Date()
    }
    
    public var searchableString = ""
    
    public var description: String{
        let noValue = "NO VALUE"
        let connectablePrintValue           = self.connectable != nil ? "\(self.connectable!)" : noValue
        let manufacturerDataPrintValue      = self.manufacturerData != nil ? "\(self.manufacturerData!)" : noValue
        let overflowServiceUUIDsPrintValue  = self.overflowServiceUUIDs != nil ? "\(self.overflowServiceUUIDs!)" : noValue
        let serviceDataPrintValue           = self.serviceData != nil ? "\(self.serviceData!)" : noValue
        let servicesPrintValue              = self.services != nil ? "\(self.services!)" : noValue
        let solicitedServiceUUIDsPrintValue = self.solicitedServiceUUIDs != nil ? "\(self.solicitedServiceUUIDs!)" : noValue
        let transmitPowerLevelPrintValue    = self.transmitPowerLevel != nil ? "\(self.transmitPowerLevel!)" : noValue
        let localNamePrintValue             = self.localName != nil ? "\(self.localName!)" : noValue
        let rssiPrintValue                  = self.rssi != nil ? "\(self.rssi!)" : noValue
        let timeStampPrintValue             = self.timeStamp != nil ? "\(self.timeStamp!)" : noValue
        let advIntervalEstimatePrintValue   = self.advIntervalEstimate != nil ? "\(self.advIntervalEstimate!)" : noValue
        
        if let manData = self.manufacturerData{
            let hexString = getHexString(unFormattedData: manData as NSData)
            return """
            Conectable: \(connectablePrintValue)
            Manufacturer Data: \(hexString)
            Overflow Service UUIDs: \(overflowServiceUUIDsPrintValue)
            ServiceData: \(serviceDataPrintValue)
            Services: \(servicesPrintValue)
            Solicited Service UUIDs: \(solicitedServiceUUIDsPrintValue)
            Transmit Power Level: \(transmitPowerLevelPrintValue)
            Local Name: \(localNamePrintValue)
            RSSI: \(rssiPrintValue)
            Adv Estimate: \(advIntervalEstimatePrintValue)")
            """
        }
        
        return """
        Conectable: \(connectablePrintValue)
        Manufacturer Data: \(manufacturerDataPrintValue)
        Overflow Service UUIDs: \(overflowServiceUUIDsPrintValue)
        ServiceData: \(serviceDataPrintValue)
        Services: \(servicesPrintValue)
        Solicited Service UUIDs: \(solicitedServiceUUIDsPrintValue)
        Transmit Power Level: \(transmitPowerLevelPrintValue)
        Local Name: \(localNamePrintValue)
        RSSI: \(rssiPrintValue)
        Adv Estimate: \(advIntervalEstimatePrintValue)")
        \n
        """
    }
    
    func getHexString(unFormattedData: NSData) -> String{
        
        let data: Data? = unFormattedData as Data?
        
        var dataBytes = [UInt8](repeating: 0, count: data!.count)
        (data! as NSData).getBytes(&dataBytes, length: data!.count)
        
        var hexValue = ""
        for value in data!{
            let hex = String(value, radix: 16)
            hexValue = hexValue + "\(hex)"
        }
        
        return hexValue
    }
}

