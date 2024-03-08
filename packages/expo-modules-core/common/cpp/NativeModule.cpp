// Copyright 2024-present 650 Industries. All rights reserved.

#include "JSIUtils.h"
#include "EventEmitter.h"
#include "NativeModule.h"

namespace expo::NativeModule {

jsi::Function getClass(jsi::Runtime &runtime) {
  return common::getCoreObject(runtime).getPropertyAsFunction(runtime, "NativeModule");
}

void installClass(jsi::Runtime &runtime) {
  jsi::Function eventEmitterClass = EventEmitter::getClass(runtime);
  jsi::Function nativeModuleClass = common::createInheritingClass(runtime, "NativeModule", eventEmitterClass);

  common::getCoreObject(runtime).setProperty(runtime, "NativeModule", nativeModuleClass);
}

jsi::Object createInstance(jsi::Runtime &runtime, const char *moduleName) {
  jsi::Object instance = getClass(runtime).callAsConstructor(runtime).getObject(runtime);

  // Give the module object a name. It's used for compatibility reasons, see `EventEmitter.ts`.
  common::defineProperty(runtime, &instance, "__expo_module_name__", common::PropertyDescriptor {
    .value = jsi::String::createFromAscii(runtime, moduleName)
  });

  return instance;
}

} // namespace expo::NativeModule
