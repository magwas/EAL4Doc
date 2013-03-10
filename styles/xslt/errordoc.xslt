<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:my="http://magwas.rulez.org/my"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="bugdoc" select="document('../../tmp/bugdoc.xml')"/>

	<xsl:function name="my:itemcount">
		<xsl:param name="this"/>
		<xsl:param name="itemname"/>
		<entry>
		<xsl:value-of select="count($this//*[name()=$itemname])"/>
		</entry>
	</xsl:function>

	<xsl:template match="/">
		<book>
			<section>
			<title>problems</title>
			<itemizedlist>
      <xsl:apply-templates select="*"/>
			</itemizedlist>
			</section>
			<section>
				<title>Bug state</title>
				<table>
					<title>Bug state</title>
					<tgroup cols="8">
					<thead>
						<row>
							<entry># - name</entry>
							<entry>methodcount</entry>
							<entry>changes</entry>
							<entry>purpose</entry>
							<entry>tsfichange</entry>
							<entry>testcase</entry>
							<entry>logicchange</entry>
							<entry>securityimpact</entry>
							<entry>tsfichange idézet</entry>
							<entry>logicchange idézet</entry>
						</row>
					</thead>
					<tbody>
						<xsl:for-each select="$bugdoc//bug[.//member and not(.//notoe)]">
							<row>
								<entry><xsl:value-of select="concat(@id,' - ', @name)"/></entry>
								<xsl:copy-of select="my:itemcount(.,'member')"/>
								<xsl:copy-of select="my:itemcount(.,'changes')"/>
								<xsl:copy-of select="my:itemcount(.,'purpose')"/>
								<xsl:copy-of select="my:itemcount(.,'tsfichange')"/>
								<xsl:copy-of select="my:itemcount(.,'testcase')"/>
								<xsl:copy-of select="my:itemcount(.,'logicchanges')"/>
								<xsl:copy-of select="my:itemcount(.,'securityimpact')"/>
								<entry>
									<xsl:if test=".//tsfichange">
										<itemizedlist>
									<xsl:for-each select=".//tsfichange">
										<listitem>
										<xsl:value-of select="from"/> -> <xsl:value-of select="to"/>
										</listitem>
									</xsl:for-each>
										</itemizedlist>
									</xsl:if>
								</entry>
								<entry>
									<xsl:if test=".//logicchanges">
										<itemizedlist>
									<xsl:for-each select=".//logicchanges">
										<listitem>
										<xsl:value-of select="."/>
										</listitem>
									</xsl:for-each>
										</itemizedlist>
									</xsl:if>
								</entry>
							</row>
						</xsl:for-each>
					</tbody>
					</tgroup>
				</table>

			</section>
		</book>
	</xsl:template>

	<xsl:template match="problem">
		<listitem>
			<xsl:value-of select="@type"/>: <xsl:value-of select="@table"/> / <xsl:value-of select="@name"/>
		</listitem>
	</xsl:template>

	<xsl:template match="alternative">
		<listitem>
			'<xsl:value-of select="@function"/>'
		</listitem>
	</xsl:template>
	<xsl:template match="missingfunc">
		<listitem>
			<para>
			missing function: '<xsl:value-of select="@name"/>'
			</para>
			<para>
			possible alternatives:
			</para>
			<itemizedlist>
      	<xsl:apply-templates select="*"/>
			</itemizedlist>
		</listitem>
	</xsl:template>

  <xsl:template match="@*|*|processing-instruction()|comment()">
      <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()"/>
  </xsl:template>

</xsl:stylesheet>

