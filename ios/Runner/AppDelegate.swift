import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let audioEngine = AVAudioEngine()
  private let pitch = AVAudioUnitTimePitch()
  private let robot = AVAudioUnitDistortion()
  private var nodesAttached = false
  private var isRunning = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    let channel = FlutterMethodChannel(
      name: "realtime_voice/audio",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(FlutterError(code: "AUDIO", message: "Audio controller unavailable", details: nil))
        return
      }
      switch call.method {
      case "start":
        let effect = (call.arguments as? [String: Any])?["effect"] as? String ?? "baby"
        do {
          try self.start(effect: effect)
          result(nil)
        } catch {
          result(FlutterError(code: "START_FAILED", message: error.localizedDescription, details: nil))
        }
      case "setEffect":
        let effect = (call.arguments as? [String: Any])?["effect"] as? String ?? "baby"
        self.apply(effect: effect)
        result(nil)
      case "stop":
        self.stop()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func start(effect: String) throws {
    if isRunning {
      apply(effect: effect)
      return
    }

    let session = AVAudioSession.sharedInstance()
    try session.setCategory(
      .playAndRecord,
      mode: .voiceChat,
      options: [.defaultToSpeaker, .allowBluetooth]
    )
    try session.setActive(true)

    if !nodesAttached {
      let input = audioEngine.inputNode
      let format = input.outputFormat(forBus: 0)
      audioEngine.attach(pitch)
      audioEngine.attach(robot)
      robot.loadFactoryPreset(.speechWaves)
      audioEngine.connect(input, to: pitch, format: format)
      audioEngine.connect(pitch, to: robot, format: format)
      audioEngine.connect(robot, to: audioEngine.mainMixerNode, format: format)
      nodesAttached = true
    }

    apply(effect: effect)
    try audioEngine.start()
    isRunning = true
  }

  private func apply(effect: String) {
    switch effect {
    case "baby": pitch.pitch = 700; robot.wetDryMix = 0
    case "deep": pitch.pitch = -700; robot.wetDryMix = 0
    case "funny": pitch.pitch = 1200; robot.wetDryMix = 0
    case "robot": pitch.pitch = 0; robot.wetDryMix = 75
    default: pitch.pitch = 0; robot.wetDryMix = 0
    }
  }

  private func stop() {
    guard isRunning else { return }
    audioEngine.stop()
    audioEngine.reset()
    isRunning = false
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    stop()
    super.applicationWillTerminate(application)
  }
}
