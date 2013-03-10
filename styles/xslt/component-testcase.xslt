<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="testplan" select="document('../../tmp/testplan.combined.xml')"/>

	<xsl:template match="instance">
		<component>
			<xsl:copy-of select="@name"/>
			<xsl:for-each select="ref[@name='sourceLocation']/value/@name">
				<!--<xsl:value-of select="."/>-->
				<xsl:for-each select="$testplan//testcase/tested/member[contains(@location,current())]">
					<testcase>
					<xsl:copy-of select="../../@name"/>
					<xsl:copy-of select="../../@type"/>
					</testcase>
				</xsl:for-each>
			</xsl:for-each>
		</component>
  </xsl:template>

  <xsl:template match="@*|*|text()|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

