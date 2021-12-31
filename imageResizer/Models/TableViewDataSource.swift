//
//  TableView.swift
//  imageResizer
//
//  Created by JaredKozar on 12/30/21.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource {

    var tablePresets = [Preset]()
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tablePresets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let presetCell = tableView.dequeueReusableCell(withIdentifier: "PresetTableViewCell", for: indexPath) as? PresetTableViewCell else {
              fatalError("Unable to dequeue the preset cell.")
          }
        
        let preset = tablePresets[indexPath.row]
        presetCell.dimension.text = preset.dimension
        presetCell.layoutIfNeeded()
        return presetCell
    }
}
