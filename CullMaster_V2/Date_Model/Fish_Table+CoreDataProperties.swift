//
//  Fish_Table+CoreDataProperties.swift
//  CullMaster_V2
//
//  Created by Mark Brady Ingle on 9/25/21.
//
//

import Foundation
import CoreData


extension Fish_Table {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Fish_Table> {
        return NSFetchRequest<Fish_Table>(entityName: "Fish_Table")
    }

    @NSManaged public var date: Date?
    @NSManaged public var fish_ID: String?
    @NSManaged public var weight: NSDecimalNumber?

}

extension Fish_Table : Identifiable {

}
