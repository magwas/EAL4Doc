<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="root" select="/"/>

	<xsl:variable name="doxy" select="document('../../tmp/inputs/doxy.freshestsrc.xml')"/>

  <xsl:template match="/">
		<xsl:for-each select="distinct-values(//nocode/@function)">
			<xsl:variable name="fnname" select="tokenize(.,'::')[last()]"/>
			<xsl:variable name="stem" select="if(contains($fnname,'(')) then substring-before($fnname,'(') else $fnname"/>
			<missingfunc>
				<xsl:attribute name="name" select="."/>
				<xsl:for-each select="$doxy//member[contains(@name,$stem)]">
					<alternative>
						<xsl:attribute name="function" select="concat(@parent,'::',@name)"/>
					</alternative>
				</xsl:for-each>
			</missingfunc>
		</xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

