//
//  SceneDelegate.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 28.09.22.
//

import UIKit
import Photos

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        registerServices()

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let viewController = obtainRootController()
            window.rootViewController = viewController
            self.window = window
            window.makeKeyAndVisible()
        }
                
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    private func obtainRootController() -> UIViewController {
        let viewController = PhotosCollectionViewController()
        let presenter = PhotosCollectionPresenter(
            photosService: DIContainer.shared.resolve(type: PhotosServiceProtocol.self)!,
            eventsDelegateHandler: DIContainer.shared.resolve(type: EventsProxy.self)!
        )
        presenter.delegate = viewController
        viewController.presenter = presenter
        let navigationController = UINavigationController(rootViewController: viewController)
        
        return navigationController
    }
    
    private func registerServices() {
        let containter = DIContainer.shared
        containter.register(type: EventsProxy.self, component: EventsProxyImp())
        containter.register(type: PhotosServiceProtocol.self, component: PhotosService(
            maxNumberOfPhotos: Constants.maxNumberOfPhotos,
            imageCachingManager: PHCachingImageManager(),
            eventsActionHandler: containter.resolve(type: EventsProxy.self)!)
        )
        containter.register(type: SaliencyServiceProtocol.self, component: SaliencyService())
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

