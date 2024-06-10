/* ----------------------------------------------------------------
 * :: :  V  U  L  K  A  N  :                                     ::
 * ----------------------------------------------------------------
 * This software is Licensed under the terms of the Apache License,
 * version 2.0 (the "Apache License") with the following additional
 * modification; you may not use this file except within compliance
 * of the Apache License and the following modification made to it.
 * Section 6. Trademarks. is deleted and replaced with:
 *
 * Trademarks. This License does not grant permission to use any of
 * its trade names, trademarks, service marks, or the product names
 * of this Licensor or its affiliates, except as required to comply
 * with Section 4(c.) of this License, and to reproduce the content
 * of the NOTICE file.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND without even an
 * implied warranty of MERCHANTABILITY, or FITNESS FOR A PARTICULAR
 * PURPOSE. See the Apache License for more details.
 *
 * You should have received a copy for this software license of the
 * Apache License along with this program; or, if not, please write
 * to the Free Software Foundation Inc., with the following address
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *         Copyright (C) 2024 Wabi Foundation. All Rights Reserved.
 * ----------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * ---------------------------------------------------------------- */

import AppKit
import CxxStdlib
import Foundation
import glm
import simd
import vulkan

public extension Vulkan
{
  class Camera
  {
    public var position: SIMD3<Float> = .init(0.0, 0.0, 0.0)
    public var rotation: SIMD3<Float> = .init(0.0, 0.0, 0.0)
    public var rotationSpeed: Float = 0.25
    public var movementSpeed: Float = 1.0
    public var keys: Keys = .init()

    public struct Keys
    {
      public var left = false
      public var right = false
      public var up = false
      public var down = false
    }

    public init()
    {}

    public func translate(_ delta: SIMD3<Float>)
    {
      position += delta
    }

    public func rotate(_ delta: SIMD3<Float>)
    {
      rotation += delta
    }

    public func update(_ delta: Float)
    {
      if keys.up
      {
        translate(SIMD3<Float>(0.0, 0.0, -movementSpeed * delta))
      }
      if keys.down
      {
        translate(SIMD3<Float>(0.0, 0.0, movementSpeed * delta))
      }
      if keys.left
      {
        translate(SIMD3<Float>(-movementSpeed * delta, 0.0, 0.0))
      }
      if keys.right
      {
        translate(SIMD3<Float>(movementSpeed * delta, 0.0, 0.0))
      }
    }

    public func moving() -> Bool
    {
      keys.up || keys.down || keys.left || keys.right
    }
  }

  class UI
  {
    public var visible: Bool = true
    public var updated: Bool = true

    public init()
    {}
  }

  class GI
  {
    public var title = "Vulkan Graphics Interface"
    public var name = "vulkan.gi"

    public var prepared: Bool = false
    public var resized: Bool = false
    public var viewUpdated: Bool = false
    public var width: Int = 1920
    public var height: Int = 1080

    public var frameTimer: Float = 1.0

    public var vulkanDevice: Vulkan.Device?

    public var view: View?
    public var metalLayer: CAMetalLayer?

    public var settings: Settings = .init()
    public var mouseState = MouseState()
    public var ui: Vulkan.UI = .init()
    public var camera: Vulkan.Camera = .init()

    private var frameCounter: Int = 0
    private var lastFPS: Int = 0
    private var lastTimestamp = std.chrono.steady_clock.time_point()
    private var tPrevEnd = std.chrono.steady_clock.time_point()

    /// For use in animations, rotations, etc.
    private var timer: Float = 0.0
    /// Multiplier for speeding up (or slowing down) the global timer
    private var timerSpeed: Float = 0.25

    private var instance: VkInstance?
    private var supportedExtensions: [String] = []

    private var physicalDevice: VkPhysicalDevice?
    private var deviceProperties: VkPhysicalDeviceProperties = .init()
    private var deviceFeatures: VkPhysicalDeviceFeatures = .init()
    private var deviceMemoryProperties: VkPhysicalDeviceMemoryProperties = .init()
    private var enabledFeatures: VkPhysicalDeviceFeatures = .init()

    private var instanceExtensions: [String] = []
    private var enabledInstanceExtensions: [String] = []
    private var enabledDeviceExtensions: [String] = []

