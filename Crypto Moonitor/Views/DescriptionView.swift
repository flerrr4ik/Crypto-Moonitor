//
//  DescriptionViewController.swift
//  Crypto Tracker Lite
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import UIKit

class DescriptionView: UIViewController {
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.textColor = .label
        tv.backgroundColor = UIColor.systemGray6
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        tv.layer.cornerRadius = 16
        tv.layer.masksToBounds = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        
        return tv
    }()
    
    var text: String? {
        didSet {
            textView.text = text
        }
    }
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(textView)
        view.addSubview(closeButton)
        view.addSubview(titleLabel)
        
        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)

        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
 }

