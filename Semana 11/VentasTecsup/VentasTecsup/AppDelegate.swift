import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    private(set) lazy var repositorio: Result<RepositorioVentas, Error> = Result {
        try RepositorioVentas.abrir()
    }
}
