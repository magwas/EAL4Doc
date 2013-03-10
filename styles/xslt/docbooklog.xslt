<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>


	<xsl:template match="logentry">
		<chapter>
			<title><anchor id="{@revision}"/><xsl:value-of select="concat(@revision,' - ', date)"/></title>
			<para>
				<xsl:value-of select="msg"/>
			</para>
			<xsl:variable name="bugs">
				<xsl:for-each select=".//bug">
					<listitem>
						<link role="buglink" linkend="bug_{@id}"> <xsl:value-of select="@id"/>: <xsl:value-of select="@name"/> </link>
					</listitem>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="count($bugs/listitem)">
				<para> Hibajegyek:
					<itemizedlist>
						<xsl:copy-of select="$bugs"/>
					</itemizedlist>
				</para>
			</xsl:if>
			<xsl:variable name="methods">
				<xsl:for-each select=".//member">
					<listitem>
						<ulink role="doxylink" url="{@url}"><xsl:value-of select="concat(@parent,'::',@name)"/></ulink>(<link role="difflink" linkend="{@location}">Diff</link>)
					</listitem>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="count($methods/listitem)">
				<para> Módosult metódusok:
					<itemizedlist>
						<xsl:copy-of select="$methods"/>
					</itemizedlist>
				</para>
			</xsl:if>
		</chapter>
	</xsl:template>

	<xsl:template match="impactlog">
		<book id="impactlog">
			<title>Detailed change log</title>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
		</book>
	</xsl:template>

  <xsl:template match="@*|*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

