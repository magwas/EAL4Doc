<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="doxy" select="document('../../tmp/inputs/doxy.freshestsrc.xml')"/>
	<xsl:variable name="bugs" select="document('../../tmp/bugs.xml')"/>
	<xsl:variable name="log" select="document('../../tmp/inputs/impact_log.xml')"/>
	<xsl:variable name="testcase" select="document('../../tmp/bug-testcase.xml')"/>

	<xsl:template match="target">
		<xsl:variable name="target" select="."/>
		<xsl:copy>
			<xsl:copy-of select="@path"/>
			<xsl:variable name="members">
				<xsl:variable name="buggedmethods" select="$doxy//member[(concat(@parent,'::',@name) = $testcase//method) and (@location = $target/@path)]"/>
				<xsl:for-each select="distinct-values(commit/@id union $buggedmethods/@id)">
					<module id="{.}">
					<xsl:variable name="memberid" select="."/>
					<xsl:copy-of select="$doxy//member[@id=$memberid]"/>
					<xsl:for-each select="distinct-values($target/commit[@id=$memberid]/@revision)">
						<commit revision="{.}"/>
					</xsl:for-each>
					<xsl:variable name="current" select="($doxy//member[@id=current()])[1]"/>
<!--
<xsl:message>
	P<xsl:value-of select="$thepath"/>'
	current<xsl:value-of select="$doxy//member[@id=current()]/@id"/>'
	P<xsl:value-of select="string(.)"/>'
	buggedm<xsl:value-of select="$buggedmethods/@id"/>'
	-<xsl:value-of select="$testcase//method/text()"/>

	+<xsl:value-of select="concat($current/@parent,'::',$current/@name)"/>
</xsl:message>
-->
					<xsl:for-each select="$testcase//method[text()=concat($current/@parent,'::',$current/@name)]/@bugid">
						<bug id="{.}"/>
					</xsl:for-each>
					</module>
				</xsl:for-each>
			</xsl:variable>
			<xsl:variable name="allrevs" select="commit/@revision"/>
			<xsl:variable name="foundrevs" select="$members//commit/@revision"/>
			<xsl:variable name="remaining" select="distinct-values($allrevs except $foundrevs)"/>
			<xsl:if test="count($remaining)">
				<xsl:variable name="uc">
					<unboundcommits>
						<xsl:for-each select="distinct-values($allrevs except $foundrevs)">
							<commit revision="{.}"/>
						</xsl:for-each>
					</unboundcommits>
				</xsl:variable>
				<xsl:apply-templates select="$uc"/>
			</xsl:if>
			<xsl:apply-templates select="$members"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="bug">
    <xsl:copy>
			<xsl:copy-of select="$bugs//bug[@id=current()/@id]/@*"/>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
			<xsl:copy-of select="$testcase//testcase[@bugid=current()/@id]"/>
			<xsl:copy-of select="$bugs//bug[@id=current()/@id]//securityimpact"/>
			<xsl:copy-of select="$bugs//bug[@id=current()/@id]//tsfichange"/>
			<xsl:copy-of select="$bugs//bug[@id=current()/@id]//logicchanges"/>
    </xsl:copy>
	</xsl:template>
	
  <xsl:template match="commit">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
			<xsl:apply-templates select="$log//logentry[@revision=current()/@revision]"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

