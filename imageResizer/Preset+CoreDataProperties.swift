//
//  Preset+CoreDataProperties.swift
//  imageResizer
//
//  Created by JaredKozar on 12/31/21.
//
//

import Foundation
import CoreData


extension Preset {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Preset> {
        return NSFetchRequest<Preset>(entityName: "Preset")
    }

    @NSManaged public var dimension: String?
    @NSManaged public var isSelected: Bool
    @NSManaged public var id: String?

}

extension Preset : Identifiable {

}
