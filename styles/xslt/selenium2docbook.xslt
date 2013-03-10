<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="posneg">
	<msg from="Pozitív" to="Positive"/>
	<msg from="Negatív" to="Negative"/>
	</xsl:variable>

	<xsl:template match="tests">
	<article>
<!-- FIXME generate this -->
	<articleinfo>
   <title>Automated test documentation</title>
  <author><firstname>Lajos</firstname><surname>Moldvai</surname></author>
  <revhistory>
     <revision>
				<author><firstname>lajos</firstname></author>
        <revnumber>r3414</revnumber>
        <date>2012-09-06T10:21:23.600803Z</date>
        <revremark>Indulás, kb. 30 teszteset, mind a local mind a tax esetében.</revremark>
     </revision>
  </revhistory>
</articleinfo>

	<title>Automated test documentation</title>
      <xsl:apply-templates select="*"/>
	</article>
	</xsl:template>

	<xsl:template match="TESTCASE">
		<xsl:variable name="testcase" select="."/>
	<section><title><xsl:value-of select="Name"/></title>
			<para><xsl:value-of select="$posneg//msg[@from=current()/PozNeg]/@to"/> test case</para>
			<para>Anticipated outcome: <xsl:value-of select="Should"/></para>
			<para>Mode of testing: <xsl:value-of select="Mode"/></para>
			<para>test succesful?: <xsl:value-of select="Result"/></para>
			<xsl:if test=".//Function">
				<para>Tested functions:
					<itemizedlist>
						<xsl:for-each select=".//Function">
							<listitem><xsl:value-of select="."/></listitem>
						</xsl:for-each>
					</itemizedlist>
				</para>
			</xsl:if>
			<xsl:variable name="numshots" select="count(Image)"/>
			<xsl:if test="$numshots">
			<para>Screenshots (<xsl:value-of select="$numshots"/>)
				<xsl:for-each select="Image">
					<xsl:variable name="broken" select="tokenize(.,'\\')"/>
					<figure pgwide="1">
						<title><xsl:value-of select="concat($testcase/Name,' #',position())"/></title>
						<mediaobject>
							<imageobject>
								<imagedata width="80%" fileref="{concat($broken[last()-1],'/',$broken[last()])}"/>
							</imageobject>
						</mediaobject>
					</figure>
				</xsl:for-each>
			</para>
			</xsl:if>
			<xsl:if test="TestIO">
				<para> Teszt I/O:
				<xsl:apply-templates select="TestIO/*"/>
				</para>
			</xsl:if>
			
	</section>
	</xsl:template>

	<xsl:template match="Input">
		<para>-><code><xsl:value-of select="."/></code></para>
	</xsl:template>

	<xsl:template match="Output">
		<para>&lt;-<code><xsl:value-of select="."/></code></para>
	</xsl:template>

  <xsl:template match="@*|*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

