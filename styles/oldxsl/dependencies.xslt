<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:archimate="http://www.bolton.ac.uk/archimate"
xmlns:fn="http://www.w3.org/2005/xpath-functions">

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

<!--
<xsl:param name="doxyfile"/>
<xsl:param name="targetdir"/>
<xsl:variable name="doxyobjs" select="document(fn:concat($targetdir,'/',$doxyfile))"/>
<xsl:variable name="archiobjs" select="/"/>
-->

	<xsl:variable name="tsflist" select="//archimate:ApplicationFunction[@id=//archimate:SpecialisationRelationship[@target=//archimate:ApplicationFunction[@id=//archimate:SpecialisationRelationship[@target=//archimate:ApplicationFunction[@name='TSF']/@id]/@source]/@id]/@source]"/>

<xsl:template name="checkdoc">
	<!-- check for tsfs in model -->
	<xsl:result-document href="tsflist">
		<xsl:copy-of select="$tsflist"/>
	</xsl:result-document>

	<xsl:for-each select="$doxyobjs//tsf">
		<xsl:variable name="tsfname" select="fn:normalize-space(string(.))"/>
		<xsl:if test="not($tsflist[@name=$tsfname])">
			<problem type="No archimate object for tsf {$tsfname}" name="{(ancestor::component|ancestor::member)/@name}" table="{(ancestor::component|ancestor::member)/@location}"/>
		</xsl:if>
	</xsl:for-each>
		
	<!-- check for sfrs in model FIXME: it is not checked whether the applicationFunction is actually descendant of TSF-->
	<xsl:for-each select="$doxyobjs//sfr">
		<xsl:variable name="sfrname" select="fn:normalize-space(string(.))"/>
		<xsl:if test="not($archiobjs//archimate:ApplicationService[@name=$sfrname])">
			<problem type="No archimate object for sfr: {$sfrname}" name="{(ancestor::component|ancestor::member)/@name}" table="{(ancestor::component|ancestor::member)/@location}"/>
		</xsl:if>
	</xsl:for-each>
	<!-- check for tsfis in model FIXME: it is not checked whether the applicationInterface is actually descendant of TSFI -->
	<xsl:for-each select="$doxyobjs//tsfi">
		<xsl:variable name="tsfname" select="fn:normalize-space(string(.))"/>
		<xsl:if test="not($archiobjs//archimate:ApplicationInterface[@name=$tsfname])">
			<problem type="No archimate object for tsfi: {$tsfname}" name="{(ancestor::component|ancestor::member)/@name}" table="{(ancestor::component|ancestor::member)/@location}"/>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template name="tsfhierarchy">
