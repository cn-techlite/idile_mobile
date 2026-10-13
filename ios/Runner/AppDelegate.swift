import Flutter
import Security
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    DeviceBindingChannel.register(with: engineBridge.applicationRegistrar.messenger())
  }
}

private final class DeviceBindingChannel {
  private static let channelName = "com.app.idile_mobile_app/device_binding"
  private static let keyTag = Data("com.app.idileMobileApp.device-binding.v1".utf8)

  static func register(with messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      do {
        switch call.method {
        case "getDeviceInfo":
          result(try deviceInfo())
        case "sign":
          guard
            let arguments = call.arguments as? [String: Any],
            let message = arguments["message"] as? String
          else {
            throw DeviceBindingError.invalidArguments
          }
          result(try sign(message))
        case "deleteKey":
          deleteKey()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      } catch {
        result(FlutterError(
          code: "DEVICE_BINDING",
          message: error.localizedDescription,
          details: nil
        ))
      }
    }
  }

  private static func deviceInfo() throws -> [String: Any] {
    let privateKey = try loadOrCreateKey()
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw DeviceBindingError.publicKeyUnavailable
    }
    var error: Unmanaged<CFError>?
    guard
      let representation = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?,
      representation.count == 65,
      representation.first == 0x04
    else {
      throw error?.takeRetainedValue() ?? DeviceBindingError.invalidPublicKey
    }
    let x = representation.subdata(in: 1..<33)
    let y = representation.subdata(in: 33..<65)
    return [
      "publicKey": [
        "kty": "EC",
        "crv": "P-256",
        "x": base64Url(x),
        "y": base64Url(y),
      ],
      "name": String(UIDevice.current.name.prefix(60)),
      "platform": "ios",
    ]
  }

  private static func sign(_ message: String) throws -> String {
    let key = try loadOrCreateKey()
    guard let data = message.data(using: .utf8) else {
      throw DeviceBindingError.invalidArguments
    }
    var error: Unmanaged<CFError>?
    guard let signature = SecKeyCreateSignature(
      key,
      .ecdsaSignatureMessageX962SHA256,
      data as CFData,
      &error
    ) as Data? else {
      throw error?.takeRetainedValue() ?? DeviceBindingError.signingFailed
    }
    return base64Url(try derToRaw(signature))
  }

  private static func loadOrCreateKey() throws -> SecKey {
    if let key = loadKey() { return key }

    var privateAttributes: [String: Any] = [
      kSecAttrIsPermanent as String: true,
      kSecAttrApplicationTag as String: keyTag,
    ]
    var attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: 256,
    ]

    #if targetEnvironment(simulator)
    privateAttributes[kSecAttrAccessible as String] =
      kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    #else
    var accessError: Unmanaged<CFError>?
    guard let access = SecAccessControlCreateWithFlags(
      nil,
      kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
      .privateKeyUsage,
      &accessError
    ) else {
      throw accessError?.takeRetainedValue() ?? DeviceBindingError.keyCreationFailed
    }
    attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
    privateAttributes[kSecAttrAccessControl as String] = access
    #endif

    attributes[kSecPrivateKeyAttrs as String] = privateAttributes
    var error: Unmanaged<CFError>?
    guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
      throw error?.takeRetainedValue() ?? DeviceBindingError.keyCreationFailed
    }
    return key
  }

  private static func loadKey() -> SecKey? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrApplicationTag as String: keyTag,
      kSecReturnRef as String: true,
    ]
    var item: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess else {
      return nil
    }
    return (item as! SecKey)
  }

  private static func deleteKey() {
    let query: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: keyTag,
    ]
    SecItemDelete(query as CFDictionary)
  }

  private static func derToRaw(_ der: Data) throws -> Data {
    let bytes = [UInt8](der)
    var offset = 0
    guard readByte(bytes, &offset) == 0x30 else { throw DeviceBindingError.invalidSignature }
    let sequenceLength = try readLength(bytes, &offset)
    guard sequenceLength == bytes.count - offset else { throw DeviceBindingError.invalidSignature }
    guard readByte(bytes, &offset) == 0x02 else { throw DeviceBindingError.invalidSignature }
    let rLength = try readLength(bytes, &offset)
    guard offset + rLength <= bytes.count else { throw DeviceBindingError.invalidSignature }
    let r = Array(bytes[offset..<(offset + rLength)])
    offset += rLength
    guard readByte(bytes, &offset) == 0x02 else { throw DeviceBindingError.invalidSignature }
    let sLength = try readLength(bytes, &offset)
    guard offset + sLength == bytes.count else { throw DeviceBindingError.invalidSignature }
    let s = Array(bytes[offset..<(offset + sLength)])
    return Data(try unsigned32(r) + unsigned32(s))
  }

  private static func readByte(_ bytes: [UInt8], _ offset: inout Int) -> UInt8? {
    guard offset < bytes.count else { return nil }
    defer { offset += 1 }
    return bytes[offset]
  }

  private static func readLength(_ bytes: [UInt8], _ offset: inout Int) throws -> Int {
    guard let first = readByte(bytes, &offset) else { throw DeviceBindingError.invalidSignature }
    if first < 0x80 { return Int(first) }
    let count = Int(first & 0x7f)
    guard count == 1 || count == 2 else { throw DeviceBindingError.invalidSignature }
    var length = 0
    for _ in 0..<count {
      guard let byte = readByte(bytes, &offset) else { throw DeviceBindingError.invalidSignature }
      length = (length << 8) | Int(byte)
    }
    return length
  }

  private static func unsigned32(_ integer: [UInt8]) throws -> [UInt8] {
    var value = integer
    while value.count > 32 && value.first == 0 { value.removeFirst() }
    guard value.count <= 32 else { throw DeviceBindingError.invalidSignature }
    return Array(repeating: 0, count: 32 - value.count) + value
  }

  private static func base64Url(_ data: Data) -> String {
    data.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}

private enum DeviceBindingError: LocalizedError {
  case invalidArguments
  case keyCreationFailed
  case publicKeyUnavailable
  case invalidPublicKey
  case signingFailed
  case invalidSignature

  var errorDescription: String? {
    switch self {
    case .invalidArguments: return "A valid message is required."
    case .keyCreationFailed: return "The protected device key could not be created."
    case .publicKeyUnavailable: return "The device public key is unavailable."
    case .invalidPublicKey: return "The device public key is invalid."
    case .signingFailed: return "The device could not sign the challenge."
    case .invalidSignature: return "The device returned an invalid signature."
    }
  }
}
