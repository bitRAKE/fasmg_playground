Simple example of building a modular project with fasmg and nmake.

readme.txt	- this file
VSGo.cmd	- establish VS build environment

Dependency structure of the project:

Makefile
.\SubClass64.g
...\DialogProc.g
.....\ConvertStaticToHyperlink.g
.....\Dlg.rc

The MS build tools are free to download and don't need Visual Studio:

https://stackoverflow.com/questions/59868753/offline-build-tools-for-visual-studio-2019

https://aka.ms/buildtools