<doc>
	<TSFS>
			<xsl:for-each select="//archimate:*[@id=//archimate:SpecialisationRelationship[@target=//archimate:*[@name='TSF']/@id]/@source]">
				<TSF>
					<this><xsl:copy-of select="."/></this>
				<xsl:for-each select="//archimate:*[@id=//archimate:SpecialisationRelationship[@target=current()/@id]/@source]">
					<subtsf>
						<this><xsl:copy-of select="."/></this>
					<xsl:variable name="functions">
					<xsl:for-each select="$doxyobjs//tsf[fn:normalize-space(string(.))=current()/@name]/(ancestor::component|ancestor::member)">
						<enforcing name="{./@name}">
							<this><xsl:copy-of select="."/></this>
					
							<xsl:variable name="enforcing">
			 					<xsl:copy-of select="."/>
							</xsl:variable>
							<supporting>
								<xsl:call-template name="supportinglist">
									<xsl:with-param name="current">
										<all>
											<processed/>
											<new>
				 								<xsl:copy-of select="$enforcing"/>
											</new>
										</all>
									</xsl:with-param>
								</xsl:call-template>
							</supporting>
						</enforcing>
					</xsl:for-each>
					</xsl:variable>
					<ef>
						<xsl:for-each select="$functions//enforcing/this/*">
							<xsl:copy-of select="."/>
						</xsl:for-each>
					</ef>
					<sup>
						<!-- this should be much more simple! -->
						<xsl:for-each select="fn:distinct-values($functions//supporting/*/@id)">
							<xsl:sort select="."/>
							<xsl:for-each select="$functions//supporting/*[@id=current()]">
								<xsl:if test="fn:position() = 1">
									<xsl:copy-of select="."/>
								</xsl:if>
							</xsl:for-each>
						</xsl:for-each>
					</sup>
					</subtsf>
				</xsl:for-each>
				</TSF>
			</xsl:for-each>
	</TSFS>
	<TSFIS>
			<xsl:for-each select="//archimate:*[@id=//archimate:SpecialisationRelationship[@target=//archimate:*[@name='ToeInterface']/@id]/@source]">
				<TSFI>
					<this><xsl:copy-of select="."/></this>
					<xsl:variable name="functions">
					<xsl:for-each select="$doxyobjs//tsfi[fn:normalize-space(string(.))=current()/@name]/(ancestor::component|ancestor::member)">
						<enforcing name="{./@name}">
							<this><xsl:copy-of select="."/></this>
					
							<xsl:variable name="enforcing">
			 					<xsl:copy-of select="$doxyobjs//*[@id=current()/@id]"/>
							</xsl:variable>

							<supporting>
								<xsl:call-template name="supportinglist">
									<xsl:with-param name="current">
										<all>
											<processed/>
											<new>
				 								<xsl:copy-of select="$enforcing"/>
											</new>
										</all>
									</xsl:with-param>
								</xsl:call-template>
							</supporting>
						</enforcing>
					</xsl:for-each>
					</xsl:variable>
					<ef>
						<xsl:for-each select="$functions//enforcing/this/*">
							<xsl:copy-of select="."/>
						</xsl:for-each>
					</ef>
					<sup>
						<xsl:for-each select="$functions//supporting/*">
							<xsl:copy-of select="."/>
						</xsl:for-each>
					</sup>
				</TSFI>
			</xsl:for-each>
	</TSFIS>
</doc>
</xsl:template>

<xsl:template name="supportinglist">
	<xsl:param name="current"/>
<!--
<xsl:message>
	calling with <xsl:value-of select="$current//@id"/>
</xsl:message>
-->
	<xsl:variable name="ids">
		<xsl:call-template name="_supportinglist">
			<xsl:with-param name="current" select="$current//@id"/>
		</xsl:call-template>
	</xsl:variable>
<!--
<xsl:message>
	ids: <xsl:value-of select="$ids"/>
</xsl:message>
-->
	<xsl:copy-of select="$doxyobjs//member[@id=$ids]"/>
</xsl:template>
<!--
	(<xsl:copy-of select="$current"/>)
			[<xsl:copy-of select="."/>]
			<xsl:message><xsl:copy-of select="$doxyobjs//*[@id=current()/@refid]"/></xsl:message>
-->
<xsl:template name="_supportinglist">
	<xsl:param name="depth" select="1"/>
	<xsl:param name="current"/>
	<xsl:variable name="called" select="$doxyobjs//member[@id=$current]//references/@refid"/>
<!--
<xsl:message terminate="no">
	depth: <xsl:value-of select="$depth"/>
</xsl:message>
 <xsl:for-each select="$current">
	current: <xsl:copy-of select="."/>
	</xsl:for-each>
 <xsl:for-each select="$called">
	called: <xsl:copy-of select="."/>
	</xsl:for-each>
 <xsl:for-each select="$called except current">
	new: <xsl:copy-of select="."/>
	</xsl:for-each>
</xsl:message>
-->
		<xsl:if test="$called except $current">
<!--
<xsl:message>
	called: <xsl:value-of select="$called"/>
	current: <xsl:value-of select="$current"/>
	new: <xsl:value-of select="$called except $current"/>
</xsl:message>
-->
		<xsl:call-template name="_supportinglist">
			<xsl:with-param name="current" select="$called union $current"/>
			<xsl:with-param name="depth" select="$depth + 1"/>
		</xsl:call-template>
		</xsl:if>
	<xsl:copy-of select="distinct-values($current)"/>
</xsl:template>

</xsl:stylesheet>

