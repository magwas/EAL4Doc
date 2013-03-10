<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:archimate="http://www.bolton.ac.uk/archimate">

	<xsl:param name="policy"/>
	<xsl:param name="targetdir"/>
	<xsl:variable name="policyobjs" select="document(concat($targetdir,'/',$policy))"/>
	<xsl:variable name="xmlobjs" select="/"/>
	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

	<xsl:variable name="sfps">
		<SFPS>
		<xsl:for-each select="//archimate:Principle[property[@key='objectClass' and @value='SFP']]">
			<SFP>
				<xsl:variable name="sfp" select="."/>
				<xsl:copy-of select="@name|@id"/>
				<xsl:variable name="reversed" select="//archimate:AssociationRelationship[@source=current()/@id]"/>
				<xsl:if test="$reversed">
					<xsl:message terminate="yes">
						reversed associations:
						<xsl:for-each select="$reversed">
							<xsl:value-of select="//*[@id=current()/@source]/@name"/> =) <xsl:value-of select="//*[@id=current()/@target]/@name"/>
						</xsl:for-each>
					</xsl:message>
				</xsl:if>
				<xsl:for-each select="//archimate:AssociationRelationship[@target=current()/@id]">
					<xsl:variable name="name" select="//archimate:*[@id=current()/@source]/@name"/>
					<xsl:variable name="id" select="//archimate:*[@id=current()/@source]/@id"/>
					<xsl:if test="'object' = tokenize(@name,'/')">
						<SFPObject>
							<xsl:copy-of select="$name|$id"/>
							<xsl:for-each select="$policyobjs//objectClass[@name=$name]/property">
								<Attribute>
									<xsl:copy-of select="@name|@id"/>
								</Attribute>
							</xsl:for-each>
						</SFPObject>
					</xsl:if>
					<xsl:if test="'subject' = tokenize(@name,'/')">
						<SFPSubject>
							<xsl:copy-of select="$name|$id"/>
							<xsl:for-each select="$policyobjs//objectClass[@name=$name]/property">
								<Attribute>
									<xsl:copy-of select="@name|@id"/>
								</Attribute>
							</xsl:for-each>
						</SFPSubject>
					</xsl:if>
					<xsl:if test="'attribute' = tokenize(@name,'/')">
						<SFPAttribute>
							<xsl:copy-of select="//archimate:*[@id=current()/@source]/(@name|@id)"/>
						</SFPAttribute>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="//archimate:Requirement[@id=//archimate:RealisationRelationship[@target=current()/@id]/@source]">
					<SFPRequirement ruleType="{property[@key='ruleType']/@value}">
					<xsl:copy-of select="@id|@name"/>
						<xsl:for-each select="//Operation[@parentid=//archimate:RealisationRelationship[@target=current()/@id]/@source]">
							<SFPOperation>
							<xsl:copy-of select="../(@name|@id)"/>
							<xsl:for-each select="//archimate:BusinessRole[@id=//archimate:UsedByRelationship[@source=current()/@parentid]/@target]">
								<SFPRole>
								<xsl:copy-of select="@name|@id"/>
								</SFPRole>
							</xsl:for-each>
							<xsl:for-each select="//archimate:AssociationRelationship[@target=current()/@parentid]">
							<xsl:message terminate="yes">reversed association for operation: <xsl:copy-of select="."/></xsl:message>
							</xsl:for-each>
							<xsl:for-each select="//archimate:AssociationRelationship[@source=current()/@parentid]">
								<xsl:variable name="idname" select="//archimate:*[@id=current()/@target]/(@name|@id)"/>
								<xsl:for-each select="tokenize(@name,'/')">
									<SFPTarget>
										<xsl:copy-of select="$idname"/>
										<xsl:attribute name="operation" select="."/>
									</SFPTarget>
								</xsl:for-each>
							</xsl:for-each>
							</SFPOperation>
						</xsl:for-each>
					</SFPRequirement>
				</xsl:for-each>
			</SFP>
		</xsl:for-each>
		</SFPS>
		</xsl:variable>

	<xsl:template match="/">
		<xsl:result-document href="{concat($targetdir,'/generated/sfps.xml')}"><xsl:copy-of select="$sfps"/></xsl:result-document>
		<xsl:for-each select="$sfps//SFP">
		<xsl:variable name="thissfp" select="."/>
		<xsl:result-document href="{concat($targetdir,'/generated/FDP_ACC.2.1_',@name,'.xml')}"><para>
			A TSF-nek ki kell kényszerítenie a [<emphasis role="bold"><xsl:value-of select="@name"/></emphasis>]-t a [<emphasis role="bold">
			<xsl:value-of select="string-join(SFPObject/@name,', ')"/> (mint objektumok), és <xsl:value-of select="string-join(SFPSubject/@name,', ')"/> (mint szubjektumok) </emphasis>] között minden műveletre az SFP által ellenőrzött szubjektumok és objektumok tekintetében.</para></xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FDP_ACF.1.1_',@name,'.xml')}"><para>
			A TSF-nek ki kell kényszerítenie a [<emphasis role="bold"><xsl:value-of select="@name"/></emphasis>]-t az objektumokon a következő biztonsági attribútumok alapján: [
				<table class="bold"><tr><td>Objektum/Szubjektum</td><td>Biztonsági attribútumok</td></tr>
				<xsl:for-each select="distinct-values($thissfp//SFPObject/@id|$thissfp//SFPSubject/@id)">
					<xsl:for-each select="($thissfp//(SFPObject|SFPSubject)[@id=current()])[1]">
					<tr><td><xsl:value-of select="@name"/></td><td>
					<xsl:value-of select="string-join(distinct-values(Attribute[@id=$thissfp//SFPAttribute/@id]/@name),', ')"/>
					</td></tr>
				</xsl:for-each>
				</xsl:for-each>
				</table>
			].
		</para></xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FDP_ACF.1.2_',@name,'.xml')}"><para>
			A TSF-nek a következő szabályokat kell kikényszerítenie annak eldöntésére, hogy egy művelet a hatálya alá tartozó objektumok és szubjektumok tekintetében engedélyezett-e: [
				<table class="bold"><tr><td>Művelet</td><td>Szabályok</td></tr>
				<xsl:for-each select="distinct-values($thissfp//SFPOperation/@id)">
<!--
<xsl:message>
Operation:
<xsl:value-of select="($thissfp//SFPOperation[@id=current()])[1]/@name"/>:
<xsl:value-of select="distinct-values($thissfp//SFPOperation[@id=current()]/../@name)"/>,
<xsl:value-of select="string-join(distinct-values($thissfp//SFPOperation[@id=current()]/SFPRole/@name),', ')"/>
</xsl:message>
-->
					<tr><td><xsl:value-of select="($thissfp//SFPOperation[@id=current()])[1]/@name"/></td><td><itemizedlist>
						<xsl:if test="$thissfp//SFPOperation[@id=current()]/SFPRole/@name">
							<listitem>A művelethez a következő szerepkörök valamelyike szükséges:<xsl:value-of select="string-join(distinct-values($thissfp//SFPOperation[@id=current()]/SFPRole/@name),', ')"/></listitem>
						</xsl:if>
						<xsl:for-each select="distinct-values($thissfp//SFPOperation[@id=current()]/../@name)">
							<listitem><xsl:value-of select="."/></listitem>
						</xsl:for-each>
					</itemizedlist></td></tr>
				</xsl:for-each>
				</table>
			].
		</para></xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FDP_ACF.1.3_',@name,'.xml')}"><para>
			A TSF-nek explicit módon engedélyeznie kell a hozzáférést az alábbi szabályok alapján: [<emphasis role="bold">
				<xsl:choose>
					<xsl:when test="'explicitAccept' = $thissfp//SFPRequirement/@ruleType">
						<itemizedlist>
							<xsl:for-each select="$thissfp//SFPRequirement[@ruleType = 'explicitAccept']">
								<listitem><xsl:value-of select="@name"/></listitem>
							</xsl:for-each>
						</itemizedlist>
					</xsl:when>
					<xsl:otherwise>
						nincsenek explicit szabályok
					</xsl:otherwise>
				</xsl:choose>
			</emphasis>].
		</para></xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FDP_ACF.1.4_',@name,'.xml')}"><para>
			A TSF-nek explicit módon tiltania kell a hozzáférést az alábbi szabályok alapján: [<emphasis role="bold">
				<xsl:choose>
					<xsl:when test="'explicitDeny' = $thissfp//SFPRequirement/@ruleType">
						<itemizedlist>
							<xsl:for-each select="$thissfp//SFPRequirement[@ruleType = 'explicitDeny']">
								<listitem><xsl:value-of select="@name"/></listitem>
							</xsl:for-each>
						</itemizedlist>
					</xsl:when>
					<xsl:otherwise>
						nincsenek explicit szabályok
					</xsl:otherwise>
				</xsl:choose>
			</emphasis>].
		</para></xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FIA_ATD.1.1_',@name,'.xml')}">
			<table class="bold"><tr><td>Szubjektum</td><td>Biztonsági tulajdonságok</td></tr>
				<xsl:for-each select="$thissfp//SFPSubject">
					<xsl:variable name="subject" select="."/>
					<tr><td><xsl:value-of select="@name"/></td><td>
					<itemizedlist>
					<xsl:for-each select="distinct-values(Attribute/@id)">
						<xsl:if test="current()=$thissfp//SFPAttribute/@id">
							<listitem><xsl:value-of select="($subject/Attribute[@id=current()])[1]/@name"/></listitem>
						</xsl:if>
					</xsl:for-each>
					</itemizedlist>
					</td></tr>
				</xsl:for-each>
			</table>
		</xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FIA_USB.1.1_',@name,'.xml')}"><para>
			A TSF-nek össze kell kapcsolnia a felhasználó következő biztonsági tulajdonságait az adott felhasználó nevében tevékenykedő szubjektumokkal[<emphasis role="bold">
			<itemizedlist>
				<xsl:for-each select="distinct-values($thissfp//SFPRequirement[@ruleType = 'USB']//SFPTarget/@name)">
					<listitem><xsl:value-of select="."/></listitem>
				</xsl:for-each>
			</itemizedlist>
			</emphasis>].
		</para></xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FIA_USB.1.2_',@name,'.xml')}"><para>
			A TSF-nek érvényre kell juttatnia a következő szabályokat a felhasználó biztonsági tulajdonságainak és a felhasználó nevében tevékenykedő szubjektumok kezdeti összekapcsolásánál: [<emphasis role="bold">
			<itemizedlist>
				<xsl:for-each select="$thissfp//SFPRequirement[@ruleType = 'USB']">
					<listitem><xsl:value-of select="@name"/></listitem>
				</xsl:for-each>
			</itemizedlist>
			</emphasis>].
		</para></xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FIA_USB.1.3_',@name,'.xml')}"><para>
			A TSF-nek érvényre kell juttatnia a következő szabályokat a felhasználó nevében tevékenykedő szubjektumokkal összekapcsolt biztonsági tulajdonságok megváltoztatására: [<emphasis role="bold">
				<xsl:choose>
					<xsl:when test="'USBChange' = $thissfp//SFPRequirement/@ruleType">
						<itemizedlist>
							<xsl:for-each select="$thissfp//SFPRequirement[@ruleType = 'USBChange']">
								<listitem><xsl:value-of select="@name"/></listitem>
							</xsl:for-each>
						</itemizedlist>
					</xsl:when>
					<xsl:otherwise>
						nincsenek további szabályok
					</xsl:otherwise>
				</xsl:choose>
			</emphasis>].
		</para></xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FMT_MSA.1.1_',@name,'.xml')}"><para>
			<table class="bold"><tr><td>Biztonsági attribútum</td><td>Művelet</td><td>Feljogosított szerepkör</td></tr>
			<xsl:for-each select="distinct-values($thissfp//SFPAttribute/@id)">
