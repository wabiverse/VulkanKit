#pragma once

#include "glm/detail/setup.hpp"

namespace glm
{
  namespace detail
  {
    typedef short hdata;

    GLM_FUNC_DECL float toFloat32(hdata value);
    GLM_FUNC_DECL hdata toFloat16(float const &value);

  } // namespace detail
} // namespace glm

#include "glm/detail/type_half.inl"
