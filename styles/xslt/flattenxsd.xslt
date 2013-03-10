<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:template match="xs:complexContent">
      <xsl:apply-templates select="xs:all">
				<xsl:with-param name="extensionattrs">
					<xsl:call-template name="extensionelements"/>
				</xsl:with-param>
			</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template name="extensionelements">
			<xsl:for-each select="//xs:complexType[@name=current()/xs:extension/@base]/xs:complexContent">
				<xsl:for-each select=".//xs:element">
					<xsl:copy>
						<xsl:attribute name="sourcetype" select="ancestor::xs:complexType/@name"/>
						<xsl:copy-of select="@*|*"/>
					</xsl:copy>
				</xsl:for-each>
				<xsl:call-template name="extensionelements"/>
			</xsl:for-each>
	</xsl:template>

	<xsl:template match="xs:all">
		<xsl:param name="extensionattrs"/>
    <xsl:copy>
			<xsl:copy-of select="$extensionattrs"/>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
	</xsl:template>

  <xsl:template match="@*|*|text()|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

