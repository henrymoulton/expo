// Copyright 2024-present 650 Industries. All rights reserved.

#pragma once

#ifdef __cplusplus

#include <jsi/jsi.h>

namespace jsi = facebook::jsi;

namespace expo::NativeModule {

/**
 Gets `expo.NativeModule` class in the given runtime.
 */
jsi::Function getClass(jsi::Runtime &runtime);

/**
 Installs `expo.NativeModule` class in the given runtime.
 */
void installClass(jsi::Runtime &runtime);

/**
 Creates a new instance of the native module.
 */
jsi::Object createInstance(jsi::Runtime &runtime, const char *moduleName);

} // namespace expo::NativeModule

#endif // __cplusplus
