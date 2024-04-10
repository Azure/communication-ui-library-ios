# Gradle Feature Flags for iOS Development

## Why Are We Using a Gradle Tool for iOS?

Yes, you read it right. We're employing a Gradle-based tool to manage feature flags in our iOS projects. It might seem odd at first—after all, Gradle and iOS aren't exactly the peanut butter and jelly of software development. The reason behind this choice is simple: to maintain consistency with our Android projects and to avoid duplicating efforts across platforms.

Android holds the master version of this tooling, and any necessary updates or tweaks made here should ideally be ported back. It's a bit of a workaround, but it ensures that both our iOS and Android teams can stay on the same page with feature toggling without reinventing the wheel.

## What This Tool Does

In essence, `Gradle Feature Flags` allows us to toggle features on and off at compile time across various programming languages that support block comments. This includes, but isn't limited to, Java, Kotlin, XML, and yes, Swift. By using block comment delimiters to enable or disable code paths, we ensure that unused code doesn't clutter our final builds.

## How to Use It

1. **Set-Up:** 
   - Use this folder as if it was an `android` project. `./gradlew flagHelp` to get started.

2. **Defining Flags:**
   - Flags are defined within your source files using block comments. Refer to the script for the exact syntax and examples.
   - To manage these flags, use the provided Gradle commands, which you can explore by running `./gradlew flagHelp`.

3. **Keeping in Sync:**
   - Since Android has the definitive version of this tool, any modifications we make for iOS should be reflected back in the Android repo. This might seem tedious, but it's crucial for keeping our tooling aligned across platforms.

## Final Thoughts

We know, using a Gradle tool for iOS development is a bit like using a Swiss Army knife as a screwdriver: not exactly what it was designed for, but surprisingly effective. While this approach has its quirks, it also offers a straightforward solution to a complex problem, enabling us to maintain feature consistency with minimal overhead.

Remember, this is an internal tool, and it's about practicality, not perfection. As we continue to develop and refine our cross-platform strategy, feedback and improvements are always welcome.
