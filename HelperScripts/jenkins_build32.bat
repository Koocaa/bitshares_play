echo Available processor count: %NUMBER_OF_PROCESSORS%
echo Starting build # %BUILD_NUMBER%
cd bitshares_play
rem git reset --hard
rem git pull
rem reset and pull not needed because we assume
rem that bitshares_toolkit was just cloned fresh
git submodule init || exit /b 21
git submodule update || exit /b 22

cd %WORKSPACE%
cd bitshares_play/vendor
if exist leveldb-win (
    pushd leveldb-win
    git reset --hard || exit /b 23
    git pull || exit /b 24
) else (
    git clone https://www.github.com/InvictusInnovations/leveldb-win.git || exit /b 25
)

cd %WORKSPACE%
call bitshares_play/setenv.bat || exit /b 26

call npm install grunt
call npm install lineman -g --prefix=%NPM_INSTALL_PREFIX%
call npm install lineman-angular
call npm install lineman-less

if exist build (
  rmdir /Q /S build || exit /b 27
)
mkdir build
cd build
cmake -DINCLUDE_QT_WALLET=TRUE -G "Visual Studio 12" ../bitshares_play || exit /b 28
msbuild.exe /M:%NUMBER_OF_PROCESSORS% /p:Configuration=RelWithDebinfo /p:Platform=Win32 /target:rebuild /v:diag BitShares.sln || exit /b 30
