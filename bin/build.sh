#!/bin/bash
# set -e: exit with errors if anything fails
#     -u: it's an error to use an undefined variable
#     -x: print out every command before it runs
#     -o pipefail: if something in the middle of a pipeline fails, the whole thing fails
set -euxo pipefail

# Clean up any prior build
rm -rf build-conan

# Otherwise, the C++ SDK build ends up creating two copies of proto and then mixes up which one to use.
cat > protobuf-override.profile << 'EOF'
include(default)
[replace_tool_requires]
protobuf/*: protobuf/<host_version>
EOF

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
      --profile=protobuf-override.profile \
      --build=missing \
      -s:a build_type=Release \
      -s:a "viam-cpp-sdk/*:build_type=RelWithDebInfo" \
      -s:a "&:build_type=RelWithDebInfo" \
      -s:a compiler.cppstd=17 \
      -o:a "*:shared=False" \
      -o:a "&:shared=False"

conan build . \
      --output-folder=build-conan \
      --profile=protobuf-override.profile \
      --build=none \
      -s:a build_type=Release \
      -s:a "viam-cpp-sdk/*:build_type=RelWithDebInfo" \
      -s:a "&:build_type=RelWithDebInfo" \
      -s:a compiler.cppstd=17 \
      -o:a "*:shared=False" \
      -o:a "&:shared=False"
