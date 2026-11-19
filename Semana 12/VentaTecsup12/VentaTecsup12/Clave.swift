import Foundation
import CommonCrypto
import Security

enum Clave {
    private struct ErrorDerivacion: LocalizedError {
        var errorDescription: String? { "No se pudo proteger la contraseña." }
    }

    static func proteger(_ clave: String) throws -> String {
        var sal = Data(count: 16)
        let estado = sal.withUnsafeMutableBytes { buffer in
            SecRandomCopyBytes(kSecRandomDefault, buffer.count, buffer.baseAddress!)
        }
        guard estado == errSecSuccess else { throw ErrorDerivacion() }
        let hash = try derivar(clave, sal: sal)
        return sal.base64EncodedString() + "." + hash.base64EncodedString()
    }

    static func validar(_ clave: String, guardada: String) throws -> Bool {
        let partes = guardada.split(separator: ".")
        guard partes.count == 2, let sal = Data(base64Encoded: String(partes[0])),
              let esperado = Data(base64Encoded: String(partes[1])), sal.count == 16, esperado.count == 32 else { return false }
        let calculado = try derivar(clave, sal: sal)
        return zip(calculado, esperado).reduce(UInt8.zero) { $0 | ($1.0 ^ $1.1) } == 0
    }

    private static func derivar(_ clave: String, sal: Data) throws -> Data {
        let longitud = 32
        var hash = Data(count: longitud)
        let estado = hash.withUnsafeMutableBytes { salida in
            sal.withUnsafeBytes { entrada in
                CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2), clave, clave.utf8.count,
                    entrada.bindMemory(to: UInt8.self).baseAddress, sal.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), 210_000,
                    salida.bindMemory(to: UInt8.self).baseAddress, longitud)
            }
        }
        guard estado == kCCSuccess else { throw ErrorDerivacion() }
        return hash
    }
}
