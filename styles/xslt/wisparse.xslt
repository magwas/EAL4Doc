<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:template match="*"/>

	<xsl:variable name="neededtables">
		<a name="issues"/>
		<a name="changes"/>
		<a name="comments"/>
	</xsl:variable>

	<xsl:variable name="nt" select="$neededtables//@name"/>

  <xsl:template match="@*|root|column|table[@name = $nt]|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

