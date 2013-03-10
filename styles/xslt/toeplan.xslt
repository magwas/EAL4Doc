<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:my="http://magwas.rulez.org/my"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="doxy" select="/"/>

	<xsl:variable name="tsf" select="document('../../tmp/repo_tsf.xml')"/>
	<xsl:variable name="model" select="document('../../source/model.archimate')"/>

	<xsl:template match="instance[contains(@name,'TSF')]">
		<TSF>
			<xsl:copy-of select="@name"/>
			<xsl:apply-templates select="$tsf//instance[@id=current()/ref[@name='tsf']/value/@id]" mode="tsf"/>
		</TSF>
	</xsl:template>

	<xsl:function name="my:digtsf">
		<xsl:param name="member"/>
		<xsl:copy-of select="my:digtsf($member,())"/>
	</xsl:function>

	<xsl:function name="my:digtsf">
		<xsl:param name="member"/>
		<xsl:param name="sofar"/>
<!--
		<xsl:message>
		<xsl:copy-of select="$member//references/@refid"/>
		<xsl:copy-of select="$member/@name"/>
		<xsl:copy-of select="$member/@id"/>
		</xsl:message>
		<xsl:variable name="referenced" select="trace(distinct-values($member//references/@refid[not(.= trace($sofar,'sofar'))]),'referenced')"/>
-->
		<xsl:variable name="referenced" select="distinct-values($member//references/@refid[not(.= $sofar)])"/>
		<xsl:copy-of select="$member//(tsf|tsfi) ,
			for $i
				in $referenced
				return
				my:digtsf($doxy//member[@id=$i],($referenced , $sofar))
		"/>
	</xsl:function>

	<xsl:template match="member">
		<xsl:copy>
		<xsl:copy-of select="@*|.//contract|.//argsstring|.//simplesect[@kind='return']|.//briefdescription|.//error|.//audit"/>
		<xsl:copy-of select="my:digtsf(.)"/>
	<!-- FIXME: component and location
		<xsl:variable name="component" select="$components[property[@key='sourceLocation' and contains($path,@value)]]"/>
		<xsl:variable name="subsystem" select="$subsystems[@id=$archiobjs//archimate:CompositionRelationship[@target=$component/@id]/@source]/@name"/>
	-->
		</xsl:copy>
	</xsl:template>

	<xsl:template match="member" mode="digtsf">
		<xsl:param name="sofar"><id>0</id></xsl:param><!--easier than check for the no id so far case-->
		<xsl:variable name="cur" select="."/>
		<xsl:variable name="myfar">
			<xsl:copy-of select=".//tsf|.//sfr"/>
			<id><xsl:value-of select="@id"/></id>
		</xsl:variable>
		<xsl:copy-of select="$myfar"/>
	</xsl:template>


	<xsl:template match="/">
		<toeplan>
<!--
			<xsl:apply-templates select=".//instance"/>
			<xsl:for-each select=".//member[count(.//references)=2 and .//tsf]/@name">
-->
			<xsl:apply-templates select=".//member"/>
		</toeplan>
	</xsl:template>

</xsl:stylesheet>
