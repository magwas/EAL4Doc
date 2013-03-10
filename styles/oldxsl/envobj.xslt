<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:archimate="http://www.bolton.ac.uk/archimate"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:structured="http://magwas.rulez.org/my"
	>

<xsl:template name="envobj">
	<xsl:variable name="arch" select="/"/>
	<xsl:variable name="envs" select="//archimate:Value[not(fn:contains(@name,'copy')) and (starts-with(@name,'P.') or starts-with(@name,'A.'))]"/>
	<table class="rationale">
		<tr>
				<th/>
			<xsl:for-each select="$envs">
				<th> <emphasis role="rotated"><xsl:value-of select="@name"/></emphasis></th>
			</xsl:for-each>
		</tr>
		<xsl:for-each select="//archimate:Value[starts-with(@name,'O.') or starts-with(@name,'OE.')]">
			<tr>
				<xsl:variable name="cur" select="."/>
					<td><xsl:value-of select="$cur/@name"/></td>
				<xsl:for-each select="$envs">
					<td><!--
							<xsl:value-of select="$cur/@name"/>, <xsl:value-of select="$cur/@id"/>,
							<xsl:value-of select="current()/@name"/>.<xsl:value-of select="current()/@id"/>.-->
						<xsl:if test="//archimate:AssociationRelationship[@target=$cur/@id and @source=current()/@id]">
							X
						</xsl:if>
					</td>
				</xsl:for-each>
			</tr>
		</xsl:for-each>
	</table>
	<table>
	<xsl:for-each select="//archimate:Value[not(fn:contains(@name,'copy')) and (starts-with(@name,'P.') or starts-with(@name,'A.'))]">
		<xsl:sort select="./@name"/>
<!--
			<xsl:message><xsl:value-of select="@name"/></xsl:message>
-->
			<tr> <td class="starter"> <para><xsl:value-of select="@name"/></para>
			<para><xsl:apply-templates select="documentation"/> </para>
			<xsl:variable name="Oid" select="@id"/>
			<xsl:variable name="meanings">
			<xsl:for-each select="//archimate:Value[@id = //archimate:AssociationRelationship[@source=$Oid]/@target]">
				<enforcing>
					<xsl:copy-of select="./@name"/>
					<xsl:apply-templates select="//archimate:Meaning[@id=//archimate:AssociationRelationship[@source=current()/@id]/@target]/documentation"/>
				</enforcing>
			</xsl:for-each>
			<xsl:for-each select="//archimate:Meaning[@id = //archimate:AssociationRelationship[@source=$Oid]/@target]">
				<enforcing>
					<xsl:copy-of select="//archimate:Value[@id=//archimate:AssociationRelationship[@source=current()/@id]/@target]/@name"/>
					<xsl:apply-templates select="./documentation"/>
				</enforcing>
			</xsl:for-each>
			</xsl:variable>
<!--
<xsl:message>
			<xsl:copy-of select="$meanings"/>
</xsl:message>
-->
			<xsl:choose>
				<xsl:when test="starts-with(@name,'P.')">
			A szabályt teljesítő biztonsági célok:
				</xsl:when>
				<xsl:when test="starts-with(@name,'A.')">
			A feltételezés az alábbi környezeti biztonsági célokra képezhető le:
				</xsl:when>
			</xsl:choose>
			<itemizedlist>
			<xsl:for-each select="$meanings/enforcing[@name]">
<!--
<xsl:message>
<a>
	.<xsl:copy-of select="."/>,
	.<xsl:value-of select="current()/@name"/>:
	.<xsl:copy-of select="$arch//archimate:Value[@name=current()/@name]"/>/
</a>
</xsl:message>
-->
				<listitem>
					<xsl:value-of select="./@name"/> - 
					<xsl:choose>
					<xsl:when test="string(.)">
						<xsl:value-of select="."/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$arch//archimate:Value[@name=current()/@name]"/>
					</xsl:otherwise>
					</xsl:choose>
				</listitem>
			</xsl:for-each>
			</itemizedlist>
			</td></tr>
		</xsl:for-each>
	</table>
</xsl:template>

</xsl:stylesheet>

