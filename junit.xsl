<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xsl:template name="millisecs-to-ISO">
        <xsl:param name="millisecs"/>

        <xsl:param name="JDN" select="floor($millisecs div 86400000) + 2440588"/>
        <xsl:param name="mSec" select="$millisecs mod 86400000"/>

        <xsl:param name="f" select="$JDN + 1401 + floor((floor((4 * $JDN + 274277) div 146097) * 3) div 4) - 38"/>
        <xsl:param name="e" select="4*$f + 3"/>
        <xsl:param name="g" select="floor(($e mod 1461) div 4)"/>
        <xsl:param name="h" select="5*$g + 2"/>

        <xsl:param name="d" select="floor(($h mod 153) div 5 ) + 1"/>
        <xsl:param name="m" select="(floor($h div 153) + 2) mod 12 + 1"/>
        <xsl:param name="y" select="floor($e div 1461) - 4716 + floor((14 - $m) div 12)"/>

        <xsl:param name="H" select="floor($mSec div 3600000)"/>
        <xsl:param name="M" select="floor($mSec mod 3600000 div 60000)"/>
        <xsl:param name="S" select="$mSec mod 60000 div 1000"/>

        <xsl:value-of select="concat($y, format-number($m, '-00'), format-number($d, '-00'))" />
        <xsl:value-of select="concat(format-number($H, 'T00'), format-number($M, ':00'), format-number($S, ':00'))" />
    </xsl:template>

    <!-- 
        https://jmeter.apache.org/usermanual/listeners.html#attributes

        JMeter Attribute Meanings - If enabled in JMeter

        by          Bytes
        sby         Sent Bytes
        de          Data encoding
        dt          Data type
        ec          Error count (0 or 1, unless multiple samples are aggregated)
        hn          Hostname where the sample was generated
        it          Idle Time = time not spent sampling (milliseconds) (generally 0)
        lb          Label
        lt          Latency = time to initial response (milliseconds) - not all samplers support this
        ct          Connect Time = time to establish the connection (milliseconds) - not all samplers support this
        na          Number of active threads for all thread groups
        ng          Number of active threads in this group
        rc          Response Code (e.g. 200)
        rm          Response Message (e.g. OK)
        s           Success flag (true/false)
        sc          Sample count (1, unless multiple samples are aggregated)
        t           Elapsed time (milliseconds)
        tn          Thread Name
        ts          timeStamp (milliseconds since midnight Jan 1, 1970 UTC)
        varname     Value of the named variable
     -->

    <xsl:template match="/testResults">
        <testsuites>
            <testsuite>
                <!-- required for Junit xsd - no available in the jmeter result -->
                <xsl:attribute name="id">1</xsl:attribute>
                <!-- required for Junit xsd - no available in the jmeter result -->
                <xsl:attribute name="name">performance test</xsl:attribute>
                <!-- required for Junit xsd - no available in the jmeter result -->
                <xsl:attribute name="package">performance test</xsl:attribute>
                <!-- required for Junit xsd - no available in the jmeter result -->
                <xsl:attribute name="hostname">Azure DevOps</xsl:attribute>
                <!-- required for JUnit xsd -->
                <xsl:attribute name="timestamp">
                    <xsl:call-template name="millisecs-to-ISO">
                        <!-- get timestamp from first test result convert it from epoch to ISO8601 -->
                        <xsl:with-param name="millisecs" select="*[1]/@ts" />
                    </xsl:call-template>
                </xsl:attribute>
                <!-- required for Junit xsd - count of test results -->
                <xsl:attribute name="tests"><xsl:value-of select="count(*)"/></xsl:attribute>
                <!-- required for Junit xsd - count of test failures -->
                <xsl:attribute name="failures"><xsl:value-of select="count(*[./assertionResult/failure[text() = 'true']])"/></xsl:attribute>
                <!-- required for Junit xsd - count of test errors -->
                <xsl:attribute name="errors"><xsl:value-of select="count(*[./assertionResult/error[text() = 'true']])"/></xsl:attribute>
                <!-- required for Junit xsd - Time taken (in seconds) to execute all the tests -->
                <xsl:attribute name="time"><xsl:value-of select="sum(*/@t) div 1000"/></xsl:attribute>
                <properties></properties>
                <xsl:for-each select="*">
                    <testcase>
                        <xsl:attribute name="classname"><xsl:value-of select="name()"/></xsl:attribute>
                        <xsl:attribute name="name"><xsl:value-of select="@lb"/></xsl:attribute>
                        <xsl:attribute name="time"><xsl:value-of select="@t div 1000"/></xsl:attribute>
                        <xsl:if test="assertionResult/failureMessage">
                            <failure>
                                <!-- show only the first failure message (if multiple) as the JUnit schema only supports one faulure node -->
                                <xsl:attribute name="message"><xsl:value-of select="assertionResult[./failure = 'true']/failureMessage"/></xsl:attribute>
                                <!-- show only the first failure type (if multiple) as the JUnit schema only supports one faulure node -->
                                <xsl:attribute name="type"><xsl:value-of select="assertionResult[./failure = 'true']/name"/></xsl:attribute>
                            </failure>
                        </xsl:if>
                        <xsl:if test="@s = 'false'">
                            <xsl:if test="responseData">
                                <error><xsl:value-of select="responseData"/></error>
                            </xsl:if>
                        </xsl:if>
                    </testcase>
                </xsl:for-each>
                <!-- required for JUnit xsd -->
                <system-out></system-out>
                <!-- required for JUnit xsd -->
                <system-err></system-err>
            </testsuite>
        </testsuites>
    </xsl:template>
</xsl:stylesheet>