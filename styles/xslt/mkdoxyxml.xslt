<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:html="http://www.w3.org/1999/xhtml"
>

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

<xsl:param name="doxyxmldir"/>
<xsl:param name="htmldir"/>
<xsl:param name="stablever"/>

<xsl:variable name="root" select="/"/>
<!-- <xsl:variable name="doxyxmldir" select="fn:concat($targetdir,'/lld/xml/')"/>
<xsl:variable name="htmldir" select="$outdir"/>
<xsl:include href="unescape.xslt" />
-->


<xsl:template match="/" priority="-2">
	<xsl:variable name="sourcepath" select="fn:document-uri(/)"/>
<xsl:message>sourcepath=<xsl:value-of select="$sourcepath"/></xsl:message>
	<xsl:variable name="doxyxml" select="document(fn:concat($doxyxmldir,'index.xml'))"/>
 <doxy>
	<xsl:apply-templates select="$doxyxml/*" mode="fromdoxy"/>
 </doxy>
</xsl:template>

<xsl:template match="compound" mode="fromdoxy">
	<xsl:apply-templates select="$compunddef" mode="fromdoxy">
		<xsl:with-param name="refid" select="@refid"/>
	</xsl:apply-templates>
</xsl:template>

<xsl:template match="compounddef" mode="fromdoxy">
	<xsl:param name="refid"/>
	<xsl:variable name="name" select="compoundname"/>
	<xsl:variable name="path" select="fn:tokenize($name,'::')"/>
	<xsl:variable name="level" select="fn:count($path)"/>
	<xsl:variable name="parent" select="fn:string-join($path[position() &lt; last()],'::')"/>
<!--
-->
	<component
		name="{$name}"
		level="{$level}"
		parent="{$parent}"
		location="{tokenize(location/@bodyfile,'stable/.../')[2]}"
	>
		<xsl:variable name="uri">
			<xsl:value-of select="fn:concat($htmldir,$refid,'.html')"/>
		</xsl:variable>
		<xsl:attribute name="url" select="fn:concat($refid,'.html')"/>
			<xsl:copy-of select="@*"/>
		<xsl:copy-of select="briefdescription|detaileddescription|location"/>
<!--
		<documentation>
			<xsl:copy-of select="document($uri)//html:a[@id='details'][1]/following-sibling::html:div[1]"/>
		</documentation>
-->
<!--//compounddef/*[local-name()='briefdescription' or local-name() = 'detaileddescription']//*[local-name()='tsfi' or local-name()='tsf']-->
<!--
		<xsl:copy-of select="location|.//tsf|.//tsfi|.//sfr"/>
-->
	</component>
			<xsl:apply-templates select=".//memberdef" mode="fromdoxy">
				<xsl:with-param name="parent" tunnel="yes" select="$name"/>
			</xsl:apply-templates>
</xsl:template>


<xsl:template match="memberdef" mode="fromdoxy">
	<xsl:param name="parent" tunnel="yes"/>
<!--	<xsl:if test="@prot='public'"> -->
	<xsl:variable name="tokenized" select="fn:tokenize(string(@id),'_')"/>

	<member
		parent="{$parent}"
		name="{normalize-space(concat(name,' ',argsstring))}"
		location="{tokenize(location/@bodyfile,'stable/.../')[2]}"
		url="{$htmldir}/{fn:concat(fn:string-join($tokenized[position() &lt; last() ],'_'),'.html#',fn:substring-after($tokenized[position() = last()],'1'))}"
	>
		<xsl:variable name="id">
			<xsl:value-of select="fn:substring-after($tokenized[position() = last()],'1')"/>
		</xsl:variable>
		<xsl:variable name="uribase">
			<xsl:value-of select="fn:concat(fn:string-join($tokenized[position() &lt; last() ],'_'),'.html')"/>
		</xsl:variable>
		<xsl:variable name="uri">
			<xsl:value-of select="fn:concat($uribase,'#',$id)"/>
		</xsl:variable>
		<xsl:attribute name="url" select="fn:concat($uribase,'#',$id)"/>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="*"/>
<!--
		<documentation>
			<xsl:copy-of select="document(fn:concat($htmldir,$uribase))//html:a[@id=$id][1]/following-sibling::html:div[1]"/>
		</documentation>
-->
		<xsl:copy-of select="location|.//tsf|.//tsfi|.//sfr|.//briefdescription|.//contract|.//argsstring|.//simplesect[@kind='return']|.//error|.//audit|.//references"/>
	</member>
<!--	</xsl:if> -->
</xsl:template>

</xsl:stylesheet>
