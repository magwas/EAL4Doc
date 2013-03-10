<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="testplan" select="document('../../tmp/testplan.combined.xml')"/>

	<xsl:variable name="root" select="/"/>

<!--
	<xsl:template match="member[.//tsfi]">
		<tsfiface>
			<xsl:variable name="name" select="concat(@parent,'::',@name)"/>
			<xsl:variable name="id" select="@id"/>
			<xsl:attribute name="name" select="$name"/>
			<xsl:attribute name="id" select="$id"/>
			<xsl:for-each select="$testplan//testcase/tested/member[@id=$id]">
				<testcase>
				<xsl:copy-of select="../../@name"/>
				<xsl:copy-of select="../../@type"/>
				</testcase>
			</xsl:for-each>
		</tsfiface>
  </xsl:template>
-->

  <xsl:template match="/">
		<collection>
			<xsl:for-each select="distinct-values(//member[.//tsfi]/@id)">
				<xsl:variable name="member" select="($root//member[@id=current()])[1]"/>
<!--
				<xsl:message select="." terminate="no"/>
				<xsl:message select="$member" terminate="yes"/>
-->
				<tsfiface>
					<xsl:variable name="name" select="concat($member/@parent,'::',$member/@name)"/>
					<xsl:variable name="id" select="$member/@id"/>
					<xsl:attribute name="name" select="$name"/>
					<xsl:attribute name="id" select="$id"/>
					<xsl:for-each select="$testplan//testcase/tested/member[@id=$id]">
						<testcase>
						<xsl:copy-of select="../../@name"/>
						<xsl:copy-of select="../../@type"/>
						</testcase>
					</xsl:for-each>
				</tsfiface>
			</xsl:for-each>
		</collection>
  </xsl:template>

  <xsl:template match="@*|*|text()|processing-instruction()|comment()">
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
  </xsl:template>

</xsl:stylesheet>

