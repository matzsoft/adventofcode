# Patching Package.swift

Sometimes a problem solution needs access to an external library. When this happens Package.swift must be modified with dependencies for the external library. Even though this is rare (currently only 2019 day22) it would be nice for this to be automatic.

Currently the `adventOfCode` tool uses the Unix `diff` and `patch` commands to accomplish this. Sadly this has proven too fragile. That is, updates to **Xcode** and/or **Swift Package Manager** can cause a subsequent `adventOfCode open` to be unable to successfully patch the Package.swift file.

Consequently a better solution is required.