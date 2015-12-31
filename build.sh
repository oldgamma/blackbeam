#!/bin/bash

VERSION="${@}" &&
    RELEASE=0.1.1 &&
    rm --recursive --force build &&
    mkdir --parents build &&
    sed -e "s#VERSION#${VERSION}#" -e "s#RELEASE#${RELEASE}#" -e "wbuild/meaningfulmoon.spec" meaningfulmoon.spec &&
    wget --output-document build/meaningfulmoon-${VERSION}.tar.gz https://github.com/persistentdog/meaningfulmoon/archive/v${VERSION}.tar.gz &&
    mkdir build/config &&
    head --lines -1 /etc/mock/default.cfg > build/config/default.cfg &&
    (cat >> build/config/default.cfg <<EOF

[dancingleather]
name=dancingleather
baseurl=https://raw.githubusercontent.com/rawflag/dancingleather/master
enabled=1
EOF
    ) &&
    tail --lines 1 /etc/mock/default.cfg >> build/config/default.cfg &&
    mkdir --parents build/init/01 &&
    mock --init --configdir build/config --resultdir build/init/01 &&
    mkdir --parents build/buildsrpm/01 &&
    mock --buildsrpm --spec build/meaningfulmoon.spec --sources build/meaningfulmoon-${VERSION}.tar.gz --config build/config --resultdir build/buildsrpm/01 &&
    mkdir --parents build/init/02 &&
    mock --init --configdir build/config --resultdir build/init/02 &&
    mkdir --parents build/rebuild &&
    mock --rebuild build/buildsrpm/01/meaningfulmoon-${VERSION}-${RELEASE}.src.rpm --configdir build/config --resultdir build/rebuild/01 &&
    if false
    then
	echo I think mock and systemd do not work together &&
	    echo that is why this is hard to test. &&
	    echo wish me luck &&
	    mkdir --parents build/init/03 &&
	    mock --init --configdir build/config --resultdir build/init/03 &&
	    mkdir --parents build/install/01 &&
	    mock --install build/rebuild/01/meaningfulmoon-${VERSION}-${RELEASE}.x86_64.rpm --configdir build/config --resultdir build/install/03 &&
	    mkdir --parents build/shell/01 &&
	    mock --shell "adduser emory && systemctl start meaningfulmoon.service && sleep 10s && wget --user emory --password emory http://127.0.0.1:26775" --configdir build/config --resultdir build/shell/01 &&
	    mkdir --parents build/copyout/01 &&
	    mock --copyout index.html build/index.html --configdir build/config --resultdir build/copyout/01 &&
	    true
    fi &&
    git clone -b master git@github.com:rawflag/dancingleather.git build/repository &&
	cp build/rebuild/01/meaningfulmoon-${VERSION}-${RELEASE}.x86_64.rpm build/repository &&
	cd build/repository &&
	rpm --resign meaningfulmoon-${VERSION}-${RELEASE}.x86_64.rpm &&
	createrepo . &&
	git add repodata/* meaningfulmoon-${VERSION}-${RELEASE}.x86_64.rpm &&
	git commit -am "Added meaningfulmoon ${VERSION} ${RELEASE}" -S &&
	git push origin master &&
	true
