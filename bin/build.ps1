# Fail fast
$ErrorActionPreference = "Stop"

# Ensure that things installed with choco are visible to us
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv

# Clean up any prior build
Remove-Item -Recurse -Force build-conan -ErrorAction SilentlyContinue

# Build the tflite_cpu module
#
# We want a static binary, so we turn off shared. Elect for C++17
# compilation, since it seems some of the dependencies we pick mandate
# it anyway. Pin to the Windows 10 1809 associated windows SDK, and
# opt for the static compiler runtime so we don't have a dependency on
# the VC redistributable.

# We could just call `build` here with `--build=missing`, but we split this into two steps
# so we can ensure that all our dependencies are built consistently in `Release`, but that
# the actual module build gets built with an override to `RelWithDebInfo`, which we
# don't want to have accidentally affect our dependencies (it makes the build far too large).
# The override itself is derived from https://github.com/conan-io/conan/issues/12656.

conan install . --update `
      --build=missing `
      -s:a build_type=Release `
      -s:a "viam-cpp-sdk/*:build_type=RelWithDebInfo" `
      -s:a "&:build_type=RelWithDebInfo" `
      -s:a compiler.cppstd=17 `
      -o:a "*:shared=False" `
      -o:a "&:shared=False" `
      -o:a "grpc/*:csharp_plugin=False" `
      -o:a "grpc/*:node_plugin=False" `
      -o:a "grpc/*:objective_c_plugin=False" `
      -o:a "grpc/*:php_plugin=False" `
      -o:a "grpc/*:python_plugin=False" `
      -o:a "grpc/*:ruby_plugin=False" `
      -o:a "grpc/*:otel_plugin=False" `
      -c:a tools.microsoft:winsdk_version=10.0.17763.0 `
      -c:a tools.cmake.cmaketoolchain:extra_variables="{'gRPC_MSVC_STATIC_RUNTIME': 'ON'}" `
      -s:a compiler.runtime=static

conan build . `
      --output-folder=build-conan `
      --build=none `
      -s:a build_type=Release `
      -s:a "viam-cpp-sdk/*:build_type=RelWithDebInfo" `
      -s:a "&:build_type=RelWithDebInfo" `
      -s:a compiler.cppstd=17 `
      -o:a "*:shared=False" `
      -o:a "&:shared=False" `
      -o:a "grpc/*:csharp_plugin=False" `
      -o:a "grpc/*:node_plugin=False" `
      -o:a "grpc/*:objective_c_plugin=False" `
      -o:a "grpc/*:php_plugin=False" `
      -o:a "grpc/*:python_plugin=False" `
      -o:a "grpc/*:ruby_plugin=False" `
      -o:a "grpc/*:otel_plugin=False" `
      -c:a tools.microsoft:winsdk_version=10.0.17763.0 `
      -c:a tools.cmake.cmaketoolchain:extra_variables="{'gRPC_MSVC_STATIC_RUNTIME': 'ON'}" `
      -s:a compiler.runtime=static