<!--
<xsl:message>
SFPAttribute: <xsl:value-of select="."/>;<xsl:value-of select="$thissfp//SFPAttribute[@id=current()]/@name"/>
</xsl:message>
-->
				<xsl:variable name="att" select="."/>
				<xsl:for-each select="distinct-values($thissfp//SFPOperation/SFPTarget[@id=current()]/@operation)">
<!--
<xsl:message>
 SFPOperation: <xsl:value-of select="."/>
</xsl:message>
-->
					<xsl:variable name="op" select="."/>
					<xsl:for-each select="$thissfp//SFPObject[Attribute/@id=$att]/@id">
						<tr><td>
							<xsl:value-of select="$thissfp//SFPObject[@id=current()]/@name"/>.<xsl:value-of select="($thissfp//SFPObject[@id=current()]/Attribute[@id=$att]/@name)[1]"/> 
						</td><td>
							<xsl:value-of select="$op"/>:
						</td><td>
							<xsl:value-of select="string-join(distinct-values($thissfp//SFPOperation[SFPTarget[@id=$att and @operation=$op]]/SFPRole/@name),', ')"/>
						</td></tr>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:for-each>
			</table>
		</para></xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FMT_SMF.1.1_',@name,'.xml')}"><para>
				<itemizedlist>
				<xsl:for-each select="distinct-values($thissfp//SFPOperation[SFPTarget/@operation = 'Create' or SFPTarget/@operation = 'Modify' or SFPTarget/@operation = 'Delete']/@name)">
					<listitem><xsl:value-of select="."/></listitem>
				</xsl:for-each>
				</itemizedlist>
		</para></xsl:result-document>
		<xsl:result-document href="{concat($targetdir,'/generated/FMT_SMR.1.1_',@name,'.xml')}"><para>
			A TSF-nek kezelnie kell az alábbi szerepköröket: [<emphasis role="bold">
				<xsl:value-of select="string-join(distinct-values($thissfp//SFPRole/@name),', ')"/>
			</emphasis>].
		</para></xsl:result-document>
		</xsl:for-each>
		<xsl:copy-of select="$sfps"/>
	</xsl:template>
	
</xsl:stylesheet>
