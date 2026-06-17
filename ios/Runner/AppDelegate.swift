import Flutter
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, UIDocumentPickerDelegate {
  private var exportDirectoryResult: FlutterResult?
  private var scopedExportDirectoryURL: URL?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let didFinish = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.limonnyemalchiki.mycharacterlist/export_directory",
        binaryMessenger: controller.binaryMessenger
      )

      channel.setMethodCallHandler { [weak self] call, result in
        guard let self = self else {
          return
        }

        switch call.method {
        case "pickDirectory":
          self.pickExportDirectory(from: controller, result: result)
        case "stopAccessingDirectory":
          self.stopExportDirectoryAccess()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return didFinish
  }

  private func pickExportDirectory(
    from controller: UIViewController,
    result: @escaping FlutterResult
  ) {
    exportDirectoryResult = result

    let picker: UIDocumentPickerViewController
    if #available(iOS 14.0, *) {
      picker = UIDocumentPickerViewController(
        forOpeningContentTypes: [UTType.folder],
        asCopy: false
      )
    } else {
      picker = UIDocumentPickerViewController(
        documentTypes: ["public.folder"],
        in: .open
      )
    }

    picker.delegate = self
    picker.allowsMultipleSelection = false
    controller.present(picker, animated: true)
  }

  private func stopExportDirectoryAccess() {
    scopedExportDirectoryURL?.stopAccessingSecurityScopedResource()
    scopedExportDirectoryURL = nil
  }

  func documentPicker(
    _ controller: UIDocumentPickerViewController,
    didPickDocumentsAt urls: [URL]
  ) {
    controller.dismiss(animated: true)

    guard let url = urls.first else {
      exportDirectoryResult?(nil)
      exportDirectoryResult = nil
      return
    }

    stopExportDirectoryAccess()
    scopedExportDirectoryURL = url

    guard url.startAccessingSecurityScopedResource() else {
      exportDirectoryResult?(
        FlutterError(
          code: "ACCESS_DENIED",
          message: "Could not access the selected folder.",
          details: nil
        )
      )
      exportDirectoryResult = nil
      scopedExportDirectoryURL = nil
      return
    }

    exportDirectoryResult?(url.path)
    exportDirectoryResult = nil
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    exportDirectoryResult?(nil)
    exportDirectoryResult = nil
  }
}
