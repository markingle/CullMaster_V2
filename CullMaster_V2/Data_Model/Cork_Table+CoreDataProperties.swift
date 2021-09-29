//
//  Cork_Table+CoreDataProperties.swift
//  CullMaster_V2
//
//  Created by Mark Brady Ingle on 9/26/21.
//
//

import Foundation
import CoreData


extension Cork_Table {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cork_Table> {
        return NSFetchRequest<Cork_Table>(entityName: "Cork_Table")
    }

    @NSManaged public var name: String?
    @NSManaged public var mAC: String?
    @NSManaged public var used: Int64

}

extension Cork_Table : Identifiable {

}
