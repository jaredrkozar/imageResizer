//
//  TableViewDataSource.swift
//  imageResizer
//
//  Created by Jared Kozar on 9/8/22.
//


import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource {

    var tablePresets = [Preset]()
    
    lazy var noPresetsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .label
        label.text = "You don't have any presets currently added. Add a preset by tapping the button above."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tablePresets.count == 0 {
            noPresetsLabel.isHidden = false
        } else {
            noPresetsLabel.isHidden = true
        }
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
