<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
>

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" omit-xml-declaration="no"/>

<!--
The format of the test plan:
<testplan>
	<testcase type="+" name="Testcase name">
		<tested fnname="fully qualified function name">
			<exception/>
			<handtest/>
		</tested>
	</testcase>
</testplan>

testcase type is either "+" or "-"
exception or handtest tag should exist for all negative test cases
-->

<xsl:template match="/" priority="-2">
	<xsl:variable name="flatplan">
		<testplan>
				<xsl:variable name="linkstyles" select="//style:style[@style:parent-style-name='testlink']/@style:name,'testlink'"/>
				<xsl:message terminate="no"><xsl:value-of select="$linkstyles"/></xsl:message>
				<xsl:apply-templates select="//text:p" mode="extractPlan">
					<xsl:with-param name="linkstyles" select="$linkstyles" tunnel="yes"/>
				</xsl:apply-templates>
		</testplan>
	</xsl:variable>
	<xsl:for-each select="$flatplan">
		<xsl:call-template name="hierarchize"/>
	</xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="extractPlan">
</xsl:template>

<xsl:template match="text:span[@text:style-name='testcasenegative']" mode="extractPlan">
	<xsl:message terminate="no">
	testcase=<xsl:value-of select="."/>
	</xsl:message>
	<testcase type="-">
		<xsl:value-of select="."/>
	</testcase>
</xsl:template>

<xsl:template match="text:span[@text:style-name='testcasepositive']" mode="extractPlan">
	<xsl:message terminate="no">
	testcase=<xsl:value-of select="."/>
	</xsl:message>
	<testcase type="+">
		<xsl:value-of select="."/>
	</testcase>
</xsl:template>

<xsl:template match="text:p" mode="extractPlan">
	<xsl:param name="linkstyles" tunnel="yes"/>
	<xsl:choose>
		<xsl:when test="@text:style-name=$linkstyles">
			<xsl:call-template name="testcase"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="*" mode="extractPlan"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="testcase">
	<tested>
		<xsl:attribute name="fnname" select="normalize-space(.)"/>
		<handtest/>
	</tested>
</xsl:template>

<xsl:template name="hierarchize">
        <xsl:if test="local-name(./testplan/*[1]) != 'testcase'">
        <!--<xsl:result-document href="testplan.xml">
                <xsl:copy-of select="."/>
        </xsl:result-document>-->
                <xsl:message terminate="yes">test plan does not start with a test case:</xsl:message>
        </xsl:if>
        <xsl:variable name="htestplan">
                <testplan>
                        <xsl:for-each select="./testplan/testcase">
                                <xsl:call-template name="hierarchizeTestCase"/>
                        </xsl:for-each>
                </testplan>
        </xsl:variable>
<!--
        <xsl:result-document href="htestplan.xml">
                <xsl:copy-of select="$htestplan"/>
        </xsl:result-document>
-->
        <xsl:copy-of select="$htestplan"/>
</xsl:template>

<xsl:template name="hierarchizeTestCase">
        <xsl:param name="posneg"/>
        <xsl:choose>
                <xsl:when test="local-name()='testcase'">
                        <xsl:variable name="type" select="@type"/>
                        <testcase name="{.}" type="{$type}">
                        <xsl:for-each select="following-sibling::*[1]">
                                <xsl:if test="local-name()='tested'">
                                        <xsl:call-template name="hierarchizeTestCase">
                                                <xsl:with-param name="posneg" select="$type"/>
                                        </xsl:call-template>
                                </xsl:if>
                        </xsl:for-each>
                        </testcase>
                </xsl:when>
                <xsl:when test="local-name()='tested'">
                        <tested>
                        <xsl:attribute name="type"><xsl:value-of select="$posneg"/></xsl:attribute>
                        <xsl:copy-of select="@*|*"/>
                        </tested>
                        <xsl:for-each select="following-sibling::*[1]">
                                <xsl:if test="local-name()='tested'">
                                        <xsl:call-template name="hierarchizeTestCase">
                                                <xsl:with-param name="posneg" select="$posneg"/>
                                        </xsl:call-template>
                                </xsl:if>
                        </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                        <xsl:message terminate="yes">unknown thing in test plan:<xsl:copy-of select="."/></xsl:message>
                </xsl:otherwise>
        </xsl:choose>
</xsl:template>

</xsl:stylesheet>
