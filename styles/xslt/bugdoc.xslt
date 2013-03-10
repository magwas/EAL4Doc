<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="doxy" select="document('../../tmp/inputs/doxy.freshestsrc.xml')"/>
	<xsl:variable name="diff" select="document('../../tmp/diffandlines.xml')"/>
	<xsl:variable name="log" select="document('../../tmp/inputs/impact_log.xml')"/>
	<xsl:variable name="step1" select="document('../../tmp/impact.step1.xml')"/>

	<xsl:template match="bug">
		<xsl:copy>
		<xsl:copy-of select="@id|@name"/>
		<xsl:variable name="bugid" select="@id"/>
		<xsl:variable name="bugmethods" select="$doxy//member[concat(@parent,'::',@name) = current()//method]/@id"/>
		<xsl:variable name="commits" select="
			distinct-values((
				$log//logentry[
					.//bug[@id=current()/@id] and
					not(some $t in msg/text() satisfies contains($t,'from revision'))
				]/@revision,.//commit/text())
			)"/>
		<xsl:for-each select="$log//logentry[@revision=$commits]">
			<xsl:copy-of select="."/>
		</xsl:for-each>
		
		<xsl:variable name="commitmethods" select="$step1//commit[@revision=$commits]/@id"/>
		<xsl:for-each select="$doxy//member[@id=distinct-values($commitmethods union $bugmethods)]">
			<xsl:copy>
				<xsl:copy-of select="@*|*"/>
				<xsl:variable name="diffs" select="$diff//member[@id=current()/@id]/ancestor::diff"/>
				<xsl:if test="count($diffs)=0">
					<problem type="Member not found" name="{@parent}::{@name}" table="bug #{$bugid}"/>
				</xsl:if>
				<xsl:for-each select="$diffs">
					<xsl:copy>
						<xsl:copy-of select="@*"/>
					</xsl:copy>
				</xsl:for-each>
			</xsl:copy>
		</xsl:for-each>
		<xsl:copy-of select=".//purpose|.//changes|.//tsfichange|.//logicchanges|.//securityimpact|.//testcase|.//removed|.//notoe"/>
		</xsl:copy>
	</xsl:template>

  <xsl:template match="*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

