# OpenSim [![Travis](https://img.shields.io/travis/luosheng/OpenSim.svg)]()

OpenSim is an open source alternative to [SimPholders](https://simpholders.com), written in Swift 3. If you are looking for sources with Swift 2, please check out the `swift-2.2` branch.

You can visit the latest [release](https://github.com/luosheng/OpenSim/releases) to grab a compiled version. (Warning: It's not code-signed.)

## Install with Homebrew Cask

1. Install Homebrew: `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
2. Install Cask: `brew install cask`
3. Install OpenSim: `brew cask install opensim`

## TODO

- [x] Parsing results from `xcrun` command rather than `device_set.plist` file (thank @bradvandyk)
- [x] Watch for changes from simulators directory and reload dynamically
- [x] Filter out empty simulators
- [x] Better UI
- [ ] Other functionalities like uninstalling apps or resetting data
