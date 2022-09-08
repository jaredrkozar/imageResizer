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
    
    func tableView(_ presetCellsView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Presets"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let preset = tablePresets[indexPath.row]
        cell.textLabel!.text = preset.dimension
        cell.layoutIfNeeded()
        return cell
    }
}
