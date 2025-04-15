//
//  SceneDelegate.swift
//  TestProject
//
//  Created by Полина Рыфтина on 12.04.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let network = Network()
        let service = Service(network: network)
        let presenter = Presenter(service: service)
        let viewController = ViewController(presenter: presenter)
        presenter.view = viewController
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
}