    // TODO: make these private
    public var device: VkDevice?
    public var queue: VkQueue?

    private var depthFormat: VkFormat = VK_FORMAT_UNDEFINED
    private var cmdPool: VkCommandPool?

    private var submitPipelineStages: VkPipelineStageFlags = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue
    private var submitInfo: VkSubmitInfo = .init()

    private var drawCmdBuffers: [VkCommandBuffer] = []
    private var renderPass: VkRenderPass?
    private var framebuffers: [VkFramebuffer] = []
    private var currentBuffer: Int = 0

    private var descriptorPool: VkDescriptorPool?
    private var shaderModules: [VkShaderModule] = []
    private var pipelineCache: VkPipelineCache?

    private var swapchain: VkSwapchainKHR?

    private struct Semaphores
    {
      var presentComplete: VkSemaphore?
      var renderComplete: VkSemaphore?
    }

    private var waitFences: [VkFence] = []

    private var requiresStencil: Bool = false

    public var paused: Bool = false
    public var quit: Bool = false

    public init()
    {}

    public func createInstance() -> VkResult
    {
      enabledInstanceExtensions.append(VK_EXT_DEBUG_UTILS_EXTENSION_NAME)
      // enabledInstanceExtensions.append(VK_KHR_SURFACE_EXTENSION_NAME)
      #if os(macOS)
        /* macOS specific extensions. */
        enabledInstanceExtensions.append(VK_EXT_METAL_SURFACE_EXTENSION_NAME)
        enabledInstanceExtensions.append(VK_MVK_MACOS_SURFACE_EXTENSION_NAME)
      #endif /* os(macOS) */
      enabledInstanceExtensions.append(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME)
      enabledInstanceExtensions.append(VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME)

      // Get extensions supported by the instance and store for later use
      var extCount: UInt32 = 0
      vkEnumerateInstanceExtensionProperties(nil, &extCount, nil)
      if extCount > 0
      {
        let extensions = UnsafeMutablePointer<VkExtensionProperties>.allocate(capacity: Int(extCount))

        print("")
        print("available vulkan extensions:")
        if vkEnumerateInstanceExtensionProperties(nil, &extCount, &extensions.pointee) == VK_SUCCESS
        {
          for extIdx in 0 ..< extCount
          {
            let extName = withUnsafePointer(to: &extensions.advanced(by: Int(extIdx)).pointee.extensionName)
            {
              $0.withMemoryRebound(to: CChar.self, capacity: 256)
              {
                String(cString: $0)
              }
            }
            print("extension [\(extIdx + 1) of \(extCount)]: \(extName)")
            supportedExtensions.append(extName)
          }
        }
      }

      // Enabled requested instance extensions
      if !enabledInstanceExtensions.isEmpty
      {
        for enabledExtension in enabledInstanceExtensions
        {
          // output message if requested extension is not available.
          if !supportedExtensions.contains(enabledExtension)
          {
            fatalError("Enabled instance extension \(enabledExtension) is not present at instance level.")
          }
          instanceExtensions.append(enabledExtension)
        }
      }

      var appInfo = VkApplicationInfo()
      let appName = withUnsafePointer(to: &name)
      {
        $0.withMemoryRebound(to: CChar.self, capacity: 256)
        {
          $0
        }
      }
      appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO
      appInfo.pApplicationName = appName
      appInfo.pEngineName = appName
      appInfo.apiVersion = vkApiVersion1_0()

      let extensions = UnsafeMutablePointer<UnsafePointer<CChar>?>.allocate(capacity: instanceExtensions.count)
      for (idx, ext) in instanceExtensions.enumerated()
      {
        extensions.advanced(by: idx).pointee = ext.withCString { $0 }
      }
      #if DEBUG_VULKAN_EXTENSIONS
        for (idx, _) in instanceExtensions.enumerated()
        {
          print("got ext:", String(cString: extensions.advanced(by: idx).pointee!))
        }
      #endif // DEBUG_VULKAN_EXTENSIONS

      let result = createAppInfo(
        with: &appInfo,
        extensions: &extensions.pointee,
        extensionsCount: instanceExtensions.count
      )

      return result
    }

