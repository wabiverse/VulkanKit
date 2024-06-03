/* --------------------------------------------------------------
 * :: :  V  U  L  K  A  N  :                                   ::
 * --------------------------------------------------------------
 * @wabistudios :: graphics :: vulkankit
 *
 * This program is free software; you can redistribute it, and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. Check out
 * the GNU General Public License for more details.
 *
 * You should have received a copy for this software license, the
 * GNU General Public License along with this program; or, if not
 * write to the Free Software Foundation, Inc., to the address of
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 *                            Copyright (C) 2023 Wabi Foundation.
 *                                           All Rights Reserved.
 * --------------------------------------------------------------
 *  . x x x . o o o . x x x . : : : .    o  x  o    . : : : .
 * -------------------------------------------------------------- */

import vulkan

public class Vulkan
{
  /**
   * Singleton instance of the Vulkan class.
   */
  public static var shared: Vulkan = .init()

  /**
   * Private initializer for the Vulkan class.
   */
  private init()
  {}

  /**
   * Get the Vulkan instance version, using the vulkan api.
   */
  var v: PFN_vkEnumerateInstanceVersion = { res in
    vkGetInstanceProcAddr(nil, "vkEnumerateInstanceVersion")
    return vkEnumerateInstanceVersion(res)
  }

  /**
   * Returns the Vulkan instance version as a string.
   */
  public var version: String
  {
    var fullVersion: UInt32 = vkApiVersion1_0()
    _ = v(&fullVersion)
    return "\(vkApiVersionMajor(fullVersion)).\(vkApiVersionMinor(fullVersion)).\(vkApiVersionPatch(fullVersion))"
  }
}
