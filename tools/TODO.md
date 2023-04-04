# Introduction

I recently discovered how to have a swift package use another swift package in the same local file tree as a library.  This allows me to move the `Library` folder out of the `adventOfCode` tool into its own seperate package.  I got this to work just for the `adventOfCode` tool but the real goal is to avoid copying the `Library` files into the package created when working on the daily problems.  Acomplishing this will be a big project.

# Tasks to Complete

## Modify Subcommands

1. Make - add the `import Library` statement to the main swift template.
1. Open
    - Ensure `main.swift` has `import Library`.
    - Don't copy `Library` files.
    - Instead modify `Package.swift` to include `Library` dependencies.
    - Be sure to properly handle `stock-Package.swift`.
1. Close - no need to copy `Library` files back.

## Update All the Library Files

Most but not all functions, methods, and properties will need to be made `public`.

## Modify All the Daily Problem Solutions

Hopefully this will only require adding the `import Library` statement and that will be handled by the `open` subcommand (see above).  But I will also need to check that they all work properly in the new structure.

## Fix Up README and TODO Files

1. The `README` for the `adventOfCode` tool will need to reflect the new structure and handling of the `Library`.
1. Make a `README` and `TODO` for the `Library`.
1. The `TODO` for the `adventOfCode` tool is now obsolete.