<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no" cdata-section-elements="diff"/>

	<xsl:variable name="root" select="/"/>

	<xsl:variable name="newdoxy" select="document('../../tmp/inputs/doxy.freshestsrc.xml')"/>
<!--	<xsl:variable name="log" select="document('../../tmp/inputs/impact_log.xml')"/>-->
	<xsl:variable name="blame" select="document('../../tmp/blaming.xml')"/>

  <xsl:template match="/">
	<foo>
  <xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
	</foo>
  </xsl:template>

	<xsl:template match="*">
		<xsl:message terminate="yes">
			No template for <xsl:value-of select="name()"/>
		</xsl:message>
	</xsl:template>

	<xsl:template match="commit">
		<xsl:param name="minstable" tunnel="yes"/>
		<xsl:param name="maxstable" tunnel="yes"/>
		<xsl:param name="module" tunnel="yes"/>
		<xsl:copy>
		<xsl:copy-of select="@revision"/>
		<xsl:variable name="commit" select="."/>
		<xsl:variable name="target" select="$commit/ancestor::target/@path"/>
		<xsl:copy-of select="$newdoxy//member[
				@location = $target and (
				if ( xs:integer(location[1]/@bodyend) = -1 )
					then
						(xs:integer(location[1]/@bodystart) eq xs:integer($commit/ancestor::entry/@line-number))
					else
						(xs:integer(location[1]/@bodystart) le xs:integer($commit/ancestor::entry/@line-number)) and
						(xs:integer(location[1]/@bodyend) ge xs:integer($commit/ancestor::entry/@line-number))
				)
			]/@id"/>
		<xsl:copy-of select="ancestor::target/@path"/>
		<xsl:copy-of select="ancestor::entry/@line-number"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="target/@path">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="path">
		<xsl:param name="minstable" tunnel="yes"/>
		<xsl:param name="maxstable" tunnel="yes"/>
		<xsl:for-each select="$blame//target[@path=(tokenize(current(),$minstable)[2])]">
			<xsl:copy>
      	<xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>

  <xsl:template match="impact">
		<xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()">
				<xsl:with-param name="minstable" select="concat(@latestcertified,'/')" tunnel="yes"/>
				<xsl:with-param name="maxstable" select="concat(@freshestsrc,'/')" tunnel="yes"/>
				<xsl:with-param name="module" select="@module" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:copy>
  </xsl:template>

  <xsl:template match="diff|paths|entry|@*|root|merged">
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
  </xsl:template>

  <xsl:template match="impact/@*|processing-instruction()|comment()">
		<xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</xsl:copy>
  </xsl:template>

</xsl:stylesheet>

