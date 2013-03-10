<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	
  <xsl:template match="blaming">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()">
				<xsl:with-param name="maxstable" select="concat(@maxstable,'/')" tunnel="yes"/>
				<xsl:with-param name="module" select="@module" tunnel="yes"/>
			</xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="target">
		<xsl:param name="maxstable" tunnel="yes"/>
		<xsl:param name="module" tunnel="yes"/>
    <xsl:copy>
			<xsl:attribute name="path" select="tokenize(@path,$maxstable)[2]"/>
			<xsl:attribute name="module" select="$module"/>
      <xsl:apply-templates select="*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

