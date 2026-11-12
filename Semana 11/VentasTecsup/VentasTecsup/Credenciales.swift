import CommonCrypto
import Foundation
import Security

enum Credenciales {
    private static let iteraciones: UInt32 = 600_000
    private static let longitudSal = 16
    private static let longitudHash = 32

    static func codificar(_ clave: String) throws -> String {
        var sal = Data(count: longitudSal)
        let estado = sal.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
            SecRandomCopyBytes(kSecRandomDefault, buffer.count, buffer.baseAddress!)
        }
        guard estado == errSecSuccess else { throw ErrorVentas.claveNoProcesada }

        let hash = try derivar(clave, sal: sal)
        return [sal.base64EncodedString(), hash.base64EncodedString()].joined(separator: "$")
    }

    static func verifica(_ clave: String, contra registro: String) throws -> Bool {
        let partes = registro.split(separator: "$")
        guard partes.count == 2,
              let sal = Data(base64Encoded: String(partes[0])), sal.count == longitudSal,
              let esperado = Data(base64Encoded: String(partes[1])), esperado.count == longitudHash else {
            return false
        }

        let actual = try derivar(clave, sal: sal)
        return zip(actual, esperado).reduce(UInt8(0)) { $0 | ($1.0 ^ $1.1) } == 0
    }

    private static func derivar(_ clave: String, sal: Data) throws -> Data {
        let bytesClave = clave.utf8CString
        var hash = Data(count: longitudHash)
        let estado = bytesClave.withUnsafeBufferPointer { claveBuffer in
            sal.withUnsafeBytes { salBuffer in
                hash.withUnsafeMutableBytes { hashBuffer in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        claveBuffer.baseAddress, claveBuffer.count - 1,
                        salBuffer.bindMemory(to: UInt8.self).baseAddress, salBuffer.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256), iteraciones,
                        hashBuffer.bindMemory(to: UInt8.self).baseAddress, hashBuffer.count
                    )
                }
            }
        }
        guard estado == kCCSuccess else { throw ErrorVentas.claveNoProcesada }
        return hash
    }
}
