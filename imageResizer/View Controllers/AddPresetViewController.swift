//
//  AddPresetViewController.swift
//  imageResizer
//
//  Created by Jared Kozar on 6/1/21.
//

import UIKit


class AddPresetViewController: UIViewController {

    lazy var heightField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.layer.backgroundColor = UIColor.systemGray4.cgColor
        textfield.layer.cornerRadius = 15.0
        textfield.addTarget(nil, action: #selector(checkText), for: .allEditingEvents)
        return textfield
    }()

    var widthField: UITextField = {
        let width = UITextField()
        
        width.translatesAutoresizingMaskIntoConstraints = false
        width.layer.backgroundColor = UIColor.systemGray4.cgColor
        width.layer.cornerRadius = 15.0
        width.translatesAutoresizingMaskIntoConstraints = false
        width.addTarget(nil, action: #selector(checkText), for: .allEditingEvents)
        return width
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
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    lazy var savePresetButton: StandardButton = {
        let button = StandardButton()
        button.setTitle("Save Preset", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(savePresetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    var currentHeight: String?
    var currentWidth: String?
    
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
        
        if isEditingDimension == false {
            //disables the save preset button
            self.savePresetButton.isEnabled = false
            savePresetButton.alpha = 0.5;
            
            title = "Add Preset"
        } else {
            self.savePresetButton.isEnabled = true
            savePresetButton.alpha = 1.0;
            widthField.text = currentWidth
            heightField.text = currentHeight
            
            title = "Edit Preset"
        }
    
        let textStackView = UIStackView(arrangedSubviews: [heightText, widthText])
        textStackView.axis = .vertical
        textStackView.distribution = .fill
        textStackView.distribution = .fillEqually
        
        let heightStackView = UIStackView(arrangedSubviews: [heightField, widthField])
        heightStackView.axis = .vertical
        heightStackView.distribution = .fill
        heightStackView.distribution = .fillEqually
        heightStackView.spacing = 9.0
        
        horizontalStackView.addArrangedSubview(textStackView)
        horizontalStackView.addArrangedSubview(heightStackView)
        parentStackView.addArrangedSubview(horizontalStackView)
        parentStackView.addArrangedSubview(savePresetButton)
        
        view.addSubview(parentStackView)
        
        
        NSLayoutConstraint.activate([
            heightField.widthAnchor.constraint(equalToConstant: 80),
            widthField.widthAnchor.constraint(equalToConstant: 80),
            heightField.heightAnchor.constraint(equalToConstant: 80),
            widthField.heightAnchor.constraint(equalToConstant: 80),
            
            savePresetButton.topAnchor.constraint(equalTo: widthField.bottomAnchor, constant: 10),
            savePresetButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
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
        
        let width = widthField.text!
        let height = heightField.text!
    
        let dimension = "\(height) x \(width)"
    
        UserDefaults.standard.set(dimension, forKey: "dimension")
        
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
