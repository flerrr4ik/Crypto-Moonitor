//
//  SplashVС.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 03.07.2025.
//

import UIKit

class SplashViewController: UIViewController {

    private let moonLabel: UILabel = {
        let label = UILabel()
        label.text = "We are going\nto the Moon"
        label.font = UIFont(name: "Courier-Bold", size: 38)
        label.textColor = .white
        label.numberOfLines = 0
        label.alpha = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemIndigo
        setupGradientBackground()
        setupLabel()
        animateLabel()
    }

    private func setupLabel() {
        view.addSubview(moonLabel)
        NSLayoutConstraint.activate([
            moonLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moonLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        let softIndigo = UIColor(red: 0.7, green: 0.75, blue: 0.9, alpha: 1.0)
        let lightWhite = UIColor.white.withAlphaComponent(0.1)

        gradient.colors = [softIndigo.cgColor, lightWhite.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func animateLabel() {
        moonLabel.alpha = 1
        moonLabel.transform = .identity

        UIView.animate(
            withDuration: 1.0,
            delay: 0.8,
            options: [.curveEaseInOut],
            animations: {
                self.moonLabel.alpha = 0
                self.moonLabel.transform = CGAffineTransform(scaleX: 2.2, y: 2.2)
            },
            completion: { _ in
                self.showMainScreen()
            }
        )
    }

    private func showMainScreen() {
        let mainVC = MainListVC()
        let nav = UINavigationController(rootViewController: mainVC)
        nav.modalTransitionStyle = .crossDissolve
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
}
