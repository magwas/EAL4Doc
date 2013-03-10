<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

	<xsl:template match="logentry">
		<xsl:value-of select="@revision"/>
	</xsl:template>
  <xsl:template match="@*|*|processing-instruction()|comment()">
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
  </xsl:template>

</xsl:stylesheet>

