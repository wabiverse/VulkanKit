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

public extension glTF
{
  class Scene
  {
    public init(vgi: Vulkan.GI)
    {
      device = vgi.vulkanDevice!
      copyQueue = vgi.queue!

      let imagePrims = glTF.Scene.Images(scene: self)
      let matPrims = glTF.Scene.Materials(scene: self)
      let nodePrims = glTF.Scene.Nodes(scene: self)
      let texPrims = glTF.Scene.Textures(scene: self)

      prims.append(imagePrims)
      prims.append(matPrims)
      prims.append(nodePrims)
      prims.append(texPrims)
    }

    public var device: Vulkan.Device
    public var copyQueue: VkQueue

    public var path: String = ""

    public var prims: [glTF.Scene.Prim] = []

    public var images: [Image] = []
    public var textures: [Texture] = []
    public var materials: [Material] = []
    public var nodes: [Node] = []
  }
}
