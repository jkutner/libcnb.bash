# libcnb.bash

This is a Bash binding of the Cloud Native Buildpacks API. It is a non-opinionated implementation adding language constructs and convenience methods for working with the API.

## Usage

Source the script directly from the Releases:

```
source /dev/stdin <<< "$(curl -sL --retry 3 https://github.com/jkutner/libcnb.bash/releases/download/0.0.1/libcnb.bash)"
```

Or vendor the [`libcnb.bash`](https://github.com/jkutner/libcnb.bash/blob/main/libcnb.bash) script into your buildpack, and source it:

```sh-sesssion
source $CNB_BUILDPACK_DIR/lib/libcnb.bash
```

## Testing

The `test.bats` script requires the [`bats`](https://github.com/sstephenson/bats) framework. Once it's installed, you can run:

```
$ make test
```

## License

MIT
