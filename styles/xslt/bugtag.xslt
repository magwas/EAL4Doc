<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:my="http://magwas.rulez.org/my"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:include href="unescape2.xslt" />

	<xsl:variable name="bugtags">
		<securityimpact/><level/>
		<purpose/>
		<notoe/>
		<commit/>
		<removed/>
		<changes/>
		<tsfichange/><from/><to/>
		<testcase/>
		<method/>
		<logicchanges/><file/>
	</xsl:variable>

	<xsl:variable name="root" select="/"/>

  <xsl:template match="thetext">
    <xsl:copy>
			<xsl:variable name="tc" select="replace(text(),'testcase - (.*)','&lt;testcase>$1&lt;/testcase>')"/>
			<xsl:variable name="meth" select="replace($tc,'method - (.*)','&lt;method>$1&lt;/method>')"/>
      <xsl:copy-of select="my:unescape($meth,$bugtags)"/>
    </xsl:copy>
	</xsl:template>

	<xsl:template match="root">
		<bugzilla>
		<xsl:for-each select="table[@name='issues']">
			<bug>
			<xsl:variable name="id" select="column[@name='issue_id']"/>
			<xsl:attribute name="id" select="$id"/>
			<xsl:attribute name="name" select="column[@name='issue_name']"/>
			<xsl:for-each select="//table[@name='changes' and column[@name='issue_id' and text()=$id]]/column[@name='change_id']/text()">
				<xsl:for-each select="$root//table[@name='comments' and column[@name='comment_id' and text()=current()]]">
					<comment>
						<xsl:variable name="c" select="string(column[@name='comment_text']/text())"/>
						<xsl:variable name="tc" select="replace($c,'testcase - (.*)','&lt;testcase>$1&lt;/testcase>')"/>
						<xsl:variable name="meth" select="replace($tc,'method - (.*)','&lt;method>$1&lt;/method>')"/>
			      <xsl:copy-of select="my:unescape($meth,$bugtags)"/>
					</comment>
				</xsl:for-each>
			</xsl:for-each>
			</bug>
		</xsl:for-each>
		</bugzilla>
	</xsl:template>

	<xsl:template match="bug">
    <xsl:copy>
			<xsl:attribute name="id" select="bug_id"/>
			<xsl:attribute name="name" select="short_desc"/>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
	</xsl:template>
  <xsl:template match="@*|*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

