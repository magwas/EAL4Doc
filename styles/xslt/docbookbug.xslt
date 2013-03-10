<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:my="http://magwas.rulez.org/my"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:function name="my:vle">
		<xsl:param name="name"/>
		<xsl:param name="value"/>
		<varlistentry>
			<term><xsl:copy-of select="$name"/></term>
			<listitem><xsl:copy-of select="$value"/></listitem>
		</varlistentry>
	</xsl:function>

	<xsl:function name="my:vleil">
		<xsl:param name="name"/>
		<xsl:param name="value"/>
		<xsl:if test="count($value)">
		<xsl:variable name="tc">
			<itemizedlist>
			<xsl:apply-templates select="$value"/>
			</itemizedlist>
		</xsl:variable>
		<varlistentry>
			<term><xsl:copy-of select="$name"/></term>
			<listitem><xsl:copy-of select="$tc"/></listitem>
		</varlistentry>
		</xsl:if>
	</xsl:function>

	<xsl:template match="bug">
	<xsl:if test="(member|removed) and not(notoe)">
	<chapter><title><xsl:value-of select="concat(@id,': ',@name)"/></title>
		<variablelist><anchor id="bug_{@id}" />
			<xsl:copy-of select="my:vle('A változtatás célja',purpose/text())"/>
			<xsl:copy-of select="my:vle('Elvégzett változtatások',changes[last()]/text())"/>
			<xsl:copy-of select="my:vleil('Tesztesetek',testcase)"/>
			<xsl:if test="tsfichange">
				<xsl:variable name="tc">
					<xsl:apply-templates select="tsfichange"/>
				</xsl:variable>
				<xsl:copy-of select="my:vle('TSFI változás:',$tc)"/>
			</xsl:if>
			<xsl:if test="logicchanges">
				<xsl:variable name="tc">
					<xsl:apply-templates select="logicchanges"/>
				</xsl:variable>
				<xsl:copy-of select="my:vle('Játéklogika változás:',$tc)"/>
			</xsl:if>
			<xsl:variable name="tc">
				<xsl:apply-templates select="securityimpact[last()]"/>
			</xsl:variable>
			<xsl:copy-of select="my:vle('biztonsági hatás',$tc)"/>
			<xsl:variable name="sectags">
			<xsl:for-each select="distinct-values(.//tsfi)">
				<listitem>
				<xsl:value-of select="concat('TOE Interface:',.,',')"/>
				</listitem>
			</xsl:for-each>
			<xsl:for-each select="distinct-values(.//tsf)">
				<listitem>
				<xsl:value-of select="concat('tsf:',.,',')"/>
				</listitem>
			</xsl:for-each>
			<xsl:for-each select="distinct-values(.//sfr)">
				<listitem>
				<xsl:value-of select="concat('SFR:',.,',')"/>
				</listitem>
			</xsl:for-each>
			</xsl:variable>
			<xsl:if test="count($sectags/listitem)">
				<para>
				(Potenciálisan érintett biztonsági elemek:
				<itemizedlist>
					<xsl:copy-of select="$sectags"/>
				</itemizedlist>
				)</para>
			</xsl:if>
			<xsl:copy-of select="my:vleil('Érintett metódusok',member)"/>
			<xsl:copy-of select="my:vleil('Eltávolított fájlok',removed)"/>
			<xsl:copy-of select="my:vleil('Commit lista',logentry)"/>
		</variablelist>
	</chapter>
	</xsl:if>
	</xsl:template>

	<xsl:template match="member">
		<listitem>
		<ulink role="doxylink" url="{@url}"><xsl:value-of select="concat(@parent,'::',@name)"/></ulink>( <link role="difflink" linkend="{@location}"><xsl:value-of select="@location"/></link>)
		<xsl:for-each select="diff">
			(<link role="difflink" linkend="{../@location}:{@newfrom}"><xsl:value-of select="concat(../@location,':',@newfrom,'-',@newfrom + @newlen)"/></link>)
		</xsl:for-each>
		</listitem>
	</xsl:template>

	<xsl:template match="removed">
		<listitem>
		<link role="difflink" linkend="{.}"><xsl:value-of select="."/></link>
		</listitem>
	</xsl:template>

	<xsl:template match="logentry">
		<listitem>
		<link role="loglink" linkend="{@revision}"> <xsl:value-of select="@revision"/></link>
		</listitem>
	</xsl:template>

	<xsl:template match="securityimpact">
		<para>
		<variablelist>
		<xsl:copy-of select="my:vle('érintettség szintje:',level/text())"/>
		</variablelist>
		<xsl:value-of select="text()"/>
		</para>
	</xsl:template>

	<xsl:template match="logicchanges">
		<para>
		<variablelist>
		<xsl:copy-of select="my:vle('érintett file:',file/text())"/>
		</variablelist>
		<xsl:value-of select="text()"/>
		</para>
	</xsl:template>

	<xsl:template match="tsfichange">
		<para>
		<variablelist>
		<xsl:copy-of select="my:vle('régi állapot',from/text())"/>
		<xsl:copy-of select="my:vle('új állapot',to/text())"/>
		</variablelist>
		<xsl:value-of select="text()"/>
		</para>
	</xsl:template>

	<xsl:template match="bugzilla">
	<book id="bugdoc"><title>Hibajegyek</title>
      <xsl:apply-templates select="*"/>
	</book>
	</xsl:template>

	<xsl:template match="testcase">
		<listitem>
			<xsl:value-of select="."/>
		</listitem>
	</xsl:template>

  <xsl:template match="*|processing-instruction()|comment()">
    <xsl:copy>
      <xsl:apply-templates select="*"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>

