# Futureal
Futureal is a free and open source simple shooting 2D platform game built on the [Godot Engine](https://github.com/godotengine/godot) (current version is 3.5.1) using the GDScript language and a [Git plugin](https://github.com/godotengine/godot-git-plugin). The project is under development, bugs, crashes and other problems are possible. Suggestions and comments are welcome, write to [Issues](https://github.com/GREATDNG/Futureal/issues).

## Getting the game
You can get the game in two ways: by compiling the game from source (recommended) or by downloading the ready build.

### Compiling from source (recommended)
The easiest way to build the game:
1. Download [sources](https://github.com/GREATDNG/Futureal/archive/refs/heads/master.zip).
2. Download [Godot Engine](https://godotengine.org/download) (without .NET support).
3. Unzip both archives to a location of your choice.
4. Run Godot binary from second archive.
5. In the window that opens, click the `Import` button and select the file `project.godot` from the archive with the game.
6. After the project is loaded, go to the export settings (`Project` > `Export...`).
7. Select a platform (`Add...` > `Windows`, `Linux`, or `OSX`). If you get an `Export templates for this platform are missing` error, click `Manage Export Templates`, in the window that opens, click the `Download and Install` button. After installation, close the window and return to the export settings (see point 6).
8. Click the `Export Project` button and select the path where you want to get the binary (I prefer `/Export/PlatformName/`). Wait for the build to finish.

You now have the latest version of the game. You can learn more about the build process in the [engine documentation](https://docs.godotengine.org/en/stable/tutorials/export/index.html).

### Downloading a ready build
:warning: **Attention: The ready build may be *very* outdated and may not contain the latest game features or is not designed for your platform.**

Download the archive from the [releases page](https://github.com/GREATDNG/Futureal/releases), unpack and run the binary.

:video_game: Have a good game!

## Getting help
For help with gameplay use `F1`. If this is not enough (which is very likely), you can ask your question in [Issues](https://github.com/GREATDNG/Futureal/issues).

## Licensing
The project uses the [MIT License](https://github.com/GREATDNG/Futureal/blob/master/LICENSE).