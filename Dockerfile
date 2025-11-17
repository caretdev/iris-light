ARG BASE_IMAGE=containers.intersystems.com/intersystems/iris-community:latest-em
ARG ORIGINAL_BASE=ubuntu:24.04
FROM ${BASE_IMAGE} AS base

RUN --mount=type=bind,src=/,dst=/tmp/irislight <<EOT
  # start IRIS and do cleanup and compact
  sed -i '/.*ENSLIB.*/d' ${ISC_PACKAGE_INSTALLDIR}/iris.cpf
  sed -i 's/^WebServer=.*/WebServer=0/' ${ISC_PACKAGE_INSTALLDIR}/iris.cpf
  sed -i 's/^EnsembleAutoStart=.*/EnsembleAutoStart=0/' ${ISC_PACKAGE_INSTALLDIR}/iris.cpf
  iris start ${ISC_PACKAGE_INSTANCENAME}
  cat <<"EOF" | iris session ${ISC_PACKAGE_INSTANCENAME} -U %SYS
  set dbfile = "/usr/irissys/mgr/irislib/"
  set db=##class(SYS.Database).%OpenId(dbfile),db.ReadOnly=0 do db.%Save()
  set keep = $listbuild("%Compiler","%Library","%SQL","%ExtentMgr","%Collection","%Stream","%SYS","%SYSTEM","%ResultSet","%Embedding","%XML","%Storage","%Exception","%Projection","%Dictionary","%Iterator","%TSQL","%Monitor","%BigData")
  set p="" for { set p=$order(^oddCOM(p)) quit:$extract(p)'="%"  set (p,pn)=$piece(p,".") set p=p_"."_$char(255) continue:$listfind(keep,pn)  write !,pn do $system.OBJ.DeletePackage(pn) kill ^%qMsg(p) }
  do $system.OBJ.DeletePackage("%SYS.ML")
  do $system.OBJ.DeletePackage("DeepSee")
  do $system.OBJ.DeletePackage("Interop")
  do $system.OBJ.DeletePackage("OAuth2")
  do $system.OBJ.DeletePackage("Report")
  do $system.OBJ.DeletePackage("DataMove")
  do $system.OBJ.DeletePackage("Net")
  do $system.OBJ.Import("/tmp/irislight/src/",,,,.list)
  set f = "" for { set f = $order(list(f)) quit:f=""  do $system.OBJ.Compile($piece(f,".",1,*-1), "ck") }
  kill ^%iKnow, ^%MV.ERRMSG, ^%MV.TERMDEFS
  do ##class(SYS.Database).Defragment(dbfile)
  do ##class(SYS.Database).CompactDatabase(dbfile, 100)
  do ##class(SYS.Database).FileCompact(dbfile, 0)
  do ##class(SYS.Database).ReturnUnusedSpace(dbfile, 0)
  set db=##class(SYS.Database).%OpenId(dbfile),db.ReadOnly=1,db.Size=0 do db.%Save()
  set dbfile = "/usr/irissys/mgr/"
  do ##class(SYS.Database).Defragment(dbfile)
  do ##class(SYS.Database).CompactDatabase(dbfile, 100)
  do ##class(SYS.Database).FileCompact(dbfile, 0)
  do ##class(SYS.Database).ReturnUnusedSpace(dbfile, 0)
  halt
EOF
  iris stop ${ISC_PACKAGE_INSTANCENAME} quietly
  mkdir -p /home/irisowner/tmp/mgr/user/
  mkdir -p /home/irisowner/tmp/mgr/iristemp/
  mkdir -p /home/irisowner/tmp/mgr/irisaudit/
  mkdir -p /home/irisowner/tmp/mgr/irislocaldata/
  rm -rf /usr/irissys/mgr/iristemp/*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/enslib
  rm -rf /usr/irissys/mgr/messages.log
  iris start ${ISC_PACKAGE_INSTANCENAME}
  cat <<"EOF" | iris session ${ISC_PACKAGE_INSTANCENAME} -U %SYS
  do ##class(SYS.Database).CreateDatabase("/home/irisowner/tmp/mgr/user/")
  do ##class(SYS.Database).CreateDatabase("/home/irisowner/tmp/mgr/iristemp/")
  do ##class(SYS.Database).CreateDatabase("/home/irisowner/tmp/mgr/irisaudit/")
  do ##class(SYS.Database).CreateDatabase("/home/irisowner/tmp/mgr/irislocaldata/")
  halt
EOF
  iris stop ${ISC_PACKAGE_INSTANCENAME} quietly
  cat /usr/irissys/mgr/messages.log
  mv /home/irisowner/tmp/mgr/user/IRIS.DAT /usr/irissys/mgr/user/
  mv /home/irisowner/tmp/mgr/iristemp/IRIS.DAT /usr/irissys/mgr/iristemp/
  mv /home/irisowner/tmp/mgr/irisaudit/IRIS.DAT /usr/irissys/mgr/irisaudit/
  mv /home/irisowner/tmp/mgr/irislocaldata/IRIS.DAT /usr/irissys/mgr/irislocaldata/
  rm -rf /home/irisowner/tmp
EOT

USER root
RUN <<EOT
  find ${ISC_PACKAGE_INSTALLDIR} -iname '*odbc*' -exec rm -rf {} \;
  find ${ISC_PACKAGE_INSTALLDIR} -iname '*xalan*' -exec rm -rf {} \;
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/dev
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/devuser
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/csp
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/dist
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/docs
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/fop
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/httpd
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/lib
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/ui
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/SNMP
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/ODBC*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/patrol
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/_LastGood_.cpf
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/iris.cpf_*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/CSPpwd
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/*iknow*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/*colorhtml*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/*opentelemetry*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/*odbc*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/ODBC*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/*python*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/*javascript*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/*mvbasic*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/*basic*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/bin/*.node
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/Locale/*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/journal/*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/journal.log
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/iboot.log
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/irisodbc.ini
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/ensinstall.log
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/SystemMonitor.log
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/python/*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/iristemp/*
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/IRIS.WIJ
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/*.isc
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/startup.last
  rm -rf ${ISC_PACKAGE_INSTALLDIR}/mgr/messages.log*
  touch ${ISC_PACKAGE_INSTALLDIR}/mgr/messages.log
  find ${ISC_PACKAGE_INSTALLDIR} -iname IRIS.DAT -exec ls -lah {} \;
  (cd ${IRISSYS} && for f in * ; do ([ -f ${ISC_PACKAGE_INSTALLDIR}/bin/$f ] && (rm -f $f && ln -s ${ISC_PACKAGE_INSTALLDIR}/bin/$f $f ) ) ; done)
  du -hd2 ${ISC_PACKAGE_INSTALLDIR}
EOT
USER 51773

ARG ORIGINAL_BASE
FROM ${ORIGINAL_BASE}

ENV ISC_PACKAGE_IRISGROUP=irisowner \
    ISC_PACKAGE_IRISUSER=irisowner \
    ISC_PACKAGE_MGRGROUP=irisowner \
    ISC_PACKAGE_MGRUSER=irisowner \
    IRISSYS=/home/irisowner/irissys \
    ISC_PACKAGE_INSTANCENAME=IRIS \
    ISC_PACKAGE_INSTALLDIR=/usr/irissys \
    PATH="$PATH:/home/irisowner/bin" \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN --mount=type=bind,from=base,src=/,dst=/tmp/base <<EOT
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y locales
  locale-gen en_US.UTF-8
  update-locale LANG=en_US.UTF-8
  # apt remove -y locales
  # apt autoremove -y
  apt-get clean && rm -rf /var/lib/apt/lists/*
  useradd -m $ISC_PACKAGE_MGRUSER --uid 51773
  sed -i /etc/environment -e "s%^PATH=.*$%PATH=\"$PATH\"%"
  echo ISC_PACKAGE_IRISGROUP="$ISC_PACKAGE_IRISGROUP" >> /etc/environment
  echo ISC_PACKAGE_IRISUSER="$ISC_PACKAGE_IRISUSER" >> /etc/environment
  echo ISC_PACKAGE_MGRGROUP="$ISC_PACKAGE_MGRGROUP" >> /etc/environment
  echo ISC_PACKAGE_MGRUSER="$ISC_PACKAGE_MGRUSER" >> /etc/environment
  echo ISC_PACKAGE_INSTANCENAME="$ISC_PACKAGE_INSTANCENAME" >> /etc/environment
  echo ISC_PACKAGE_INSTALLDIR="$ISC_PACKAGE_INSTALLDIR" >> /etc/environment
  echo IRISSYS="$IRISSYS" >> /etc/environment
  mkdir -p /home/${ISC_PACKAGE_MGRUSER}/bin
  mkdir -p ${ISC_PACKAGE_INSTALLDIR}
  mkdir -p ${IRISSYS}
  cp -R /tmp/base/home/${ISC_PACKAGE_MGRUSER}/bin/* /home/${ISC_PACKAGE_MGRUSER}/bin/
  cp -R /tmp/base${ISC_PACKAGE_INSTALLDIR}/* ${ISC_PACKAGE_INSTALLDIR}/
  cp -R /tmp/base${IRISSYS}/* ${IRISSYS}/
  cp -R /tmp/base/licenses /
  chown -R 51773:51773 /home/${ISC_PACKAGE_MGRUSER}/bin/
  chown -R 51773:51773 ${ISC_PACKAGE_INSTALLDIR}
  chown -R 51773:51773 ${IRISSYS}
  cp /tmp/base/tini / && chmod +x /tini
  cp /tmp/base/iris-main / && chmod +x /iris-main
  cp /tmp/base/irisHealth.sh / && chmod +x /irisHealth.sh
  du -hd 1 ${ISC_PACKAGE_INSTALLDIR}
EOT

USER 51773

WORKDIR /home/$ISC_PACKAGE_MGRUSER

EXPOSE 2188/tcp 1972/tcp
HEALTHCHECK --interval=1m --timeout=10s --start-period=1m --retries=3   CMD ["/irisHealth.sh"] || exit 1
ENTRYPOINT ["/tini", "--", "/iris-main"]
