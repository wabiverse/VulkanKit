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

import Foundation
import vulkan

public extension Vulkan
{
  class Texture
  {
    public var device: VkDevice
    public var image: VkImage
    public var imageLayout: VkImageLayout
    public var imageView: VkImageView
    public var deviceMemory: VkDeviceMemory
    public var width: Int
    public var height: Int
    public var mipLevels: Int
    public var layerCount: Int
    public var decriptor: VkDescriptorImageInfo
    public var sampler: VkSampler?

    public init(device: VkDevice,
                image: VkImage,
                imageLayout: VkImageLayout,
                imageView: VkImageView,
                deviceMemory: VkDeviceMemory,
                width: Int,
                height: Int,
                mipLevels: Int,
                layerCount: Int,
                decriptor: VkDescriptorImageInfo,
                sampler: VkSampler)
    {
      self.device = device
      self.image = image
      self.imageLayout = imageLayout
      self.imageView = imageView
      self.deviceMemory = deviceMemory
      self.width = width
      self.height = height
      self.mipLevels = mipLevels
      self.layerCount = layerCount
      self.decriptor = decriptor
      self.sampler = sampler
    }

    deinit
    {
      destroy()
    }

    public func destroy()
    {
      vkDestroyImageView(device, imageView, nil)
      vkDestroyImage(device, image, nil)
      if let sampler
      {
        vkDestroySampler(device, sampler, nil)
      }
      vkFreeMemory(device, deviceMemory, nil)
    }

    public func updateDescriptor()
    {
      decriptor.sampler = sampler
      decriptor.imageView = imageView
      decriptor.imageLayout = imageLayout
    }

    public func loadKTXFile(atPath filename: String, target: inout UnsafeMutablePointer<ktxTexture>?) -> ktxResult
    {
      var result: ktxResult = KTX_SUCCESS

      if !Vulkan.Tools.fileExists(atPath: filename)
      {
        Vulkan.Tools.exitFatal("""
          Could not load texture from \(filename).
          Make sure the assets submodule has been
          checked out and is up-to-date.
          """)
      }
      result = ktxTexture_CreateFromNamedFile(filename, KTX_TEXTURE_CREATE_LOAD_IMAGE_DATA_BIT.rawValue, &target)

      return result
    }
  }
}
