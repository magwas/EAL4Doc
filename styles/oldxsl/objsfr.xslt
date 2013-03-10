<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:archimate="http://www.bolton.ac.uk/archimate"
xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:structured="http://magwas.rulez.org/my"
>

<xsl:template name="objsfr">
	<xsl:variable name="envs" select="//archimate:Value[starts-with(@name,'O.')]"/>
	<xsl:variable name="meanings">
		<xsl:for-each select="$envs">
			<obj>
				<xsl:copy-of select="@name"/>
				<xsl:copy-of select="@id"/>
				<xsl:copy-of select="documentation"/>
				<xsl:variable name="Oid" select="@id"/>
				<xsl:for-each select="//archimate:ApplicationService[@id = //archimate:AssociationRelationship[@source=$Oid]/@target]">
					<enforcing>
						<xsl:copy-of select="./@name"/>
						<xsl:copy-of select="//archimate:Meaning[@id=//archimate:AssociationRelationship[@source=current()/@id]/@target]/documentation"/>
						<xsl:call-template name="supporting"/>
					</enforcing>
				</xsl:for-each>
				<xsl:for-each select="//archimate:Meaning[@id = //archimate:AssociationRelationship[@source=$Oid]/@target]">
					<enforcing>
						<xsl:copy-of select="//archimate:ApplicationService[@id=//archimate:AssociationRelationship[@source=current()/@id]/@target]/@name"/>
						<xsl:copy-of select="./documentation"/>
						<xsl:call-template name="supporting"/>
					</enforcing>
				</xsl:for-each>
			</obj>
		</xsl:for-each>
	</xsl:variable>
	<table class="rationale">
		<tr>
				<th/>
			<xsl:for-each select="$envs">
				<th> <emphasis role="rotated"><xsl:value-of select="@name"/></emphasis></th>
			</xsl:for-each>
		</tr>
		<xsl:for-each select="//archimate:ApplicationService[@id=//archimate:RealisationRelationship[@source=//archimate:ApplicationFunction[starts-with(@name,'TSF')]/@id]/@target]">
			<tr>
				<xsl:variable name="cur" select="."/>
					<td><xsl:value-of select="$cur/@name"/></td>
				<xsl:for-each select="$meanings/obj">
					<td>
<!--
							<xsl:value-of select="$cur/@name"/>, <xsl:value-of select="$cur/@id"/>,
							<xsl:value-of select="current()/@name"/>.<xsl:value-of select="current()/@id"/>
-->
						<xsl:if test="enforcing/supporting[@name = $cur/@name]|enforcing[@name = $cur/@name]">
							X
						</xsl:if>
					</td>
				</xsl:for-each>
			</tr>
		</xsl:for-each>
	</table>
	<xsl:result-document href="generated/meanings.xls">
		<xsl:copy-of select="$meanings"/>
	</xsl:result-document>
	<table>
	<xsl:for-each select="$meanings/obj">
		<xsl:sort select="@name"/>
			<tr> <td class="starter"> <para><xsl:value-of select="@name"/></para>
			Biztosítják a biztonsági cél teljesülését:
			<itemizedlist>
			<xsl:for-each select="enforcing[@name]">
				<listitem>
					<xsl:value-of select="./@name"/> - <!-- <fff><xsl:copy-of select="."/></fff>--><xsl:value-of select="documentation"/>
				</listitem>
			</xsl:for-each>
			</itemizedlist>
			<xsl:if test="enforcing/supporting[not(@name = current()/enforcing/@name)]">	
				Támogatják a biztonsági cél teljesülését:
				<itemizedlist>
					<xsl:for-each select="distinct-values(enforcing/supporting[not(@name = current()/enforcing/@name)]/@id)">
						<listitem><xsl:value-of select="($meanings//supporting[@id=current()]/@name)[1]"/> -
							<xsl:apply-templates select="($meanings//supporting[@id=current()]/documentation)[1]"/>
						</listitem>
<xsl:message terminate="no">
<xsl:value-of select="."/>
</xsl:message>
					</xsl:for-each>
				</itemizedlist>
			</xsl:if>
			</td></tr>
		</xsl:for-each>
	</table>
</xsl:template>

<xsl:template name="supporting">
	<xsl:for-each select="//archimate:ApplicationService[@id = //archimate:UsedByRelationship[@target=current()/@id]/@source]">
		<supporting>
			<xsl:copy-of select="./@id"/>
			<xsl:copy-of select="./@name"/>
			<xsl:copy-of select="//archimate:Meaning[@id=//archimate:AssociationRelationship[@source=current()/@id]/@target]/documentation"/>
		</supporting>
	<xsl:for-each select="//archimate:ApplicationService[@id = //archimate:UsedByRelationship[@target=current()/@id]/@source]">
		<supporting>
			<xsl:copy-of select="./@id"/>
			<xsl:copy-of select="./@name"/>
			<xsl:copy-of select="//archimate:Meaning[@id=//archimate:AssociationRelationship[@source=current()/@id]/@target]/documentation"/>
		</supporting>
	</xsl:for-each>
	</xsl:for-each>
</xsl:template>


</xsl:stylesheet>
