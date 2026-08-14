@echo off
dpm cache remove ccLib.LayoutSaver
for %%f in (*.dpkg) do (
	dpm push "%%f" -source=local
)