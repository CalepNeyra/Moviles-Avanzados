import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var almacen = Result { try RepositorioVentas() }

    func application(_ application: UIApplication, configurationForConnecting session: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: session.role)
    }
}
