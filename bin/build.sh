#!/bin/bash
# set -e: exit with errors if anything fails
#     -u: it's an error to use an undefined variable
#     -x: print out every command before it runs
#     -o pipefail: if something in the middle of a pipeline fails, the whole thing fails
set -euxo pipefail

# Clean up any prior build
rm -rf build-conan

# Build the tflite_cpu module
#
# We want a static binary, so we turn off shared. Elect for C++17
# compilation, since it seems some of the dependencies we pick mandate
# it anyway.

# We could just call `build` here with `--build=missing`, but we split this into two steps
# so we can ensure that all our dependencies are built consistently in `Release`, but that
# the actual module build gets built with an override to `RelWithDebInfo`, which we
# don't want to have accidentally affect our dependencies (it makes the build far too large).
# The override itself is derived from https://github.com/conan-io/conan/issues/12656.

conan install . --update \
      --build=missing \
      -s:h build_type=Release \
      -s:h "viam-cpp-sdk/*:build_type=RelWithDebInfo" \
      -s:h "&:build_type=RelWithDebInfo" \
      -s:a compiler.cppstd=17 \
      -o:h "*:shared=False" \
      -o:h "&:shared=False" \
      -o:h "grpc/*:cpp_plugin=False" \
      -o:a "grpc/*:csharp_plugin=False" \
      -o:a "grpc/*:node_plugin=False" \
      -o:a "grpc/*:objective_c_plugin=False" \
      -o:a "grpc/*:php_plugin=False" \
      -o:a "grpc/*:python_plugin=False" \
      -o:a "grpc/*:ruby_plugin=False" \
      -o:a "grpc/*:otel_plugin=False"

conan build . \
      --output-folder=build-conan \
      --build=none \
      -s:h build_type=Release \
      -s:h "viam-cpp-sdk/*:build_type=RelWithDebInfo" \
      -s:h "&:build_type=RelWithDebInfo" \
      -s:a compiler.cppstd=17 \
      -o:h "*:shared=False" \
      -o:h "&:shared=False" \
      -o:h "grpc/*:cpp_plugin=False" \
      -o:a "grpc/*:csharp_plugin=False" \
      -o:a "grpc/*:node_plugin=False" \
      -o:a "grpc/*:objective_c_plugin=False" \
      -o:a "grpc/*:php_plugin=False" \
      -o:a "grpc/*:python_plugin=False" \
      -o:a "grpc/*:ruby_plugin=False" \
      -o:a "grpc/*:otel_plugin=False"
