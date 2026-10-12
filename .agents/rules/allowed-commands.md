# Allowed Project Commands

The following repository scripts and commands are pre-authorized for autonomous execution during development, testing, and verification:

- `./scripts/build.sh`: Compiles and ad-hoc signs `build/FlagType.app`.
- `./scripts/test.sh`: Compiles and executes the native Swift test runner (`tests/run_tests.swift`).
- `./scripts/install.sh`: Deploys `build/FlagType.app` to `/Applications/FlagType.app` and strips quarantine attributes.
- `./scripts/package.sh`: Packages release archive `build/FlagType.zip` and calculates SHA256 checksums.
- `swift scripts/<script_name>.swift`: Executes standalone Swift helper scripts (e.g. icon or asset generators).

Agents do not need to request additional user confirmation before running these standard repository commands.
