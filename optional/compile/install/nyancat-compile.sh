#!/usr/bin/env bash
# yourTermux - Author: JubairSenseiDev - https://github.com/JubairSenseiDev/yourTermux

DEPENDENCY_PACKAGES=(
  clang make git binutils
)

for DEPENDENCY_PACKAGES in ${DEPENDENCY_PACKAGE[@]}; do
  pkg i -y ${DEPENDENCY_PACKAGE}
done

git clone https://github.com/JubairSenseiDev/nyancat.git $HOME/nyancat
cd $HOME/nyancat
make
strip src/nyancat
make install
echo -e "Compile & Install done!"
