M=6.18
V=21

# 1. clone first time
# git clone https://github.com/raspberrypi/linux.git raspberrypi
cd raspberrypi
# git remote add upstream https://mirror.nju.edu.cn/git/linux-stable.git

# 2. checkout branch
git checkout rpi-${M}.y 
git pull -v origin rpi-${M}.y

# 3. update HEAD
git fetch -v upstream linux-${M}.y

# 4. merge base
BASE_COMMIT=$(git merge-base rpi-${M}.y FETCH_HEAD)
echo "BASE_COMMIT=$BASE_COMMIT"

# 5. generate patchset
git diff $BASE_COMMIT..rpi-${M}.y > ../rpi-${M}.${V}.patch
echo rpi-${M}.${V}.patch
cd -
