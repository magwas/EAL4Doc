<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="step1" select="document('../../tmp/impact.step1.xml')"/>
	<xsl:variable name="doxy" select="document('../../tmp/inputs/doxy.freshestsrc.xml')"/>
	<xsl:variable name="bugs" select="document('../../tmp/bugs.xml')"/>

	<xsl:variable name="root" select="/"/>

	<xsl:template match="/">
		<impactlog>
		<xsl:for-each select="distinct-values($step1//commit/@revision)">
			<xsl:apply-templates select="($root//logentry[@revision=current()])[1]"/>
		</xsl:for-each>
		</impactlog>
  </xsl:template>

	<xsl:template match="bug">
		<xsl:copy>
			<xsl:copy-of select="$bugs//bug[@id=current()/@id]/@*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="logentry">
		<xsl:copy>
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
			<xsl:for-each select="distinct-values($step1//commit[@revision=current()/@revision]/@id)">
				<xsl:copy-of select="$doxy//member[@id=current()]"/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*|*|processing-instruction()|comment()">
		<xsl:copy>
		<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</xsl:copy>
	</xsl:template>


</xsl:stylesheet>

