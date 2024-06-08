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
import glTF
import vulkan
import VulkanKit

public extension glTF.Scene
{
  class Images: glTF.Scene.Prim
  {
    override public func load(input: tinygltf.Model)
    {
      // POI: The textures for the glTF file used in this sample are stored as external ktx files, so we can directly load them from disk without the need for conversion
      for i in 0 ..< input.images.count
      {
        let glTFImage = input.images[i]
        scene.images[i].texture.loadFromFile(
          atPath: scene.path + "/" + String(glTFImage.uri),
          format: VK_FORMAT_R8G8B8A8_UNORM,
          device: scene.device,
          copyQueue: scene.copyQueue
        )
      }
    }
  }
}
