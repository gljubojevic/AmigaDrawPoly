# download osx tools for Amiga Assembly extension
echo "Downloading bin tools..."
echo "NOTE: No need to set osx unknown developer attributes when bin tools downloaded like this"
[ -d "bin" ] && rm -rf bin
mkdir -p bin
curl https://github.com/prb28/vscode-amiga-assembly/releases/download/0.21.1/osx.zip -L -o bin/osx.zip
unzip -d ./bin ./bin/osx.zip
rm ./bin/osx.zip
