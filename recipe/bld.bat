REM This batch file is derived from conda-forge with a view to cleanly
REM reporting the build logs on failure.

REM BUILDDIR=buildir, relative to %SRC_DIR% results in C1083 errors in
REM the cythonize section which appear to be related to long pathnames
REM and (ultimately) MSVC.  Clearly, using some shortened BUILDDIR=\X
REM is neither a long-term solution (filenames could get a lot longer)
REM nor respecting of the build environment (should we crash or it
REM already exist).
REM
REM NB \AD24 is Anaconda Distribution 2024 which avoids \tmp - a
REM well-known name
set BUILDDIR=\AD25

REM Try to avoid race conditions between a potential rmdir immediately
REM followed by a mkdir.  Also "cd X; rmdir ." avoids deleting the
REM current directory which might have been created with special
REM permissions.
if exist %BUILDDIR% (
  cd %BUILDDIR%
  rmdir /Q /S .
) else (
  mkdir %BUILDDIR%
)

@REM %PYTHON% -m build --wheel --no-isolation --skip-dependency-check --verbose ^
@REM   -Cbuilddir=%BUILDDIR%
%PYTHON% -m pip install . --no-deps --ignore-installed --no-build-isolation -vv -b %BUILDDIR%
if errorlevel 1 (
  type %BUILDDIR%\meson-logs\meson-log.txt
  rmdir /Q /S %BUILDDIR%
  exit /b 1
)

@REM for /f %%f in ('dir /b /S .\dist') do (
@REM   pip install %%f
@REM   if %errorlevel% neq 0 (
@REM     rmdir /Q /S %BUILDDIR%
@REM     exit 1
@REM   )
@REM )

rmdir /Q /S %BUILDDIR%
