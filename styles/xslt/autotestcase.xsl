<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
	xmlns:my="http://magwas.rulez.org/my"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="xml|tests|cmstest">
	<testplan>
		<xsl:apply-templates select="testcase"/>
		<xsl:apply-templates select="test"/>
		<xsl:apply-templates select="TESTCASE"/>
		<xsl:apply-templates select="call"/>
	</testplan>
</xsl:template>

<xsl:variable name="poznegmap">
        <map from="pozitív" to="+"/>
        <map from="Pozitív" to="+"/>
        <map from="negatív" to="-"/>
        <map from="Negatív" to="-"/>
        <map from="positive" to="+"/>
        <map from="negative" to="-"/>
        <map from="" to="+"/>
        <map from="NEGATIVE" to="-"/>
</xsl:variable>

<xsl:variable name="needstate">
<method>GetDoubler</method>
<method>GetMultiplier</method>
<method>GetRoulette</method>
<method>GetRisiko</method>
<method>Deal</method>
<method>Draw</method>
<method>GetMystery</method>
<method>GetForntune</method>
</xsl:variable>

<xsl:function name="my:isNeedState">
	<xsl:param name="method"/>
	<xsl:variable name="needmap">
		<xsl:for-each select="$needstate/method">
			<xsl:if test="contains($method,.)">
				<needs/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:copy-of select="boolean($needmap/needs)"/>
</xsl:function>

<!--<problem type="Failed" method="{@name}" param="{@qualifier}"/>-->
<!-- FIXME problems should be reported in the combinator, not the creator, as it is business logic -->
<xsl:function name="my:problem">
	<xsl:param name="type"/>
	<xsl:param name="method"/>
	<xsl:param name="qualifier"/>
	<xsl:variable name="msg">
		<problem type="{$type}" method="{$method}" param="{$qualifier}"/>
	</xsl:variable>
	<xsl:message select="$msg"/>
	<xsl:copy-of select="$msg"/>
</xsl:function>

<xsl:template match="test">
	<testcase>
	<xsl:variable name="pn" select="$poznegmap//map[@from=current()/pozneg/text()]/@to"/>
	<xsl:attribute name="type" select="$pn"/>
	<xsl:attribute name="name" select="current()/fvname"/><!-- testcase name -->
	<xsl:for-each select="concat(controller,'::',fuggveny)">
		<tested>
			<xsl:attribute name="type" select="$pn"/>
			<xsl:attribute name="fnname" select="."/><!-- tested method name -->
		</tested>
	</xsl:for-each>
	</testcase>
</xsl:template>

<xsl:template match="TESTCASE">
	<testcase>
	<xsl:variable name="pn" select="if (PozNeg) then $poznegmap//map[@from=current()/PozNeg/text()]/@to else $poznegmap//map[@from=current()/Type/text()]/@to"/>
	<xsl:attribute name="type" select="$pn"/>
	<xsl:attribute name="name" select="current()/Name"/><!-- testcase name -->
	<xsl:for-each select=".//Function">
		<tested>
			<xsl:attribute name="type" select="$pn"/>
			<xsl:attribute name="fnname" select="."/><!-- tested method name -->
		</tested>
	</xsl:for-each>
	</testcase>
</xsl:template>

<xsl:template match="testcase">
	<xsl:choose>
		<xsl:when test="@posneg">
			<testcase> 
				<xsl:variable name="pn" select="$poznegmap/map[@from=current()/@posneg]/@to"/>
				<xsl:attribute name="type" select="$pn"/>
				<xsl:attribute name="name" select="concat(@testcase,@parameter)"/><!-- testcase name -->
				<tested>
					<xsl:attribute name="type" select="$pn"/>
					<xsl:attribute name="fnname" select="@testcase"/><!-- tested method name -->
					<xsl:apply-templates select=".//exception"/>
					<xsl:apply-templates select=".//serverEvent[@eventtypeid='GameState']"/>
				</tested>
				<xsl:if test="(@posneg = 'negative' ) and not (.//exception or .//serverEvent[@EventTypeId='exception' or @EventTypeId='loginFailed'])">
					<xsl:copy-of select="my:problem('noexception',@testcase,@parameter)"/>
				</xsl:if>
				<xsl:if test="(@posneg = 'positive' ) and my:isNeedState(@testcase) and not (.//serverEvent[@EventTypeId='GameState'])">
					<xsl:copy-of select="my:problem('noState',@testcase,@parameter)"/>
				</xsl:if>
				<xsl:if test="not(.//testcasePassed)">
					<xsl:copy-of select="my:problem('Failed',@testcase,@parameter)"/>
				</xsl:if>
			</testcase>
		</xsl:when>
		<xsl:when test="@qualifier">
			<testcase>
				<xsl:variable name="pn" select="$poznegmap/map[@from=substring-before(current()/@qualifier,'_')]/@to"/>
				<xsl:attribute name="type" select="$pn"/>
				<xsl:attribute name="name" select="concat(@name,@qualifier)"/><!-- testcase name -->
				<tested>
					<xsl:attribute name="type" select="$pn"/>
					<!--<xsl:attribute name="fnname" select="substring-after(@name,'::')"/>-->
					<xsl:attribute name="fnname" select="@name"/>
					<xsl:apply-templates select=".//exception"/>
					<xsl:apply-templates select=".//serverEvent[@eventtypeid='GameState']"/>
				</tested>
				<xsl:if test="contains(@qualifier,'NEGATIVE' ) and not (.//exception or .//serverEvent[@EventTypeId='exception' or @EventTypeId='pagePermissionError' or @EventTypeId='logoutFailed'])">
					<xsl:copy-of select="my:problem('noexception',@name,@qualifier)"/>
				</xsl:if>
				<xsl:if test="not(.//testcasePassed)">
					<xsl:copy-of select="my:problem('Failed',@name,@qualifier)"/>
				</xsl:if>
			</testcase>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="yes">unknown testcase: <xsl:copy-of select="."/>
			</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="serverEvent">
	<serverEvent>
		<xsl:copy-of select="@eventtypeid"/>
	</serverEvent>
</xsl:template>
<xsl:template match="exception">
	<exception>
		<xsl:copy-of select="@type"/>
	</exception>
</xsl:template>

<xsl:template match="call">
	<xsl:if test="my:isNeedState(@method) and not (.//serverEvent[@EventTypeId='GameState'])">
		<problem type="noState" method="{@method}" />
		<xsl:copy-of select="."/>
	</xsl:if>
</xsl:template>


</xsl:stylesheet>

