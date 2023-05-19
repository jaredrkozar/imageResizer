//
//  AddPresetViewController.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/1/21.
//

import UIKit


class AddPresetViewController: UIViewController {

    lazy var heightField: CusstomTextField = {
        let textfield = CusstomTextField(frame: .zero)
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.addTarget(nil, action: #selector(checkText), for: .allEditingEvents)
        return textfield
    }()

    lazy var widthField: CusstomTextField = {
        let widthField = CusstomTextField(frame: .zero)
        widthField.translatesAutoresizingMaskIntoConstraints = false
        widthField.addTarget(nil, action: #selector(checkText), for: .allEditingEvents)
        return widthField
    }()
    
    lazy var widthText: UILabel = {
        let label = UILabel()
        label.text = "Width"
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var heightText: UILabel = {
        let label = UILabel()
        label.text = "Height"
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .regular)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var parentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var savePresetButton: StandardButton = {
        let button = StandardButton()
        button.setTitle("Save Preset", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(savePresetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var presetIndex: Int!
    
    let nc = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            savePresetButton.isHidden = false
        case .mac:
            savePresetButton.isHidden = true
        default:
            break
        }
        
        view.addSubview(savePresetButton)
        
        if presetIndex == nil {
            //disables the save preset button
            self.savePresetButton.isEnabled = false
            savePresetButton.alpha = 0.5;
            
            title = "Add Preset"
        } else {
            self.savePresetButton.isEnabled = true
            savePresetButton.alpha = 1.0;

            title = "Edit Preset"
            let splitDimension = presets[presetIndex].dimension?.getHeightWidth()
            widthField.text = "\(splitDimension!.0)"
            heightField.text = "\(splitDimension!.1)"
        }
    
        let heightStackView = UIStackView(arrangedSubviews: [heightText, heightField])
        heightStackView.axis = .horizontal
        heightStackView.distribution = .fill
        heightStackView.distribution = .fillEqually
        
        let widthStackView = UIStackView(arrangedSubviews: [widthText, widthField])
        widthStackView.axis = .horizontal
        widthStackView.distribution = .fill
        widthStackView.distribution = .fillEqually
        
        parentStackView.addArrangedSubview(heightStackView)
        parentStackView.addArrangedSubview(widthStackView)
        parentStackView.addArrangedSubview(savePresetButton)
        
        view.addSubview(parentStackView)
        
        NSLayoutConstraint.activate([
            heightField.heightAnchor.constraint(equalToConstant: 60),
            widthField.heightAnchor.constraint(equalToConstant: 60),
            
            savePresetButton.heightAnchor.constraint(equalToConstant: 40),
            
            parentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            parentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            parentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            parentStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])
    }
    
    @objc func checkText(_ sender: UITextField) {
        //if the height field or width fields are empty, the save preset button is disabled, but if both fields have text, they are enabled
 
        if heightField.text!.isEmpty || widthField.text!.isEmpty {
            savePresetButton.isEnabled = false
            savePresetButton.alpha = 0.5;
        } else {
            savePresetButton.isEnabled = true
            savePresetButton.alpha = 1.0;
        }
    }
    
    @objc func savePresetButtonTapped(_ sender: StandardButton) {
        //gets the text in the height and width field's UITextField, and  concatenate them together to get the dimension. This dimension is saved, where it's added to the table
    
        let dimension = "\(String(describing: heightField.text!)) x \(String(describing: widthField.text!))"

        if presetIndex == nil {
            savePreset(dimension: dimension)
        } else {
            updatePreset(index: presetIndex!, dimension: dimension)
        }
    
        NotificationCenter.default.post(name: Notification.Name( "addWidthHeighttoTable"), object: nil)
    
        switch UIDevice.current.userInterfaceIdiom {
        case .mac:
            
            if let session = self.view.window?.windowScene?.session {
              let options = UIWindowSceneDestructionRequestOptions()
              options.windowDismissalAnimation = .commit
              UIApplication.shared.requestSceneSessionDestruction(session, options: options, errorHandler: nil)
            }

            default:
                break
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}
