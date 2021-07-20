# libcnb.bash

This is a Bash binding of the Cloud Native Buildpacks API. It is a non-opinionated implementation adding language constructs and convenience methods for working with the API.

## Usage

Set the following vars in your `bin/build` (eventually these will because a part of the CNB spec and you won't need these lines):

```
CNB_BP_LAYERS_DIR="$1"
CNB_PLATFORM_DIR="$2"
```

Then source the `libcnb.bash` script directly from Github Releases:

```
source /dev/stdin <<< "$(curl -sL --retry 3 https://github.com/jkutner/libcnb.bash/releases/download/0.0.4/libcnb.bash)"
```

Or vendor the [`libcnb.bash`](https://github.com/jkutner/libcnb.bash/blob/main/libcnb.bash) script into your buildpack, and source it:

```sh-sesssion
source $CNB_BUILDPACK_DIR/lib/libcnb.bash
```

Finally, in your buildpack's `bin/build` you can run functions like:

* `cnb_load_env` - loads all the environment variables passed into the buildpack (which are stored in the platform dir)
* `cnb_create_layer <layer>` - creates a new layer directory
* `cnb_reset_layer <layer>` - destroys and creates a layer directory (useful when caching)
* `cnb_set_layer_env <layer> <var> <value>` - sets an env var for the layer
* `cnb_load_layer <layer>` - loads all env vars and sets `PATH` as if this layer were used by a subsequent buildpack
* `cnb_set_layer_metadata <layer> <metadata>` - writes metadata to the layer TOML file
* `cnb_create_process <type> <command>` - adds a process type to the `launch.toml`

## Example

```bash
#!/usr/bin/env bash

set -euo pipefail

CNB_BP_LAYERS_DIR="$1"
CNB_PLATFORM_DIR="$2"

source $CNB_BUILDPACK_DIR/lib/libcnb.bash

cnb_load_env

sample_layer="$(cnb_create_layer sample)"

version="$(cat version.txt)"

if [ -f ${sample_layer}.toml ] && [ "$(cat "${sample_layer}.toml" | yj -t | jq .metadata.version -r)" == "${version}" ]; then
  echo "Using cached version: ${version}"
else
  cnb_reset_layer sample
  echo "I'm a sample layer" > ${sample_layer}/sample.txt
  cnb_set_layer_metadata python """
version = \"$version\"
"""
fi
```


## Testing

The `test.bats` script requires the [`bats`](https://github.com/sstephenson/bats) framework. Once it's installed, you can run:

```
$ make test
```

## License

MIT