    @discardableResult
    public func initVulkan() -> Bool
    {
      // Create the instance
      var result = createInstance()
      if result != VK_SUCCESS
      {
        print("")
        Vulkan.Tools.errorString(result)
        return false
      }
      else
      {
        print("")
        print("success: vulkan instance created.")
      }

      // Physical device (number of available physical devices).
      var gpuCount: UInt32 = 0
      VK_CHECK_RESULT(vkEnumeratePhysicalDevices(instance, &gpuCount, nil))
      if gpuCount == 0
      {
        Vulkan.Tools.exitFatal("No device with Vulkan support found.")
        return false
      }

      // Enumerate devices.
      var physicalDevices = [VkPhysicalDevice?](repeating: VkPhysicalDevice(bitPattern: 0), count: Int(gpuCount))
      result = vkEnumeratePhysicalDevices(instance, &gpuCount, &physicalDevices)
      if result != VK_SUCCESS
      {
        Vulkan.Tools.exitFatal("Could not enumerate physical devices: \(result.rawValue).")
        return false
      }

      // GPU selection.
      let selectedDevice: UInt32 = 0
      print("")
      print("available vulkan devices:")
      for i in 0 ..< gpuCount
      {
        let deviceProperties = UnsafeMutablePointer<VkPhysicalDeviceProperties>.allocate(capacity: 1)
        vkGetPhysicalDeviceProperties(physicalDevices[Int(i)], deviceProperties)
        let deviceName = withUnsafePointer(to: &deviceProperties.pointee.deviceName)
        {
          $0.withMemoryRebound(to: CChar.self, capacity: 256)
          {
            String(cString: $0)
          }
        }
        print("device [\(i + 1) of \(gpuCount)]:", deviceName)
        switch deviceProperties.pointee.deviceType
        {
          case VK_PHYSICAL_DEVICE_TYPE_OTHER:
            print("type: other")
          case VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU:
            print("type: integrated gpu")
          case VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU:
            print("type: discrete gpu")
          case VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU:
            print("type: virtual gpu")
          case VK_PHYSICAL_DEVICE_TYPE_CPU:
            print("type: cpu")
          default:
            print("type: unknown")
        }

        let v = deviceProperties.pointee.apiVersion
        print("api:", Vulkan.Version.makeVersion(from: v))
      }

      guard let foundDevice = physicalDevices[Int(selectedDevice)]
      else
      {
        Vulkan.Tools.exitFatal("Could not find a device that supports Vulkan.")
        return false
      }

      physicalDevice = foundDevice

      return true
    }

    public func keyPressed(_: UInt16)
    {}

    public func mouseDragged(x: CGFloat, y: CGFloat)
    {
      let dx = mouseState.position.x - Float(x);
      let dy = mouseState.position.y - Float(y);

      let handled = false

      if (settings.overlay) {
        // ImGuiIO& io = ImGui::GetIO();
        // handled = io.WantCaptureMouse && ui.visible;
      }

      if (handled) {
        mouseState.position = SIMD2<Float>(Float(x), Float(y));
        return;
      }

      if (mouseState.buttons.left) {
        camera.rotate(SIMD3<Float>(dy * camera.rotationSpeed, -dx * camera.rotationSpeed, 0.0))
        viewUpdated = true
      }
      if (mouseState.buttons.right) {
        camera.translate(SIMD3<Float>(-0.0, 0.0, dy * 0.005))
        viewUpdated = true
      }
      if (mouseState.buttons.middle) {
        camera.translate(SIMD3<Float>(-dx * 0.005, -dy * 0.005, 0.0))
        viewUpdated = true
      }
      mouseState.position = SIMD2<Float>(Float(x), Float(y))
    }
  }
}

extension Vulkan.GI
{
  private func createAppInfo(
    with appInfo: UnsafePointer<VkApplicationInfo>,
    extensions: UnsafePointer<UnsafePointer<CChar>?>,
    extensionsCount: Int
  ) -> VkResult
  {
    var createApp = VkInstanceCreateInfo()

    createApp.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO
    createApp.pApplicationInfo = appInfo
    createApp.flags = VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR.rawValue

    createApp.enabledExtensionCount = UInt32(extensionsCount)
    createApp.ppEnabledExtensionNames = extensions

    return vkCreateInstance(&createApp, nil, &instance)
  }
}

