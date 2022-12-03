<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:z="http://www.zetcom.com/ria/ws/module"
    exclude-result-prefixes="z"
    xsi:schemaLocation="http://www.lido-schema.org http://www.lido-schema.org/schema/v1.0/lido-v1.0.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- 
    SPEC 1.0: 
    (1) rightsWorkWrap: rights information about the object / work described
    (2) rightsWorkSet: Information about rights management; may include copyright and
    other intellectual property statements about the object / work. 
    
    Rights for the record in rightsRecord
    Rights for the resource in rightsResource
    
    Credits hat wohl einen Bezug zu rightsWork 
    Bei DLG hat jemand anders die Rechte?
    -->

    <xsl:template name="rightsWorkWrap">
		<!--
		why is the id logged in rightsWorkWrap?
		xsl:message><xsl:value-of select="z:systemField[@name ='__id']"/></xsl:message-->
        <lido:rightsWorkWrap>
            <lido:rightsWorkSet>
                <xsl:call-template name="defaultRightsHolder"/>
                <!-- xsl:apply-templates select="credits"/ -->
            </lido:rightsWorkSet>
        </lido:rightsWorkWrap>
    </xsl:template>

    <xsl:template match="credits">
    	<!-- objCreditLineVoc, but have to example case to test it with (in 1 Grunddaten) -->
        <lido:creditLine>
            <xsl:value-of select="."/>
        </lido:creditLine>
    </xsl:template>

    <xsl:template name="defaultRightsHolder">
		<xsl:variable name="verwaltendeInstitution" select="z:moduleReference[@name = 'ObjOwnerRef']"/>
		<xsl:choose>
			<xsl:when test="normalize-space($verwaltendeInstitution) ne ''">
				<lido:rightsHolder>
					<xsl:call-template name="legalBody">
						<xsl:with-param name="verwaltendeInstitution" select="$verwaltendeInstitution"/>
					</xsl:call-template>
				</lido:rightsHolder>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>
					<xsl:text>WARNING: No verwaltendeInstitution!</xsl:text>
				</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>