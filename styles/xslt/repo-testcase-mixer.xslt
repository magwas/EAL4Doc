<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="testplan" select="document('../../tmp/testplan.combined.xml')"/>

	<xsl:param name="tag"/>

	<xsl:template match="instance">
		<xsl:element name="{$tag}">
			<xsl:copy-of select="@name"/>
			<xsl:variable name="thetag" select="@name"/>
			<xsl:for-each select="$testplan//testcase">
				<xsl:variable name="testcase" select="."/>
				<xsl:for-each select="distinct-values(.//*[name()=$tag])">
					<xsl:if test="normalize-space(.) = $thetag">
						<testcase>
							<xsl:copy-of select="$testcase/@name"/>
							<xsl:copy-of select="$testcase/@type"/>
						</testcase>
					</xsl:if>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:element>
  </xsl:template>

  <xsl:template match="@*|*|text()|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