public extension Vulkan.GI
{
	struct Settings 
  {
		/** activates validation layers (and message output) when set to true. */
		public var validation: Bool = false
		/** set to true if fullscreen mode has been requested via command line. */
		public var fullscreen: Bool = false
		/** set to true if v-sync will be forced for the swapchain. */
		public var vsync: Bool = false
		/** enable UI overlay. */
		public var overlay: Bool = true
	}

  struct MouseState
  {
    public struct Buttons
    {
      public var left: Bool = false
      public var right: Bool = false
      public var middle: Bool = false
    }

    public var buttons: Buttons = .init()
    public var position: SIMD2<Float> = .init(0.0, 0.0)
  }
}

public extension Vulkan.GI
{
  func displayLinkOutputCb()
  {
    #if WITH_BENCHMARKS
      if benchmark.active
      {
        benchmark.run({ render() }, vulkanDevice.properties)
        if !benchmark.filename.isEmpty
        {
          benchmark.saveResults()
        }
        quit = true
        return
      }
    #endif /* WITH_BENCHMARKS */

    if prepared
    {
      nextFrame()
    }
  }
}

public extension Vulkan.GI
{
  func nextFrame()
  {
    if viewUpdated
    {
      viewUpdated = false
    }

    // render()
    frameCounter += 1
    let tEnd = std.chrono.high_resolution_clock.now()
    #if os(macOS)
      let tDiff = Float(wabi.std.duration(tEnd - tPrevEnd).count())
    #endif
    frameTimer = tDiff / 1000.0
    camera.update(frameTimer)
    if camera.moving()
    {
      viewUpdated = true
    }
    // convert to clamped timer value
    if !paused
    {
      timer += timerSpeed * frameTimer
      if timer > 1.0
      {
        timer -= 1.0
      }
    }
    let fpsTimer = Float(wabi.std.duration(tEnd - lastTimestamp).count())
    if fpsTimer > 1000.0
    {
      lastFPS = frameCounter * Int(Float(1000.0) / fpsTimer)
      frameCounter = 0
      lastTimestamp = tEnd
    }
    tPrevEnd = tEnd

    // updateOverlay()
  }
}

class AppDelegate: NSObject, NSApplicationDelegate
{
  var vgi: Vulkan.GI = .init()
  var concurrentGroup: DispatchGroup = .init()

  func applicationDidFinishLaunching(_: Notification)
  {
    NSApp.activate(ignoringOtherApps: true)

    concurrentGroup = DispatchGroup()
    DispatchQueue.global(qos: .userInteractive).async(group: concurrentGroup)
    {
      while !self.vgi.quit
      {
        self.vgi.displayLinkOutputCb()
      }
    }

    #if WITH_BENCHMARKS
      if vgi.benchmark.active
      {
        let notifyQueue = DispatchQueue.main
        DispatchGroup().notify(queue: notifyQueue)
        {
          NSApp.terminate(nil)
        }
      }
    #endif /* WITH_BENCHMARKS */
  }

  func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool
  {
    true
  }

  func applicationWillTerminate(_: Notification)
  {
    vgi.quit = true
    concurrentGroup.wait()
    if let device = vgi.vulkanDevice?.logicalDevice
    {
      vkDeviceWaitIdle(device)
    }
    // delete(vgi)
  }
}

public class View: NSView, NSWindowDelegate
{
  var vgi: Vulkan.GI = .init()
  var displayLink: CVDisplayLink?

