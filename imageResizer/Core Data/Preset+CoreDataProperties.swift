//
//  Preset+CoreDataProperties.swift
//  imageResizer
//
//  Created by JaredKozar on 1/1/22.
//
//

import Foundation
import CoreData


extension Preset {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Preset> {
        return NSFetchRequest<Preset>(entityName: "Preset")
    }

    @NSManaged public var dimension: String?
    @NSManaged public var presetID: String?
    @NSManaged public var isSelected: Bool

}

extension Preset : Identifiable {

}
