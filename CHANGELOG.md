# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- Added `load!` function to return raw value without `:ok/:error` tuple.

## [0.2.0] - 2016-11-21
### Added
- Added support for function pattern like `{:function, ModuleName, :function_name, [:list, :of, :args]}`

## [0.1.0] - 2016-11-21
### Added
- `ConfigExt.load/1` and `ConfigExt.load/2` with capability to load patterns like `{:system, key[, default]}`