  override init(frame: NSRect)
  {
    super.init(frame: frame)
    wantsLayer = true
    layer = CAMetalLayer()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder)
  {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidMoveToWindow()
  {
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
    if let displayLink
    {
      CVDisplayLinkStart(displayLink)
    }
  }

  public override var acceptsFirstResponder: Bool
  {
    true
  }

  public override func acceptsFirstMouse(for _: NSEvent?) -> Bool
  {
    true
  }

  func keyDown(event: NSEvent)
  {
    switch event.characters
    {
      case "p":
        vgi.paused = !vgi.paused
      case "1", "f1":
        vgi.ui.visible = !vgi.ui.visible
        vgi.ui.updated = true
      case "delete", "escape":
        NSApp.terminate(nil)
      case "w":
        vgi.camera.keys.up = true
      case "s":
        vgi.camera.keys.down = true
      case "a":
        vgi.camera.keys.left = true
      case "d":
        vgi.camera.keys.right = true
      default:
        vgi.keyPressed(event.keyCode)
    }
  }

  func keyUp(event: NSEvent)
  {
    switch event.characters
    {
      case "w":
        vgi.camera.keys.up = false
      case "s":
        vgi.camera.keys.down = false
      case "a":
        vgi.camera.keys.left = false
      case "d":
        vgi.camera.keys.right = false
      default:
        break
    }
  }

  func getMouseLocalPoint(event: NSEvent) -> NSPoint
  {
    let location = event.locationInWindow
    var point: NSPoint = convert(location, from: nil)
    point.y = frame.size.height - point.y
    return point
  }

  func mouseDown(event: NSEvent)
  {
    let point = getMouseLocalPoint(event: event)
    vgi.mouseState.position = .init(Float(point.x), Float(point.y))
    vgi.mouseState.buttons.left = true
  }

  func mouseUp(event _: NSEvent)
  {
    vgi.mouseState.buttons.left = false
  }

  func rightMouseDown(event: NSEvent)
  {
    let point = getMouseLocalPoint(event: event)
    vgi.mouseState.position = .init(Float(point.x), Float(point.y))
    vgi.mouseState.buttons.right = true
  }

  func rightMouseUp(event _: NSEvent)
  {
    vgi.mouseState.buttons.right = false
  }

  func otherMouseDown(event: NSEvent)
  {
    let point = getMouseLocalPoint(event: event)
    vgi.mouseState.position = .init(Float(point.x), Float(point.y))
    vgi.mouseState.buttons.middle = true
  }

  func otherMouseUp(event _: NSEvent)
  {
    vgi.mouseState.buttons.middle = false
  }

  func mouseDragged(event: NSEvent)
  {
    let point = getMouseLocalPoint(event: event)
    vgi.mouseDragged(x: point.x, y: point.y)
  }

  func rightMouseDragged(event: NSEvent)
  {
    let point = getMouseLocalPoint(event: event)
    vgi.mouseDragged(x: point.x, y: point.y)
  }

  func otherMouseDragged(event: NSEvent)
  {
    let point = getMouseLocalPoint(event: event)
    vgi.mouseDragged(x: point.x, y: point.y)
  }

  func mouseMoved(event: NSEvent)
  {
    let point = getMouseLocalPoint(event: event)
    vgi.mouseDragged(x: point.x, y: point.y)
  }

  func scrollWheel(event: NSEvent)
  {
    let wheelDelta = event.deltaY
    vgi.camera.translate(.init(0.0, 0.0, -(Float(wheelDelta) * 0.05 * vgi.camera.movementSpeed)))
    vgi.viewUpdated = true
  }

  public func windowWillEnterFullScreen(_: Notification)
  {
    vgi.settings.fullscreen = true
  }

  public func windowWillExitFullScreen(_: Notification)
  {
    vgi.settings.fullscreen = false
  }

  public func windowShouldClose(_: NSWindow) -> Bool
  {
    true
  }

  public func windowWillClose(_: Notification)
  {
    if let displayLink
    {
      CVDisplayLinkStop(displayLink)
    }
  }
}

extension Vulkan.GI
{
  public func setupWindow()
  {
    NSApp = NSApplication.shared
    NSApp.setActivationPolicy(.regular)

    let appDelegate = AppDelegate()
    appDelegate.vgi = self
    NSApp.delegate = appDelegate

    let contentRect = NSMakeRect(0.0, 0.0, CGFloat(width), CGFloat(height))
    let styleMask: NSWindow.StyleMask = [.titled, .closable, .resizable]

    let window = NSWindow(
      contentRect: contentRect,
      styleMask: styleMask,
      backing: .buffered,
      defer: false
    )

    window.title = title
    window.acceptsMouseMovedEvents = true
    window.center()
    window.makeKeyAndOrderFront(nil)
    if settings.fullscreen
    {
      window.toggleFullScreen(nil)
    }

    let nsView = View(frame: contentRect)
    nsView.vgi = self
    window.delegate = nsView
    window.contentView = nsView
    self.view = nsView
    metalLayer = nsView.layer as? CAMetalLayer
  }
}
