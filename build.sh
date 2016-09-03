#!/usr/bin/env bash

#exit if any command fails
set -e

artifactsFolder="./artifacts"

if [ -d $artifactsFolder ]; then
  rm -R $artifactsFolder
fi

dotnet restore

# Ideally we would use theis command to test netcoreapp and net451 so restrict for now 
# but currently donsn't work due to https://github.com/dotnet/cli/issues/3073 
dotnet test ./test/NetEscapades.Configuration.Yaml.Tests -c Release -f netcoreapp1.0
dotnet test ./test/NetEscapades.Configuration.Remote.Tests -c Release -f netcoreapp1.0

# Instead, run directly with mono for the full .net version 
dotnet build ./test/NetEscapades.Configuration.Yaml.Tests -c Release -f net451
dotnet build ./test/NetEscapades.Configuration.Remote.Tests -c Release -f net451

mono \
./test/NetEscapades.Configuration.Yaml.Tests/bin/Release/net451/*/dotnet-test-xunit.exe \
./test/NetEscapades.Configuration.Yaml.Tests/bin/Release/net451/*/NetEscapades.Configuration.Yaml.Tests.dll

mono \
./test/NetEscapades.Configuration.Remote.Tests/bin/Release/net451/*/dotnet-test-xunit.exe \
./test/NetEscapades.Configuration.Remote.Tests/bin/Release/net451/*/NetEscapades.Configuration.Yaml.Tests.dll

revision=${TRAVIS_JOB_ID:=1}
revision=$(printf "%04d" $revision) 

dotnet pack ./src/NetEscapades.Configuration.Yaml -c Release -o ./artifacts --version-suffix=$revision