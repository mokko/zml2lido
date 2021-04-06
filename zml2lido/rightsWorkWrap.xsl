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
		<xsl:message><xsl:value-of select="z:systemField[@name ='__id']"/></xsl:message>
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
        <lido:rightsHolder>
			<xsl:variable name="vi" select="z:moduleReference[@name = 'ObjOwnerRef']"/>
			<xsl:choose>
                <xsl:when test="$vi = 'Ethnologisches Museum, Staatliche Museen zu Berlin'">
                    <lido:legalBodyID lido:type="concept-ID" lido:source="ISIL (ISO 15511)">DE-MUS-019118</lido:legalBodyID>
                    <lido:legalBodyName>
                        <lido:appellationValue>Ethnologisches Museum, Staatliche Museen zu Berlin</lido:appellationValue>
                    </lido:legalBodyName>
                    <lido:legalBodyWeblink>http://www.smb.museum/em</lido:legalBodyWeblink>
                </xsl:when>
                <xsl:when test="$vi = 'Museum für Asiatische Kunst, Staatliche Museen zu Berlin'">
                    <lido:legalBodyID lido:type="concept-ID" lido:source="ISIL (ISO 15511)">DE-MUS-019014</lido:legalBodyID>
                    <lido:legalBodyName>
                        <lido:appellationValue>Museum für Asiatische Kunst, Staatliche Museen zu Berlin</lido:appellationValue>
                    </lido:legalBodyName>
                    <lido:legalBodyWeblink>http://www.smb.museum/aku</lido:legalBodyWeblink>
                </xsl:when>
                <xsl:when test="not(string($vi))">
                	<xsl:message>do nothing and for once that's ok</xsl:message>
                </xsl:when>
				<xsl:otherwise>
                    <xsl:message terminate="yes">
						<xsl:value-of select="$vi"/>
						<xsl:text>Error: Unknown institution in defaultRightsHolder</xsl:text>
					</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
        </lido:rightsHolder>
	</xsl:template>
</xsl:stylesheet>