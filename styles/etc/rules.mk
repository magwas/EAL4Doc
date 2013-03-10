#!/usr/bin/make -f

tmp/inputs/start-stamp:
	mkdir -p tmp/inputs;touch tmp/inputs/start-stamp

clean:
	rm -f tmp/*

allclean:
	rm -rf tmp/*

pics: source/model.archimate
	mkdir pics;/opt/Archi/Archi -load $(PWD)/source/model.archimate -targetdir $(PWD) -runstyle $(PWD)/styles/etc/pictures.style -exit

tmp/inputs/impact_log.xml: tmp/svnvers
	styles/bin/impactlog

tmp/inputs/diff.xml: tmp/svnvers
	styles/bin/impactdiff

tmp/inputs/blaming.xml: tmp/svnvers tmp/inputs/impact.summary
	styles/bin/blamer <tmp/inputs/impact.summary >tmp/inputs/blaming.xml

tmp/blaming.xml: tmp/inputs/blaming.xml
	styles/bin/saxon -xsl:styles/xslt/blamingfilter.xslt -s:tmp/inputs/blaming.xml -o:tmp/blaming.xml

tmp/inputs/impact.summary: tmp/svnvers
	styles/bin/impactsummary

tmp/svnvers tmp/inputs/deploylist.xml: tmp/inputs/start-stamp
	styles/bin/svnvers

tmp/repo_access tmp/control.xml tmp/repo_ADV_ARC.1.1C.xml tmp/repo_ADV_ARC.1.2C.xml tmp/repo_ADV_ARC.1.3C.xml tmp/repo_ADV_ARC.1.4C.xml tmp/repo_ADV_ARC.1.5C.xml tmp/repo_Alrendszer.xml tmp/repo_CodeClass.xml tmp/repo_DataClass.xml tmp/repo_deploymentLocation.xml tmp/repo_Domain\ separation.xml tmp/repo_domain.xml tmp/repo_Elsődleges\ támadások.xml tmp/repo_hozzáférésvezérlés,\ authentikáció.xml tmp/repo_inicializációs\ eljárások.xml tmp/repo_Initialisation.xml tmp/repo_input\ validációs\ mechanizmusok.xml tmp/repo_input\ validation.xml tmp/repo_interfészek.xml tmp/repo_Komponens.xml tmp/repo_Másodlagos\ támadások.xml tmp/repo_modell.xml tmp/repo_Nem megbízható\ entitások.xml tmp/repo_Objective\ rationale.xml tmp/repo_objective.xml tmp/repo_Policy.xml tmp/repo_Security\ environment item.xml tmp/repo_SFR\ rationale.xml tmp/repo_SFR.xml tmp/repo_sourceLocation.xml tmp/repo_szeparációs\ szolgáltatások.xml tmp/repo_Threat.xml tmp/repo_ToeInterface.xml tmp/repo_TSF\ data.xml tmp/repo_tsfi.xml tmp/repo_tsf.xml tmp/repo_TSF.xml tmp/repo_védelmi\ mechanizmusok.xml tmp/repo_Assumption.xml: tmp/policy_flat.xsd
	styles/bin/saxon -xsl:styles/xslt/extractrepo.xslt -s:source/model.archimate xsd=../../tmp/policy_flat.xsd

tmp/policy_flat.xsd: tmp/policy.xsd
	styles/bin/saxon -xsl:styles/xslt/flattenxsd.xslt -s:tmp/policy.xsd -o:tmp/policy_flat.xsd

tmp/policy.xsd: source/model.archimate
	styles/bin/saxon -xsl:styles/xslt/mkpolicy.xslt -s:source/model.archimate -o:tmp/policy.xsd

tmp/bug-testcase.xml: tmp/bugs.xml tmp/testplan.combined.xml
	./styles/bin/saxon -xsl:styles/xslt/bug-testcase.xml -s:tmp/bugs.xml -o:tmp/bug-testcase.xml

tmp/missingfunc.xml: tmp/missingfunc.noxml tmp/inputs/doxy.freshestsrc.xml
	(echo "<missing>";cat tmp/missingfunc.noxml;echo "</missing>")|./styles/bin/saxon -xsl:styles/xslt/missingfunc.xslt -s:- -o:tmp/missingfunc.xml

freshestsrc/xml/index.xml tmp/errors.freshestsrc: tmp/svnvers
	styles/bin/prepare.doxyxml sourcecode freshestsrc

tmp/inputs/doxy.freshestsrc.xml: freshestsrc/xml/index.xml
	styles/bin/saxon -xsl:styles/xslt/mkdoxyxml.xslt -s:freshestsrc/xml/index.xml doxyxmldir=../../freshestsrc/xml/ htmldir=freshestsrc -o:tmp/inputs/doxy.freshestsrc.xml
	
latestcertified/xml/index.xml tmp/errors.latestcertified: tmp/svnvers
	styles/bin/prepare.doxyxml oldsource latestcertified

tmp/inputs/doxy.latestcertified.xml: latestcertified/xml/index.xml
	styles/bin/saxon -xsl:styles/xslt/mkdoxyxml.xslt -s:latestcertified/xml/index.xml doxyxmldir=../../latestcertified/xml/ htmldir=latestcertified -o:tmp/inputs/doxy.latestcertified.xml
	
$(rawplan): tmp/testplan_auto_%.xml: tmp/auto_%_raw.xml
	styles/bin/saxon -xsl:styles/xslt/autotestcase.xsl -s:$<  -o:$@

$(odtplan): tmp/testplan_%.xml: source/%.odt
	unzip -o $< -d testdoc;styles/bin/saxon -xsl:styles/xslt/odttestcase.xslt -s:testdoc/content.xml  -o:$@;rm -rf testdoc

tmp/testplan.combined.xml tmp/missingfunc.noxml: tmp/inputs/doxy.freshestsrc.xml $(testplans)
	styles/bin/saxon -xsl:styles/xslt/combine_testcases.xslt -s:tmp/inputs/doxy.freshestsrc.xml testcases=`echo $(testplans)|sed 's/^/ /;s/ tmp/,..\/..\/tmp/g'` -o:tmp/testplan.combined.xml 2>tmp/missingfunc.noxml

tmp/impact.step1.xml: tmp/inputs/impact.summary tmp/inputs/doxy.freshestsrc.xml tmp/inputs/impact_log.xml tmp/blaming.xml
	styles/bin/saxon -xsl:styles/xslt/impact_files.xslt -s:tmp/inputs/impact.summary -o:tmp/impact.step1.xml

tmp/impact.step2.xml: tmp/impact.step1.xml tmp/inputs/doxy.freshestsrc.xml tmp/inputs/impact_log.xml tmp/bug-testcase.xml tmp/bugs.xml
	styles/bin/saxon -xsl:styles/xslt/impact_2.xslt -s:tmp/impact.step1.xml -o:tmp/impact.step2.xml

tmp/impactlog.xml: tmp/inputs/impact_log.xml tmp/impact.step1.xml tmp/inputs/doxy.freshestsrc.xml
	styles/bin/saxon -xsl:styles/xslt/impactlog.xslt -s:tmp/inputs/impact_log.xml -o:tmp/impactlog.xml

tmp/impactlog.docbook: tmp/impactlog.xml
	styles/bin/saxon -xsl:styles/xslt/docbooklog.xslt -s:tmp/impactlog.xml -o:tmp/impactlog.docbook

tmp/sfr-testcase.xml: tmp/repo_SFR.xml tmp/testplan.combined.xml
	styles/bin/saxon -xsl:styles/xslt/repo-testcase-mixer.xslt -s:tmp/repo_SFR.xml -o:tmp/sfr-testcase.xml tag=sfr

tmp/rationale_sfr-testcase.xml tmp/err.sfr: tmp/sfr-testcase.xml
	styles/bin/saxon -xsl:styles/xslt/rationaletable.xslt -s:tmp/sfr-testcase.xml horizontal=sfr vertical=testcase -o:tmp/rationale_sfr-testcase.xml 2>&1 |tee tmp/err.sfr

tmp/tsf-testcase.xml: tmp/repo_tsf.xml tmp/testplan.combined.xml
	styles/bin/saxon -xsl:styles/xslt/repo-testcase-mixer.xslt -s:tmp/repo_tsf.xml -o:tmp/tsf-testcase.xml tag=tsf

tmp/rationale_tsf-testcase.xml tmp/err.tsf: tmp/tsf-testcase.xml
	styles/bin/saxon -xsl:styles/xslt/rationaletable.xslt -s:tmp/tsf-testcase.xml horizontal=tsf vertical=testcase -o:tmp/rationale_tsf-testcase.xml 2>&1 |tee tmp/err.tsf

tmp/tsfi-testcase.xml: tmp/repo_ToeInterface.xml tmp/testplan.combined.xml
	styles/bin/saxon -xsl:styles/xslt/repo-testcase-mixer.xslt -s:tmp/repo_ToeInterface.xml -o:tmp/tsfi-testcase.xml tag=tsfi

tmp/rationale_tsfi-testcase.xml tmp/err.tsfi: tmp/tsfi-testcase.xml
	styles/bin/saxon -xsl:styles/xslt/rationaletable.xslt -s:tmp/tsfi-testcase.xml horizontal=tsfi vertical=testcase -o:tmp/rationale_tsfi-testcase.xml 2>&1 |tee tmp/err.tsfi

tmp/tsfiface-testcase.xml: tmp/testplan.combined.xml tmp/inputs/doxy.freshestsrc.xml
	styles/bin/saxon -xsl:styles/xslt/tsfi-testcase.xslt -s:tmp/testplan.combined.xml -o:tmp/tsfiface-testcase.xml

tmp/rationale_tsfiface-testcase.xml tmp/err.tsfiface: tmp/tsfiface-testcase.xml
	styles/bin/saxon -xsl:styles/xslt/rationaletable.xslt -s:tmp/tsfiface-testcase.xml horizontal=testcase vertical=tsfiface simple=true -o:tmp/rationale_tsfiface-testcase.xml 2>&1 |tee tmp/err.tsfiface

tmp/component-testcase.xml: tmp/repo_Komponens.xml tmp/testplan.combined.xml
	styles/bin/saxon -xsl:styles/xslt/component-testcase.xslt -s:tmp/repo_Komponens.xml -o:tmp/component-testcase.xml

tmp/rationale_component-testcase.xml tmp/err.component: tmp/component-testcase.xml
	styles/bin/saxon -xsl:styles/xslt/rationaletable.xslt -s:tmp/component-testcase.xml horizontal=component vertical=testcase -o:tmp/rationale_component-testcase.xml 2>&1 |tee tmp/err.component

tmp/rationale_subsystem-testcase.xml tmp/err.subsystem: tmp/subsystem-testcase.xml
	styles/bin/saxon -xsl:styles/xslt/rationaletable.xslt -s:tmp/subsystem-testcase.xml horizontal=subsystem vertical=testcase -o:tmp/rationale_subsystem-testcase.xml 2>&1 |tee tmp/err.subsystem

tmp/subsystem-testcase.xml: tmp/repo_Alrendszer.xml tmp/testplan.combined.xml
	styles/bin/saxon -xsl:styles/xslt/subsystem-testcase.xslt -s:tmp/repo_Alrendszer.xml -o:tmp/subsystem-testcase.xml

tmp/errors.docbook: tmp/err.sfr tmp/err.tsf tmp/err.tsfi tmp/err.tsfiface tmp/err.component tmp/missingfunc.xml tmp/bugdoc.xml tmp/dependencies.docbook tmp/FSP.docbook  
	(echo "<errorlist>";cat tmp/dependencies.docbook tmp/FSP.docbook tmp/err.* tmp/missingfunc.xml;echo "</errorlist>")|grep -v '<?xml'| styles/bin/saxon -xsl:styles/xslt/errordoc.xslt -s:- -o:tmp/errors.docbook

tmp/errors.html: tmp/errors.docbook
	styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:tmp/errors.docbook -o:tmp/errors.html

tmp/impactlog.html: tmp/impactlog.docbook
	styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:tmp/impactlog.docbook -o:tmp/impactlog.html doxylinkbase="../freshestsrc/" difflinkbase="diff.html#" buglinkbase="bugdoc.html#"

tmp/testanal.docbook: tmp/rationale_subsystem-testcase.xml tmp/rationale_component-testcase.xml tmp/rationale_sfr-testcase.xml tmp/rationale_tsfi-testcase.xml tmp/rationale_tsf-testcase.xml tmp/rationale_tsfiface-testcase.xml
	styles/bin/saxon -xsl:styles/xslt/docbook.xslt -s:source/model.archimate part=testanal title="Tesztelemzés" noroot="true" targetdir=tmp -o:tmp/testanal.docbook

outputs/testanal.html.gz: tmp/testanal.html
	mkdir outputs;gzip <tmp/testanal.html >outputs/testanal.html.gz

tmp/testanal.html: tmp/testanal.docbook tmp/rationale_sfr-testcase.xml tmp/rationale_tsf-testcase.xml tmp/rationale_tsfi-testcase.xml tmp/rationale_tsfiface-testcase.xml tmp/rationale_component-testcase.xml tmp/rationale_subsystem-testcase.xml
	styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:tmp/testanal.docbook -o:tmp/testanal.html

tmp/diffandlines.xml: tmp/inputs/diff.xml tmp/inputs/doxy.freshestsrc.xml tmp/inputs/doxy.latestcertified.xml
	styles/bin/saxon -xsl:styles/xslt/diffandlines.xslt -s:tmp/inputs/diff.xml -o:tmp/diffandlines.xml

tmp/impact.byfilep.docbook tmp/diffp.docbook: tmp/impact.step2.xml tmp/diffandlines.xml
	styles/bin/saxon -xsl:styles/xslt/impact.byfile.xslt -s:tmp/impact.step2.xml -o:tmp/impact.byfilep.docbook rowlimit=30 diffile=diffp.docbook

tmp/impact.byfile.docbook tmp/diff.docbook: tmp/impact.step2.xml tmp/diffandlines.xml
	styles/bin/saxon -xsl:styles/xslt/impact.byfile.xslt -s:tmp/impact.step2.xml -o:tmp/impact.byfile.docbook rowlimit=0 diffile=diff.docbook

tmp/diff.html: tmp/diff.docbook
	styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:tmp/diff.docbook -o:tmp/diff.html buglinkbase="bugdoc.html#"

tmp/bugdoc.html: tmp/bugdoc.docbook
	styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:tmp/bugdoc.docbook -o:tmp/bugdoc.html doxylinkbase="../freshestsrc/" difflinkbase="diff.html#" loglinkbase="impactlog.html#"

tmp/impact.byfile.html: tmp/impact.byfile.docbook
	styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:tmp/impact.byfile.docbook -o:tmp/impact.byfile.html doxylinkbase="../freshestsrc/" difflinkbase="diff.html#" buglinkbase="bugdoc.html#"

outputs/impact.html.zip: outputs/testanal.html.gz tmp/diff.html tmp/bugdoc.html tmp/impact.byfile.html tmp/impactlog.html
	cd tmp; zip ../outputs/impact.html.zip diff.html bugdoc.html impact.byfile.html impactlog.html

outputs/impact.pdf.zip: outputs/testanal.html.gz tmp/impact.byfile.pdf tmp/diff.pdf tmp/bugdoc.pdf tmp/impactlog.pdf
	cd tmp; zip ../outputs/impact.pdf.zip impact.byfile.pdf diff.pdf bugdoc.pdf impactlog.pdf

tmp/impact.byfile.pdf tmp/diff.pdf tmp/bugdoc.pdf tmp/impactlog.pdf: tmp/impact.byfilep.docbook tmp/diffp.docbook tmp/impactbook.docbook tmp/bugdoc.docbook tmp/impactlog.docbook
	rm -f tmp/impact.byfile.pdf tmp/diff.pdf tmp/bugdoc.pdf tmp/impactlog.pdf;dblatex -x --maxdepth -x 1000000 -P doc.collab.show=0 -P latex.output.revhistory=0 -P doc.toc.show=0 -P set.book.num=all -P use.id.as.filename=1 tmp/impactbook.docbook -O tmp

tmp/impactbook.docbook: styles/lib/impactbook.docbook
	cp styles/lib/impactbook.docbook tmp/impactbook.docbook

tmp/bugdoc.xml: tmp/bugs.xml tmp/inputs/impact_log.xml tmp/impact.step1.xml tmp/inputs/doxy.freshestsrc.xml tmp/diffandlines.xml
	./styles/bin/saxon -xsl:styles/xslt/bugdoc.xslt -s:tmp/bugs.xml -o:tmp/bugdoc.xml

tmp/bugdoc.docbook: tmp/bugdoc.xml 
	./styles/bin/saxon -xsl:styles/xslt/docbookbug.xslt -s:tmp/bugdoc.xml -o:tmp/bugdoc.docbook

outputs/freshestsrc.zip: tmp/inputs/doxy.freshestsrc.xml
	zip -r outputs/freshestsrc.zip freshestsrc

tmp/toeplan.xml: tmp/inputs/doxy.freshestsrc.xml tmp/repo_tsf.xml source/model.archimate
	./styles/bin/saxon -xsl:styles/xslt/toeplan.xslt -s:tmp/repo_TSF.xml -o:tmp/toeplan.xml

#### old builder

outputs/oldbuild.zip: tmp/dependencies.html tmp/FSP.html tmp/configlist.html tmp/ST.html tmp/ToePlan.html tmp/LifeCycle.html tmp/architecture.html outputs/testanal.html.gz
	cd tmp; zip ../outputs/oldbuild.zip dependencies.html FSP.html configlist.html ST.html ToePlan.html LifeCycle.html architecture.html

tmp/inputs/archirich.xml: tmp/inputs/start-stamp source/model.archimate
	/opt/Archi/Archi -load $(PWD)/source/model.archimate -targetdir $(PWD) -runstyle $(PWD)/styles/etc/archirich.style -exit

tmp/policy_old.xml: tmp/inputs/archirich.xml generated/inputs/start-stamp
	./styles/bin/saxon -xsl:stylelib/metamodel.xslt -s:tmp/inputs/archirich.xml -o:generated/policy_old.xml target=generated/policy.xml targetdir=$(PWD)

generated/inputs/start-stamp: tmp/inputs/start-stamp
	ln -s tmp generated

tmp/sfpout.xml: tmp/policy_old.xml generated/inputs/start-stamp
	./styles/bin/saxon -xsl:styles/oldxsl/sfp.xslt -s:tmp/inputs/archirich.xml -o:tmp/sfpout.xml target=tmp/sfpout.xml targetdir=$(PWD) policy="tmp/policy_old.xml"

tmp/dependencies.docbook tmp/err.dependencies: tmp/inputs/archirich.xml tmp/inputs/doxy.freshestsrc.xml tmp/sfpout.xml
	./styles/bin/saxon -xsl:styles/oldxsl/toeplan.xslt -s:tmp/inputs/archirich.xml -o:tmp/dependencies.docbook targetdir=$(PWD) target="tmp/dependencies.docbook" keep="true" doxyfile="tmp/inputs/doxy.freshestsrc.xml" pathmarker="trunk"

tmp/dependencies.html: tmp/dependencies.docbook
	./styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:tmp/dependencies.docbook -o:tmp/dependencies.html

#<transform language="xslt" script="fsp.xslt" target="generated/FSP.docbook" keep="true" doxyfile="generated/doxy.xml">

tmp/FSP.docbook: tmp/inputs/archirich.xml tmp/inputs/doxy.freshestsrc.xml
	./styles/bin/saxon -xsl:styles/oldxsl/fsp.xslt -s:tmp/inputs/archirich.xml -o:tmp/FSP.docbook target="tmp/FSP.docbook" keep="true" doxyfile="tmp/inputs/doxy.freshestsrc.xml" targetdir=$(PWD)

tmp/FSP.html: tmp/FSP.docbook
	./styles/bin/saxon -xsl:styles/oldxsl/tohtml.xslt -s:tmp/FSP.docbook -o:tmp/FSP.html toc.section.depth="4"

#<transform language="xslt" script="configlist.xslt" target="generated/configlist.html" keep="true" doxyfile="generated/doxy.xml"/>
tmp/configlist.html: tmp/inputs/archirich.xml tmp/inputs/deploylist.xml
	./styles/bin/saxon -xsl:styles/oldxsl/configlist.xslt -s:tmp/inputs/archirich.xml -o:tmp/configlist.html doxyfile="tmp/inputs/doxy.freshestsrc.xml" targetdir=$(PWD)

#<transform language="xslt" script="onest.xslt" target="generated/ST.docbook" keep="true" part="ST" flat="false" noroot="true">
tmp/ST.docbook: tmp/inputs/archirich.xml  tmp/sfpout.xml
	./styles/bin/saxon -xsl:styles/oldxsl/onest.xslt -s:tmp/inputs/archirich.xml -o:tmp/ST.docbook keep="true" part="ST" flat="false" noroot="true" targetdir=$(PWD)

tmp/ST.html: tmp/ST.docbook
	./styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:tmp/ST.docbook -o:tmp/ST.html

#<transform language="xslt" script="onest.xslt" target="generated/ToePlan.docbook" keep="true" part="ToePlan" title="TOE architektúra terv">
generated/ToePlan.docbook: tmp/inputs/archirich.xml tmp/sfpout.xml
	./styles/bin/saxon -xsl:styles/oldxsl/onest.xslt -s:tmp/inputs/archirich.xml -o:generated/ToePlan.docbook target="generated/ToePlan.docbook" keep="true" part="ToePlan" title="TOE_architektúra_terv" targetdir=$(PWD)

tmp/ToePlan.html: generated/ToePlan.docbook
	./styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:generated/ToePlan.docbook -o:tmp/ToePlan.html


generated/LifeCycle.docbook: tmp/inputs/archirich.xml tmp/sfpout.xml
	./styles/bin/saxon -xsl:styles/oldxsl/onest.xslt -s:tmp/inputs/archirich.xml -o:generated/LifeCycle.docbook target="generated/LifeCycle.docbook" keep="true" part="LifeCycle" title="LifeCycle" targetdir=$(PWD)

tmp/LifeCycle.html: generated/LifeCycle.docbook
	./styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:generated/LifeCycle.docbook -o:tmp/LifeCycle.html

generated/architecture.docbook: tmp/inputs/archirich.xml tmp/sfpout.xml
	./styles/bin/saxon -xsl:styles/oldxsl/onest.xslt -s:tmp/inputs/archirich.xml -o:generated/architecture.docbook target="generated/architecture.docbook" keep="true" part="all" title="AllArchitecture" targetdir=$(PWD)

tmp/architecture.html: generated/architecture.docbook
	./styles/bin/saxon -xsl:styles/xslt/tohtml.xslt -s:generated/architecture.docbook -o:tmp/architecture.html


