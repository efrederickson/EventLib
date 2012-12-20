@echo off
for %%f in (*.lua) do (
 cd ..
 lua "tests\%%f"
 cd tests
)

if %ERRORLEVEL% EQ 1 ( PAUSE )