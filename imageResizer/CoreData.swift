//
//  CoreData.swift
//  imageResizer
//
//  Created by JaredKozar on 12/31/21.
//

import UIKit
import CoreData

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
var fetchedResultsController: NSFetchedResultsController<Preset>!

func savePreset(dimension: String, uuid: String) {
  
    let newPreset = Preset(context: context)
    newPreset.dimension = dimension
    newPreset.isSelected = false
    newPreset.presetID = uuid
    
    do {
        try context.save()
    } catch {
        print("An error occured while saving the preset. \(error)")
    }
}

func fetchPresets() {
    let request = Preset.createFetchRequest()
    let sort = NSSortDescriptor(key: "dimension", ascending: false)
    request.sortDescriptors = [sort]

    do {
        presets = try context.fetch(request)
    } catch {
        print("Fetch failed")
    }
}

func deletePreset(preset: Preset) {
    context.delete(preset)
    
    do {
        try context.save()
    } catch {
        print("An error occured while saving the preset.")
    }
}
