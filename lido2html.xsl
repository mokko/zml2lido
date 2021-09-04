<xsl:stylesheet version="2.0"
    xmlns:lido="http://www.lido-schema.org"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xmlns="http://www.w3.org/1999/xhtml"
    xmlns:h="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="lido xsi h">

    <xsl:output method="html" name="html" version="1.0" encoding="UTF-8" indent="yes" />
    <xsl:strip-space elements="*" />

    <!-- ROOT -->
    <xsl:template match="/">
                <xsl:apply-templates select="/lido:lidoWrap/lido:lido"/>
    </xsl:template>

    <!-- INTRO -->    
    <xsl:template match="/lido:lidoWrap/lido:lido">
        <xsl:variable name="file" select="concat(normalize-space(lido:lidoRecID),'.html')"/>
        <xsl:message><xsl:value-of select="$file"/></xsl:message>
        <xsl:result-document href="{$file}" method="html" encoding="UTF-8">
            <html>
                <head>
                    <title>lido2html</title>
                    <meta charset="UTF-8" />
                </head>
                <body>
                    <h1><xsl:value-of select="lido:lidoRecID"/></h1>
                    <table border="1" width="1000">
                        <xsl:apply-templates select="*"/>
                    <tr>
                        <td colspan="2">
        In dieser Darstellung sollen alle Inhalte eines Lido Dokuments 
        strukturiert dargestellt werden. Es gibt Container und Felder; fast 
        alle Inhalte sind in Feldern, Container gruppieren im Wesentlichen 
        Felder, haben jedoch auch selbst gelegentlich Inhalte, welche die 
        folgenden Inhalte qualifizieren. Container werden hier fett 
        geschrieben; Felder nicht. Es werden in der von LIDO vorgegebenen 
        Reihenfolge nur Felder angezeigt, die vorhanden sind. Die linke Spalte 
        zeigt Feld- oder Container-Labels, die rechte Spalte Feldinhalte. Beide
        Spalten können weitere zugehörigen Informationen anzeigen. Diese 
        Information qualifizieren die Inhalte. Ich bin nicht sicher, ob diese 
        Qualifikatoren nicht besser alle in der rechten Spalte angezeigt werden 
        sollten. Wiederholfelder werden in einer Zelle angezeigt, wiederholte 
        Container bekommen eigene Zeilen.
                        </td>
                    </tr> 
                    </table>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="lido:objectPublishedID|lido:lidoRecID">
        <tr>
            <td width="34%">
                <xsl:value-of select="name()"/>
                <xsl:call-template name="attributeList"/>
            </td>
            <td with="66%">
                <xsl:value-of select="."/>
            </td>
        </tr>
    </xsl:template>

    <!-- Don't show twice -->
    <xsl:template match="
        //lido:appellationValue|
        //lido:conceptID|
        //lido:descriptiveNoteValue|
        lido:relatedWork|
        //lido:term
        "/>

    <!-- 
        TOP LEVEL containers:
        container with attributes 
    -->
    <xsl:template match="lido:descriptiveMetadata|lido:administrativeMetadata">
        <tr>
            <td colspan="2" align="center">
                <h4>
                    <xsl:value-of select="name()"/>
                    <xsl:call-template name="attributeList"/>
                </h4>
            </td>
        </tr>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- 2nd level container L1-L7 -->
    <xsl:template match="
        lido:eventWrap|
        lido:objectClassificationWrap|
        lido:objectIdentificationWrap|
        lido:objectRelationWrap|
        lido:recordWrap|
        lido:resourceWrap|
        lido:rightsWorkWrap">
        <tr>
            <td colspan="2">
                <h2>
                    <xsl:value-of select="replace(name(),'lido:','')"/>
                </h2>
            </td>
        </tr>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- 
        3rd level: non-repeatable container without attributes (all remaining wraps)
        subjectWrap is on a different level, but still a wrap (not required, non-repeatable)
    -->
    <xsl:template match="
        lido:classificationWrap|
        lido:displayStateEditionWrap|
        lido:inscriptionsWrap|
        lido:objectWorkTypeWrap|
        lido:objectDescriptionWrap|
        lido:objectMeasurementsWrap|
        lido:objectdescriptionWrap|
        lido:repositoryWrap|
        lido:subjectWrap|
        lido:titleWrap
        ">
        <tr>
            <td colspan="2" align="left">
                <h4>
                    <xsl:value-of select="name()"/>
                </h4>
            </td>
        </tr>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- 
        CONTAINER WITH OPTIONAL ATTRIBUTES (not required, repeatable), e.g. 
        eventSet which has @sortorder and two subelements displayEvent and event  
    -->
    <xsl:template match="
        lido:actor|
        lido:actorInRole|
        lido:date|
        lido:eventSet|
        lido:event|
        lido:eventActor|
        lido:eventDate|
        lido:eventMaterialsTech|
        lido:eventPlace|
        lido:measurementsSet|
        lido:objectMeasurements|
        lido:objectMeasurementsSet|
        lido:partOfPlace|
        lido:recordInfoSet|
        lido:recordRights|
        lido:repositoryLocation|
        lido:repositoryName|
        lido:resourceRepresentation|
        lido:repositorySet|
        lido:resourceSet|
        lido:resourceSource|
        lido:rightsWorkSet
        ">
        <tr>
            <td colspan="2" align="left">
                <h4>
                    <xsl:value-of select="name()"/>
                    <xsl:call-template name="attributeList"/>
                </h4>
            </td>
        </tr>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- FIELD TYPE 1 -->
    <xsl:template match="
        lido:category|
        lido:classification|
        lido:Culture|
        lido:eventType|
        lido:genderActor|
        lido:inscriptions|
        lido:legalBodyName|
        lido:materialsTech|
        lido:nameActorSet|
        lido:namePlaceSet|
        lido:objectDescriptionSet|
        lido:objectWorkType|
        lido:recordSource|
        lido:recordType|
        lido:relatedWorkSet|
        lido:resourceType|
        lido:rightsHolder|
        lido:titleSet|
        lido:vitalDatesActor
        ">
        <tr>
            <td>
                <xsl:value-of select="name()"/>
                <xsl:call-template name="attributeList"/>
            </td>
            <td>
                <xsl:for-each select="*">
                    <xsl:value-of select="name()"/>
                    <xsl:call-template name="attributeList"/>
                    <xsl:text>: </xsl:text> 
                    <xsl:value-of select="."/>
                    <br/> 
                </xsl:for-each>
            </td>
        </tr>
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <!--  FIELD TYPE 2: element with attributes plus one value, repeatable -->
    <xsl:template match="
        lido:actorID|
        lido:creditLine|
        lido:displayActorInRole|    
        lido:displayDate|
        lido:displayEvent|
        lido:displayObjectMeasurements|
        lido:displayMaterialsTech|
        lido:displayPlace|
        lido:earliestDate|
        lido:extentMeasurements|
        lido:latestDate|
        lido:linkResource|
        lido:legalBodyID|
        lido:measurementType|
        lido:measurementUnit|
        lido:measurementValue|
        lido:placeID|
        lido:recordID|
        lido:roleActor|
        lido:recordMetadataDate|
        lido:resourceDateTaken|
        lido:resourceDescription|
        lido:resourceID|
        lido:rightsType|
        lido:workID
    ">
        <tr>
            <td>
                <xsl:value-of select="name()"/>
                <xsl:call-template name="attributeList"/>
            </td>
            <td>
                <xsl:value-of select="."/>
            </td>
        </tr>
    </xsl:template>

    <!-- Linkify in HTML no attributes -->
    <xsl:template match="lido:recordInfoLink|lido:legalBodyWeblink">
        <tr>
            <td>
                <xsl:value-of select="name()"/>
            </td>
            <td>
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    <xsl:value-of select="."/>
                </xsl:element>
            </td>
        </tr>
    </xsl:template>

    <!-- NAMED TEMPLATES -->        
    <xsl:template name="attributeList">
        <xsl:if test="@*">
            <xsl:text> (</xsl:text>
            <xsl:for-each select="@*">
                <xsl:if test="position()!=1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:text>@</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>=</xsl:text> 
                <xsl:value-of select="."/>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>    
</xsl:stylesheet>